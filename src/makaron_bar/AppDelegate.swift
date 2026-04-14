import AppKit
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var stripView: WorkspaceStripView!
    private var theme: MakaronTheme = .default
    private var workspaces: [Workspace] = []
    private var refreshTimer: Timer?
    private var barLabelTimer: Timer?
    private var lastFocused: String = ""
    private let sysInfo = SystemInfoProvider.shared
    private let config = BarConfig.shared
    private var hotKeyRef: EventHotKeyRef?
    private let optionsWindow = OptionsWindowController()
    private let dashboard = DashboardPanel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        refreshWorkspacesSync()
        setupTimer()
        sysInfo.start()
        setupHotKey()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        stripView = WorkspaceStripView()
        stripView.onWorkspaceClick = { [weak self] wsId in
            AeroSpaceProvider.switchToWorkspace(wsId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self?.refreshWorkspacesSync()
            }
        }
        stripView.onMenuClick = { [weak self] in
            self?.showDashboard()
        }

        if let button = statusItem.button {
            stripView.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(stripView)
            NSLayoutConstraint.activate([
                stripView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                stripView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
                stripView.topAnchor.constraint(equalTo: button.topAnchor),
                stripView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            ])
        }
    }

    // MARK: - Bar Labels

    private func buildBarLabels() -> [BarLabel] {
        let info = sysInfo.getCached()
        var labels: [BarLabel] = []

        for item in config.itemsVisible(in: .bar) {
            switch item {
            case .battery:
                if !info.battery.isEmpty { labels.append(BarLabel(text: info.battery, highlight: info.batteryPercent <= 20)) }
            case .cpu:
                if !info.cpu.isEmpty { labels.append(BarLabel(text: info.cpu, highlight: false)) }
            case .memory:
                if !info.memory.isEmpty { labels.append(BarLabel(text: info.memory, highlight: false)) }
            case .storage:
                if !info.storage.isEmpty { labels.append(BarLabel(text: info.storage, highlight: false)) }
            case .wifi:
                if !info.wifi.isEmpty { labels.append(BarLabel(text: info.wifi, highlight: false)) }
            case .timer:
                if info.timerAvailable && info.timerActive {
                    let txt = info.timerDetail.isEmpty ? info.timerDuration : "\(info.timerDuration) \(info.timerDetail)"
                    labels.append(BarLabel(text: txt, highlight: true))
                } else if info.timerAvailable {
                    labels.append(BarLabel(text: "timer", highlight: false))
                }
            case .calendar:
                if let first = info.calendarEvents.first {
                    let txt = first.time.isEmpty ? String(first.title.prefix(20)) : "\(first.time) \(String(first.title.prefix(15)))"
                    labels.append(BarLabel(text: txt, highlight: false))
                }
            case .todoist:
                if let first = info.todoistTasks.first {
                    labels.append(BarLabel(text: String(first.content.prefix(20)), highlight: false))
                }
            case .datetime:
                let fmt = DateFormatter()
                fmt.dateFormat = "HH:mm"
                labels.append(BarLabel(text: fmt.string(from: Date()), highlight: false))
            }
        }
        return labels
    }

    // MARK: - Dashboard Panel

    func showDashboard() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.sysInfo.refreshAll()
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.dashboard.updateContent(info: self.sysInfo.getCached(), workspaces: self.workspaces, config: self.config)
            }
        }

        dashboard.onWorkspaceClick = { [weak self] wsId in
            AeroSpaceProvider.switchToWorkspace(wsId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self?.refreshWorkspacesSync()
            }
        }
        dashboard.onAction = { [weak self] action in
            self?.handleDashboardAction(action)
        }

        dashboard.toggle(relativeTo: statusItem, info: sysInfo.getCached(), workspaces: workspaces, config: config)
    }

    private func handleDashboardAction(_ action: String) {
        let makaronPath = ProcessInfo.processInfo.environment["MAKARON_PATH"]
            ?? "\(NSHomeDirectory())/.local/share/makaron"
        switch action {
        case "stop-timer":
            _ = AeroSpaceProvider.shell("\(makaronPath)/bin/makaron-timer", args: ["stop"])
        case _ where action.hasPrefix("start-timer:"):
            let tag = String(action.dropFirst("start-timer:".count))
            _ = AeroSpaceProvider.shell("\(makaronPath)/bin/makaron-timer", args: ["start", tag])
        case "open-calendar":
            NSWorkspace.shared.open(URL(string: "ical://")!)
        case "open-todoist":
            if let url = URL(string: "https://app.todoist.com/app/today") { NSWorkspace.shared.open(url) }
        case "new-note":
            let script = "\(makaronPath)/bin/makaron-tools"
            DispatchQueue.global(qos: .userInitiated).async {
                _ = AeroSpaceProvider.shell(script, args: ["--action", "new-note"])
            }
        case "options":
            optionsWindow.onChanged = { [weak self] in self?.updateStrip() }
            optionsWindow.show()
        case "reload":
            _ = AeroSpaceProvider.shell("aerospace", args: ["reload-config"])
            refreshWorkspacesSync()
        case "open-github":
            if let url = URL(string: "https://github.com/grzegorzbartman/makaron") { NSWorkspace.shared.open(url) }
        case "quit":
            NSApp.terminate(nil)
        default: break
        }
    }


    // MARK: - Global Hotkey

    private func setupHotKey() {
        let (keyCode, modifiers) = BarConfig.shared.readHotKey()

        let signature = OSType(0x4D4B524E) // "MKRN"
        let hotKeyID = EventHotKeyID(signature: signature, id: 1)

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handler: EventHandlerUPP = { _, event, _ -> OSStatus in
            guard let event = event else { return OSStatus(eventNotHandledErr) }
            var hkID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID), nil,
                              MemoryLayout<EventHotKeyID>.size, nil, &hkID)
            if hkID.id == 1 {
                DispatchQueue.main.async {
                    guard let del = NSApp.delegate as? AppDelegate else { return }
                    del.showDashboard()
                }
            }
            return noErr
        }

        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventType, nil, nil)
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    // MARK: - Workspace Polling

    private func setupTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            self?.checkForFocusChange()
        }
        barLabelTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.updateStrip()
        }
    }

    private func checkForFocusChange() {
        let focused = AeroSpaceProvider.fetchFocusedWorkspace()
        if focused != lastFocused {
            lastFocused = focused
            // Instant visual: swap focus marker without CLI calls
            for i in workspaces.indices {
                workspaces[i].isFocused = (workspaces[i].id == focused)
            }
            updateStrip()
            // Full refresh (app lists etc.) in background
            refreshWorkspacesAsync()
        }
    }

    private func refreshWorkspacesSync() {
        workspaces = AeroSpaceProvider.fetchAllWorkspaces()
        lastFocused = workspaces.first(where: { $0.isFocused })?.id ?? ""
        updateStrip()
    }

    private func refreshWorkspacesAsync() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let ws = AeroSpaceProvider.fetchAllWorkspaces()
            DispatchQueue.main.async {
                self?.workspaces = ws
                self?.lastFocused = ws.first(where: { $0.isFocused })?.id ?? ""
                self?.updateStrip()
            }
        }
    }

    private func updateStrip() {
        let labels = buildBarLabels()
        let visibleWS: [Workspace]
        switch config.workspaceDisplay {
        case .focused:
            visibleWS = workspaces.filter { $0.isFocused || !$0.apps.isEmpty }
        case .current:
            visibleWS = workspaces.filter { $0.isFocused }
        case .all:
            visibleWS = workspaces
        }
        stripView.update(workspaces: visibleWS, theme: theme, barLabels: labels)
        let newWidth = stripView.intrinsicContentSize.width
        statusItem.length = newWidth
    }

    func applicationWillTerminate(_ notification: Notification) {
        sysInfo.stop()
        refreshTimer?.invalidate()
        barLabelTimer?.invalidate()
    }
}
