import Foundation
import Carbon

enum ItemVisibility: String {
    case menu = "menu"
    case bar = "bar"
    case off = "off"

    var next: ItemVisibility {
        switch self {
        case .menu: return .bar
        case .bar: return .off
        case .off: return .menu
        }
    }

    var label: String {
        switch self {
        case .menu: return "Menu"
        case .bar: return "Top Bar"
        case .off: return "Off"
        }
    }
}

enum BarItem: String, CaseIterable {
    case battery = "MAKARONBAR_BATTERY"
    case cpu = "MAKARONBAR_CPU"
    case memory = "MAKARONBAR_MEMORY"
    case storage = "MAKARONBAR_STORAGE"
    case wifi = "MAKARONBAR_WIFI"
    case timer = "MAKARONBAR_TIMER"
    case calendar = "MAKARONBAR_CALENDAR"
    case todoist = "MAKARONBAR_TODOIST"
    case datetime = "MAKARONBAR_DATETIME"

    var displayName: String {
        switch self {
        case .battery: return "Battery"
        case .cpu: return "CPU"
        case .memory: return "Memory"
        case .storage: return "Storage"
        case .wifi: return "WiFi"
        case .timer: return "Timer"
        case .calendar: return "Calendar"
        case .todoist: return "Todoist"
        case .datetime: return "Date & Time"
        }
    }

    var defaultVisibility: ItemVisibility {
        switch self {
        case .battery, .cpu, .memory: return .menu
        case .storage, .wifi: return .menu
        case .timer, .calendar, .todoist: return .menu
        case .datetime: return .menu
        }
    }
}

enum WorkspaceDisplayMode: String {
    case all = "all"
    case focused = "focused"
    case current = "current"

    var label: String {
        switch self {
        case .all: return "All"
        case .focused: return "Active Only"
        case .current: return "Current Only"
        }
    }
}

class BarConfig {
    static let shared = BarConfig()

    private var items: [BarItem: ItemVisibility] = [:]
    private(set) var workspaceDisplay: WorkspaceDisplayMode = .all
    private(set) var selectedCalendars: Set<String> = []
    private let confPath: String

    private init() {
        let home = NSHomeDirectory()
        confPath = "\(home)/.config/makaron/makaron.conf"
        load()
    }

    func visibility(for item: BarItem) -> ItemVisibility {
        items[item] ?? item.defaultVisibility
    }

    func setVisibility(_ vis: ItemVisibility, for item: BarItem) {
        items[item] = vis
        save()
    }

    func cycle(_ item: BarItem) {
        let current = visibility(for: item)
        setVisibility(current.next, for: item)
    }

    func setWorkspaceDisplay(_ mode: WorkspaceDisplayMode) {
        workspaceDisplay = mode
        save()
    }

    func setSelectedCalendars(_ ids: Set<String>) {
        selectedCalendars = ids
        save()
    }

    func itemsVisible(in mode: ItemVisibility) -> [BarItem] {
        BarItem.allCases.filter { visibility(for: $0) == mode }
    }

