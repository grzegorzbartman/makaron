import AppKit

struct SystemInfo {
    var battery: String = ""
    var batteryCharging: Bool = false
    var batteryPercent: Int = -1
    var cpu: String = ""
    var memory: String = ""
    var storage: String = ""
    var wifi: String = ""
    var timerActive: Bool = false
    var timerDuration: String = ""
    var timerDetail: String = ""
    var timerAvailable: Bool = false
    var timerTags: [String] = []
    var timerRecent: [(duration: String, title: String, day: String)] = []
    var timerTodayTotal: String = ""
    var calendarEvents: [(time: String, title: String)] = []
    var todoistTasks: [(content: String, priority: Int)] = []
    var frontApp: String = ""
}

class SystemInfoProvider {
    static let shared = SystemInfoProvider()

    private let makaronPath: String
    private var cache = SystemInfo()
    private var systemTimer: Timer?
    private var fastTimer: Timer?
    private var slowTimer: Timer?

    private init() {
        makaronPath = ProcessInfo.processInfo.environment["MAKARON_PATH"]
            ?? "\(NSHomeDirectory())/.local/share/makaron"
    }

    func start() {
        refreshAll()
        systemTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refreshSystem()
        }
        fastTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.refreshFast()
        }
        slowTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.global(qos: .utility).async { self?.refreshSlow() }
        }
    }

    func stop() {
        systemTimer?.invalidate()
        fastTimer?.invalidate()
        slowTimer?.invalidate()
    }

    func getCached() -> SystemInfo { cache }

    func refreshAll() {
        refreshSystem()
        refreshFast()
        refreshSlow()
    }

    private func refreshSystem() {
        cache.battery = fetchBattery()
        cache.cpu = fetchCPU()
        cache.memory = fetchMemory()
        cache.storage = fetchStorage()
        cache.wifi = fetchWiFi()
        cache.frontApp = NSWorkspace.shared.frontmostApplication?.localizedName ?? ""
    }

    private func refreshFast() {
        fetchTimerStatus()
    }

    private func refreshSlow() {
        cache.calendarEvents = fetchCalendar()
        cache.todoistTasks = fetchTodoist()
    }

    // MARK: - Battery

    private func fetchBattery() -> String {
        let out = shell("pmset", args: ["-g", "batt"])
        cache.batteryCharging = out.contains("AC Power")
        if let range = out.range(of: #"\d+%"#, options: .regularExpression) {
            let pctStr = String(out[range]).replacingOccurrences(of: "%", with: "")
            cache.batteryPercent = Int(pctStr) ?? -1
            let icon = cache.batteryCharging ? "⚡" : ""
            return "\(pctStr)% \(icon)".trimmingCharacters(in: .whitespaces)
        }
        return ""
    }

    // MARK: - CPU

    private func fetchCPU() -> String {
        let cores = shell("sysctl", args: ["-n", "hw.ncpu"]).trimmingCharacters(in: .whitespacesAndNewlines)
        let uptimeOut = shell("uptime", args: [])
        guard let loadPart = uptimeOut.components(separatedBy: "load averages:").last
                ?? uptimeOut.components(separatedBy: "load average:").last else { return "N/A" }
        let load = loadPart.trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ").first?
            .replacingOccurrences(of: ",", with: "") ?? "?"
        return "\(load)/\(cores)"
    }

    // MARK: - Memory

    private func fetchMemory() -> String {
        let bin = "\(makaronPath)/bin/makaron-memory-stats"
        let out = shell(bin, args: []).trimmingCharacters(in: .whitespacesAndNewlines)
        return out.isEmpty ? "N/A" : out
    }

    // MARK: - Storage

    private func fetchStorage() -> String {
        let out = shell("df", args: ["-H", "/System/Volumes/Data"])
        let lines = out.components(separatedBy: "\n")
        guard lines.count > 1 else { return "N/A" }
        let cols = lines[1].split(separator: " ", omittingEmptySubsequences: true)
        guard cols.count >= 3 else { return "N/A" }
        return "\(cols[2])/\(cols[1])"
    }

    // MARK: - WiFi

    private func fetchWiFi() -> String {
        let out = shell("/usr/sbin/ipconfig", args: ["getsummary", "en0"])
        for line in out.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("SSID :") || trimmed.hasPrefix("SSID:") {
                let ssid = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                if !ssid.isEmpty { return ssid }
            }
        }
        return "Disconnected"
    }

    // MARK: - Timer

    private func fetchTimerStatus() {
        let bin = "\(makaronPath)/bin/makaron-timer"
        let out = shell(bin, args: ["status"])
        guard let data = out.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            cache.timerAvailable = false
            return
        }
        cache.timerAvailable = json["available"] as? Bool ?? false
        cache.timerActive = json["active"] as? Bool ?? false
        cache.timerDuration = json["duration"] as? String ?? ""
        cache.timerDetail = json["detail"] as? String ?? ""
        cache.timerTags = readTimerTags()
        fetchTimerRecent()
        fetchTimerToday()
    }

    private func fetchTimerRecent() {
        let bin = "\(makaronPath)/bin/makaron-timer"
        let out = shell(bin, args: ["recent", "3"])
        guard let data = out.data(using: .utf8),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            cache.timerRecent = []
            return
        }
        cache.timerRecent = arr.map { entry in
            let dur = entry["duration"] as? String ?? ""
            let title = entry["title"] as? String ?? ""
            let day = entry["day"] as? String ?? ""
            return (dur, title, day)
        }
    }

    private func fetchTimerToday() {
        let bin = "\(makaronPath)/bin/makaron-timer"
        let out = shell(bin, args: ["today"])
        guard let data = out.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            cache.timerTodayTotal = ""
            return
        }
        let total = json["total"] as? String ?? "0:00"
        let entries = json["entries"] as? Int ?? 0
        cache.timerTodayTotal = "\(total) (\(entries) entries)"
    }

    private func readTimerTags() -> [String] {
        let confPath = "\(NSHomeDirectory())/.config/makaron/makaron.conf"
        guard let content = try? String(contentsOfFile: confPath, encoding: .utf8) else {
            return ["other"]
        }
        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("MAKARON_TIMER_TAGS=") {
                let val = String(trimmed.dropFirst("MAKARON_TIMER_TAGS=".count))
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"' "))
                return val.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            }
            if trimmed.hasPrefix("SKETCHYBAR_TIMER_TAGS=") {
                let val = String(trimmed.dropFirst("SKETCHYBAR_TIMER_TAGS=".count))
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"' "))
                return val.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            }
        }
        return ["other"]
    }

    // MARK: - Calendar

    private func fetchCalendar() -> [(time: String, title: String)] {
        let bin = "\(makaronPath)/bin/makaron-calendar-next"
        let out = shell(bin, args: ["--today"])
        var events: [(String, String)] = []
        for line in out.components(separatedBy: "\n") where !line.isEmpty {
            let parts = line.components(separatedBy: "\t")
            guard parts.count >= 3 else { continue }
            let ts = parts[0]
            let allDay = parts[1]
            let title = parts[2]

            if allDay == "1" {
                events.append(("All day", title))
            } else if let epoch = TimeInterval(ts) {
                let date = Date(timeIntervalSince1970: epoch)
                let fmt = DateFormatter()
                fmt.dateFormat = "HH:mm"
                events.append((fmt.string(from: date), title))
            } else {
                events.append(("", title))
            }
        }
        return events
    }

    // MARK: - Todoist

    private func fetchTodoist() -> [(content: String, priority: Int)] {
        let tdBin = findTdBin()
        guard !tdBin.isEmpty else { return [] }
        let out = shell(tdBin, args: ["today", "--json", "--full"])
        guard let data = out.data(using: .utf8) else { return [] }

        var items: [[String: Any]] = []

        if let wrapper = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let results = wrapper["results"] as? [[String: Any]] {
            items = results
        } else if let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            items = arr
        }

        items.sort { a, b in
            let rawA = a["dayOrder"] as? Int ?? 999
            let rawB = b["dayOrder"] as? Int ?? 999
            let da = rawA < 0 ? 999 : rawA
            let db = rawB < 0 ? 999 : rawB
            return da < db
        }

        return items.prefix(10).map { item in
            var content = item["content"] as? String ?? ""
            // Strip markdown links: [text](url) -> text
            while let start = content.range(of: "["), let mid = content.range(of: "](", range: start.upperBound..<content.endIndex),
                  let end = content.range(of: ")", range: mid.upperBound..<content.endIndex) {
                let linkText = String(content[start.upperBound..<mid.lowerBound])
                content.replaceSubrange(start.lowerBound..<end.upperBound, with: linkText)
            }
            let prio = item["priority"] as? Int ?? 1
            return (content, prio)
        }
    }

    private func findTdBin() -> String {
        let candidates = [
            shell("/usr/bin/which", args: ["td"]).trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        for c in candidates where !c.isEmpty && FileManager.default.isExecutableFile(atPath: c) {
            return c
        }

        let home = NSHomeDirectory()
        let globs = [
            "\(home)/.fnm/node-versions",
            "\(home)/Library/Application Support/fnm/node-versions",
            "\(home)/.nvm/versions/node",
        ]
        for base in globs {
            if let dirs = try? FileManager.default.contentsOfDirectory(atPath: base) {
                for dir in dirs {
                    let path = "\(base)/\(dir)/installation/bin/td"
                    let path2 = "\(base)/\(dir)/bin/td"
                    if FileManager.default.isExecutableFile(atPath: path) { return path }
                    if FileManager.default.isExecutableFile(atPath: path2) { return path2 }
                }
            }
        }
        return ""
    }

    // MARK: - Shell helper

    @discardableResult
    private func shell(_ cmd: String, args: [String]) -> String {
        let proc = Process()
        let pipe = Pipe()
        proc.executableURL = URL(fileURLWithPath: cmd.hasPrefix("/") ? cmd : "/usr/bin/env")
        proc.arguments = cmd.hasPrefix("/") ? args : [cmd] + args
        proc.standardOutput = pipe
        proc.standardError = FileHandle.nullDevice
        proc.environment = ProcessInfo.processInfo.environment
        do {
            try proc.run()
            proc.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
}
