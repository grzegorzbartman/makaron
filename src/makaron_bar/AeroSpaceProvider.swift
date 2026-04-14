import Foundation

struct Workspace {
    let id: String
    var isFocused: Bool
    var apps: [String]
}

enum AeroSpaceProvider {
    static func shell(_ command: String, args: [String] = []) -> String {
        let proc = Process()
        let pipe = Pipe()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        proc.arguments = [command] + args
        proc.standardOutput = pipe
        proc.standardError = FileHandle.nullDevice
        do {
            try proc.run()
            proc.waitUntilExit()
        } catch {
            return ""
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    static func fetchFocusedWorkspace() -> String {
        let stateFile = "/tmp/makaron_focused_ws"
        if let content = try? String(contentsOfFile: stateFile, encoding: .utf8) {
            let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { return trimmed }
        }
        return shell("aerospace", args: ["list-workspaces", "--focused"])
    }

    static func fetchAllWorkspaces() -> [Workspace] {
        let focused = fetchFocusedWorkspace()
        let allWS = shell("aerospace", args: ["list-workspaces", "--all"])
        guard !allWS.isEmpty else { return [] }

        var workspaces: [Workspace] = []
        for wsId in allWS.split(separator: "\n").map({ String($0).trimmingCharacters(in: .whitespaces) }) {
            guard !wsId.isEmpty else { continue }
            let windowsRaw = shell("aerospace", args: ["list-windows", "--workspace", wsId])
            var apps: [String] = []
            for line in windowsRaw.split(separator: "\n") {
                let parts = String(line).split(separator: "|", maxSplits: 2)
                if parts.count >= 2 {
                    let app = String(parts[1]).trimmingCharacters(in: .whitespaces)
                    if !app.isEmpty && !apps.contains(app) {
                        apps.append(app)
                    }
                }
            }
            workspaces.append(Workspace(
                id: wsId,
                isFocused: wsId == focused,
                apps: apps
            ))
        }
        return workspaces
    }

    static func switchToWorkspace(_ wsId: String) {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        proc.arguments = ["aerospace", "workspace", wsId]
        proc.standardOutput = FileHandle.nullDevice
        proc.standardError = FileHandle.nullDevice
        try? proc.run()
    }
}