    func readHotkeyString() -> String {
        guard let content = try? String(contentsOfFile: confPath, encoding: .utf8) else {
            return "option+m"
        }
        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("MAKARONBAR_HOTKEY=") else { continue }
            return String(trimmed.dropFirst("MAKARONBAR_HOTKEY=".count)).trimmingCharacters(in: .whitespaces)
        }
        return "option+m"
    }

    func writeHotkeyString(_ value: String) {
        guard var content = try? String(contentsOfFile: confPath, encoding: .utf8) else { return }
        let key = "MAKARONBAR_HOTKEY"
        let newLine = "\(key)=\(value)"
        if let range = content.range(of: "(?m)^\(key)=.*$", options: .regularExpression) {
            content.replaceSubrange(range, with: newLine)
        } else {
            if !content.hasSuffix("\n") { content += "\n" }
            content += "\(newLine)\n"
        }
        try? content.write(toFile: confPath, atomically: true, encoding: .utf8)
    }

    // Returns (keyCode, carbonModifiers). Default: ⌥M
    func readHotKey() -> (UInt32, UInt32) {
        guard let content = try? String(contentsOfFile: confPath, encoding: .utf8) else {
            return (46, UInt32(optionKey))
        }
        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("MAKARONBAR_HOTKEY=") else { continue }
            let val = String(trimmed.dropFirst("MAKARONBAR_HOTKEY=".count)).trimmingCharacters(in: .whitespaces)
            return parseHotKey(val)
        }
        return (46, UInt32(optionKey))
    }

    private func parseHotKey(_ str: String) -> (UInt32, UInt32) {
        let parts = str.lowercased().split(separator: "+").map { $0.trimmingCharacters(in: .whitespaces) }
        var mods: UInt32 = 0
        var key: String = ""
        for p in parts {
            switch p {
            case "option", "opt", "alt", "⌥": mods |= UInt32(optionKey)
            case "ctrl", "control", "⌃": mods |= UInt32(controlKey)
            case "cmd", "command", "⌘": mods |= UInt32(cmdKey)
            case "shift", "⇧": mods |= UInt32(shiftKey)
            default: key = p
            }
        }
        let code = keyCodeFor(key)
        return (code, mods)
    }

    private func keyCodeFor(_ key: String) -> UInt32 {
        let map: [String: UInt32] = [
            "a": 0, "b": 11, "c": 8, "d": 2, "e": 14, "f": 3, "g": 5, "h": 4,
            "i": 34, "j": 38, "k": 40, "l": 37, "m": 46, "n": 45, "o": 31, "p": 35,
            "q": 12, "r": 15, "s": 1, "t": 17, "u": 32, "v": 9, "w": 13, "x": 7,
            "y": 16, "z": 6, "space": 49, "tab": 48, "escape": 53, "esc": 53,
            "1": 18, "2": 19, "3": 20, "4": 21, "5": 23, "6": 22, "7": 26, "8": 28,
            "9": 25, "0": 29, "f1": 122, "f2": 120, "f3": 99, "f4": 118,
        ]
        return map[key] ?? 46
    }

    private func load() {
        guard let content = try? String(contentsOfFile: confPath, encoding: .utf8) else { return }
        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.hasPrefix("#"), trimmed.contains("=") else { continue }
            let parts = trimmed.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else { continue }
            let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
            let val = String(parts[1]).trimmingCharacters(in: .whitespaces)
            if key == "MAKARONBAR_WORKSPACE_DISPLAY" {
                workspaceDisplay = WorkspaceDisplayMode(rawValue: val) ?? .all
            } else if key == "MAKARONBAR_CALENDARS" {
                let ids = val.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                    .split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                selectedCalendars = Set(ids)
            } else if let item = BarItem(rawValue: key), let vis = ItemVisibility(rawValue: val) {
                items[item] = vis
            }
        }
    }

    private func save() {
        guard var content = try? String(contentsOfFile: confPath, encoding: .utf8) else { return }

        for item in BarItem.allCases {
            let vis = visibility(for: item)
            let key = item.rawValue
            let newLine = "\(key)=\(vis.rawValue)"

            if let range = content.range(of: "(?m)^\(key)=.*$", options: .regularExpression) {
                content.replaceSubrange(range, with: newLine)
            } else {
                if !content.hasSuffix("\n") { content += "\n" }
                content += "\(newLine)\n"
            }
        }

        let wsKey = "MAKARONBAR_WORKSPACE_DISPLAY"
        let wsLine = "\(wsKey)=\(workspaceDisplay.rawValue)"
        if let range = content.range(of: "(?m)^\(wsKey)=.*$", options: .regularExpression) {
            content.replaceSubrange(range, with: wsLine)
        } else {
            if !content.hasSuffix("\n") { content += "\n" }
            content += "\(wsLine)\n"
        }

        let calKey = "MAKARONBAR_CALENDARS"
        let calLine = "\(calKey)=\(selectedCalendars.sorted().joined(separator: ","))"
        if let range = content.range(of: "(?m)^\(calKey)=.*$", options: .regularExpression) {
            content.replaceSubrange(range, with: calLine)
        } else {
            if !content.hasSuffix("\n") { content += "\n" }
            content += "\(calLine)\n"
        }

        try? content.write(toFile: confPath, atomically: true, encoding: .utf8)
    }
}
