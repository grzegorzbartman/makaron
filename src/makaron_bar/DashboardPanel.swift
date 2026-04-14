import AppKit

class KeyPanel: NSPanel {
    var onKeyDown: ((UInt16) -> Bool)?

    override var canBecomeKey: Bool { true }

    override func keyDown(with event: NSEvent) {
        if onKeyDown?(event.keyCode) == true { return }
        super.keyDown(with: event)
    }
}

class DashboardPanel {
    private var panel: KeyPanel?
    private var eventMonitor: Any?
    private weak var lastStatusItem: NSStatusItem?
    var onWorkspaceClick: ((String) -> Void)?
    var onAction: ((String) -> Void)?

    private var colButtons: [[HoverButton]] = [[], [], []]
    private var focusCol: Int = 0
    private var focusRow: Int = -1

    var isVisible: Bool { panel?.isVisible ?? false }

    func toggle(relativeTo statusItem: NSStatusItem, info: SystemInfo, workspaces: [Workspace], config: BarConfig) {
        if let p = panel, p.isVisible {
            close()
            return
        }
        show(relativeTo: statusItem, info: info, workspaces: workspaces, config: config)
    }

    func close() {
        panel?.orderOut(nil)
        if let m = eventMonitor { NSEvent.removeMonitor(m); eventMonitor = nil }
        colButtons = [[], [], []]
        focusCol = 0
        focusRow = -1
    }

    func updateContent(info: SystemInfo, workspaces: [Workspace], config: BarConfig) {
        guard let p = panel, p.isVisible, let statusItem = lastStatusItem else { return }
        let frame = p.frame
        close()
        show(relativeTo: statusItem, info: info, workspaces: workspaces, config: config)
        panel?.setFrame(frame, display: true)
    }

    private func show(relativeTo statusItem: NSStatusItem, info: SystemInfo, workspaces: [Workspace], config: BarConfig) {
        lastStatusItem = statusItem
        colButtons = [[], [], []]
        focusCol = 0
        focusRow = -1

        let colWidth: CGFloat = 220
        let padding: CGFloat = 14
        let spacing: CGFloat = 4

        let col1 = buildCol1(workspaces: workspaces, info: info, config: config)
        let col2 = buildCol2(info: info, config: config)
        let col3 = buildCol3(info: info, config: config)

        let h1 = columnHeight(col1, spacing: spacing) + padding * 2
        let h2 = columnHeight(col2, spacing: spacing) + padding * 2
        let h3 = columnHeight(col3, spacing: spacing) + padding * 2
        let panelHeight = max(h1, max(h2, h3))
        let panelWidth = colWidth * 3 + padding * 4

        let p = KeyPanel(
            contentRect: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        p.titleVisibility = .hidden
        p.titlebarAppearsTransparent = true
        p.isMovableByWindowBackground = false
        p.level = .popUpMenu
        p.isFloatingPanel = true
        p.hasShadow = true
        p.isOpaque = false
        p.backgroundColor = .clear
        p.isReleasedWhenClosed = false

        p.onKeyDown = { [weak self] keyCode in
            self?.handleKey(keyCode) ?? false
        }

        let bg = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight))
        bg.material = .popover
        bg.state = .active
        bg.blendingMode = .behindWindow
        bg.wantsLayer = true
        bg.layer?.cornerRadius = 10
        bg.layer?.masksToBounds = true
        p.contentView = bg

        let x1 = padding
        let x2 = colWidth + padding * 2
        let x3 = colWidth * 2 + padding * 3

        bg.addSubview(buildColumnView(col1, x: x1, height: panelHeight, spacing: spacing, padding: padding, column: 0))

        let sep1 = NSBox(frame: NSRect(x: x2 - padding / 2, y: padding, width: 1, height: panelHeight - padding * 2))
        sep1.boxType = .separator
        bg.addSubview(sep1)

        bg.addSubview(buildColumnView(col2, x: x2, height: panelHeight, spacing: spacing, padding: padding, column: 1))

        let sep2 = NSBox(frame: NSRect(x: x3 - padding / 2, y: padding, width: 1, height: panelHeight - padding * 2))
        sep2.boxType = .separator
        bg.addSubview(sep2)

        bg.addSubview(buildColumnView(col3, x: x3, height: panelHeight, spacing: spacing, padding: padding, column: 2))

        positionPanel(p, relativeTo: statusItem)
        p.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        panel = p

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, let panel = self.panel, panel.isVisible else { return }
            if !NSMouseInRect(NSEvent.mouseLocation, panel.frame, false) {
                self.close()
            }
        }
    }

    // MARK: - Keyboard

    private func handleKey(_ keyCode: UInt16) -> Bool {
        switch keyCode {
        case 125: moveFocus(0, 1); return true
        case 126: moveFocus(0, -1); return true
        case 124: moveFocus(1, 0); return true
        case 123: moveFocus(-1, 0); return true
        case 36, 76: activateFocused(); return true
        case 53: close(); return true
        case 48: moveFocus(0, 1); return true
        default: return false
        }
    }

    private func currentButtons() -> [HoverButton] { colButtons[focusCol] }

    private func moveFocus(_ dx: Int, _ dy: Int) {
        clearFocusHighlight()
        if dx != 0 {
            let newCol = (focusCol + dx + 3) % 3
            focusCol = colButtons[newCol].isEmpty ? focusCol : newCol
            focusRow = min(focusRow, currentButtons().count - 1)
            if focusRow < 0 { focusRow = 0 }
        }
        if dy != 0 {
            let btns = currentButtons()
            guard !btns.isEmpty else { return }
            focusRow += dy
            if focusRow < 0 { focusRow = btns.count - 1 }
            if focusRow >= btns.count { focusRow = 0 }
        }
        if focusRow < 0 { focusRow = 0 }
        showFocusHighlight()
    }

    private func activateFocused() {
        let btns = currentButtons()
        guard focusRow >= 0, focusRow < btns.count else { return }
        btns[focusRow].performClick(nil)
    }

    private func clearFocusHighlight() {
        let btns = currentButtons()
        if focusRow >= 0, focusRow < btns.count {
            btns[focusRow].layer?.backgroundColor = nil
        }
    }

    private func showFocusHighlight() {
        let btns = currentButtons()
        if focusRow >= 0, focusRow < btns.count {
            btns[focusRow].layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.1).cgColor
        }
    }

    private func positionPanel(_ panel: NSPanel, relativeTo statusItem: NSStatusItem) {
        guard let button = statusItem.button, let bw = button.window else { panel.center(); return }
        let btnRect = bw.convertToScreen(button.convert(button.bounds, to: nil))
        var x = btnRect.midX - panel.frame.width / 2
        let y = btnRect.minY - panel.frame.height - 4
        if let screen = NSScreen.main {
            let maxX = screen.visibleFrame.maxX - panel.frame.width - 4
            if x > maxX { x = maxX }
            if x < screen.visibleFrame.minX + 4 { x = screen.visibleFrame.minX + 4 }
        }
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    // MARK: - Row model

    private enum Row {
        case header(String)
        case section(String)
        case info(String, NSFont, NSColor)
        case button(String, NSFont, NSColor, String)
        case separator
        case workspace(Workspace)
    }

    private func columnHeight(_ rows: [Row], spacing: CGFloat) -> CGFloat {
        var h: CGFloat = 0
        for row in rows {
            switch row {
            case .header: h += 22
            case .section: h += 20
            case .info: h += 18
            case .button: h += 22
            case .separator: h += 8
            case .workspace: h += 20
            }
            h += spacing
        }
        return h
    }

    // MARK: - Column 1: AeroSpace + System

    private func buildCol1(workspaces: [Workspace], info: SystemInfo, config: BarConfig) -> [Row] {
        var rows: [Row] = []

        rows.append(.section("AEROSPACE WORKSPACES"))
        for ws in workspaces {
            rows.append(.workspace(ws))
        }

        return rows
    }

    // MARK: - Column 2: Timer + Todoist + Calendar

    private func buildCol2(info: SystemInfo, config: BarConfig) -> [Row] {
        let small = NSFont.systemFont(ofSize: 11, weight: .regular)
        let smallBold = NSFont.systemFont(ofSize: 11, weight: .medium)
        let tiny = NSFont.systemFont(ofSize: 10, weight: .regular)
        let label = NSColor.labelColor
        let dim = NSColor.secondaryLabelColor
        let faint = NSColor.tertiaryLabelColor

        var rows: [Row] = []

        if config.visibility(for: .todoist) != .off && !info.todoistTasks.isEmpty {
            rows.append(.section("TODOIST"))
            for task in info.todoistTasks.prefix(8) {
                let icon = priorityIcon(task.priority)
                rows.append(.info("\(icon) \(String(task.content.prefix(26)))", small, label))
            }
            rows.append(.button("Open Todoist", small, NSColor.systemBlue, "open-todoist"))
            rows.append(.separator)
        }

        if config.visibility(for: .calendar) != .off {
            rows.append(.section("CALENDAR"))
            if info.calendarEvents.isEmpty {
                rows.append(.info("No events today", small, dim))
            } else {
                for event in info.calendarEvents.prefix(5) {
                    let time = event.time.isEmpty ? "" : "\(event.time)  "
                    rows.append(.info("\(time)\(String(event.title.prefix(24)))", small, label))
                }
            }
            rows.append(.button("Open Calendar", small, NSColor.systemBlue, "open-calendar"))
            rows.append(.separator)
        }

        if config.visibility(for: .timer) != .off && info.timerAvailable {
            rows.append(.section("TIMER"))
            if info.timerActive {
                let detail = info.timerDetail.isEmpty ? "" : " — \(info.timerDetail)"
                rows.append(.info("⏱ \(info.timerDuration)\(detail)", smallBold, label))
                rows.append(.button("⏹ Stop timer", small, label, "stop-timer"))
            } else {
                rows.append(.info("⏱ Not tracking", small, dim))
                for tag in info.timerTags {
                    rows.append(.button("▶  \(tag)", small, label, "start-timer:\(tag)"))
                }
            }

            if !info.timerTodayTotal.isEmpty {
                rows.append(.info("Today: \(info.timerTodayTotal)", tiny, dim))
            }

            if !info.timerRecent.isEmpty {
                rows.append(.separator)
                rows.append(.info("Recent", tiny, dim))
                for entry in info.timerRecent {
                    let day = entry.day == "Today" || entry.day.isEmpty ? "" : "  \(entry.day)"
                    rows.append(.info("\(entry.duration)  \(entry.title)\(day)", tiny, label))
                }
            }

            rows.append(.separator)
            rows.append(.info("timew summary today", tiny, faint))
            rows.append(.info("timew summary :week", tiny, faint))
        }

        return rows
    }

    // MARK: - Column 3: Rest

    private func buildCol3(info: SystemInfo, config: BarConfig) -> [Row] {
        let mono = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        let small = NSFont.systemFont(ofSize: 11, weight: .regular)
        let label = NSColor.labelColor
        let dim = NSColor.secondaryLabelColor
        let tiny = NSFont.systemFont(ofSize: 10, weight: .regular)
        let faint = NSColor.tertiaryLabelColor

        var rows: [Row] = []

        rows.append(.header("◆ Makaron"))
        if config.visibility(for: .datetime) != .off {
            let fmt = DateFormatter()
            fmt.dateFormat = "EEEE | yyyy-MM-dd | HH:mm"
            rows.append(.info(fmt.string(from: Date()), mono, dim))
        }
        rows.append(.separator)

        let systemItems: [(BarItem, String, String)] = [
            (.battery, info.batteryCharging ? "⚡" : "🔋", "Battery    \(info.battery)"),
            (.cpu, "💻", "CPU         \(info.cpu)"),
            (.memory, "🧠", "Memory   \(info.memory)"),
            (.storage, "💾", "Storage    \(info.storage)"),
            (.wifi, "📶", "WiFi         \(info.wifi)"),
        ]

        var hasSystem = false
        for (item, icon, text) in systemItems {
            if config.visibility(for: item) != .off {
                if !hasSystem { rows.append(.section("SYSTEM")); hasSystem = true }
                rows.append(.info("\(icon)  \(text)", mono, label))
            }
        }
        if hasSystem { rows.append(.separator) }

        rows.append(.section("QUICK ACTIONS"))
        rows.append(.button("📝  New Apple Note", small, label, "new-note"))
        rows.append(.separator)

        rows.append(.button("Options…", small, dim, "options"))
        rows.append(.button("Reload AeroSpace", small, dim, "reload"))
        rows.append(.button("Quit MakaronBar", small, dim, "quit"))
        rows.append(.separator)

        rows.append(.info("Makaron by Grzegorz Bartman", tiny, faint))
        rows.append(.button("github.com/grzegorzbartman/makaron", tiny, faint, "open-github"))

        return rows
    }

    private func priorityIcon(_ prio: Int) -> String {
        switch prio {
        case 4: return "🔴"
        case 3: return "🟠"
        case 2: return "🔵"
        default: return "  "
        }
    }

    // MARK: - Build views

    private func buildColumnView(_ rows: [Row], x: CGFloat, height: CGFloat, spacing: CGFloat, padding: CGFloat, column: Int) -> NSView {
        let colWidth: CGFloat = 200
        let container = NSView(frame: NSRect(x: x, y: 0, width: colWidth, height: height))
        var y = height - padding

        for row in rows {
            switch row {
            case .header(let text):
                let lbl = makeLabel(text, font: .systemFont(ofSize: 13, weight: .bold), color: .labelColor)
                lbl.frame = NSRect(x: 0, y: y - 18, width: colWidth, height: 18)
                container.addSubview(lbl)
                y -= 22

            case .section(let text):
                let lbl = makeLabel(text, font: .systemFont(ofSize: 10, weight: .bold), color: .secondaryLabelColor)
                lbl.attributedStringValue = NSAttributedString(string: text, attributes: [
                    .font: NSFont.systemFont(ofSize: 10, weight: .bold),
                    .foregroundColor: NSColor.secondaryLabelColor,
                    .kern: 1.2,
                ])
                lbl.frame = NSRect(x: 0, y: y - 16, width: colWidth, height: 16)
                container.addSubview(lbl)
                y -= 20

            case .info(let text, let font, let color):
                let lbl = makeLabel(text, font: font, color: color)
                lbl.frame = NSRect(x: 4, y: y - 16, width: colWidth - 4, height: 16)
                container.addSubview(lbl)
                y -= 18

            case .button(let text, let font, let color, let action):
                let btn = HoverButton(frame: NSRect(x: 0, y: y - 20, width: colWidth, height: 20))
                btn.title = ""
                btn.isBordered = false
                btn.attributedTitle = NSAttributedString(string: "  \(text)", attributes: [.font: font, .foregroundColor: color])
                btn.alignment = .left
                btn.target = self
                btn.action = #selector(panelButtonClicked(_:))
                btn.identifier = NSUserInterfaceItemIdentifier(action)
                btn.wantsLayer = true
                btn.layer?.cornerRadius = 4
                container.addSubview(btn)
                colButtons[column].append(btn)
                y -= 22

            case .separator:
                y -= 8

            case .workspace(let ws):
                let btn = HoverButton(frame: NSRect(x: 0, y: y - 18, width: colWidth, height: 18))
                btn.isBordered = false
                let prefix = ws.isFocused ? "●  " : "    "
                let apps = ws.apps.isEmpty ? "(empty)" : ws.apps.prefix(2).joined(separator: ", ")
                let wsFont = ws.isFocused ? NSFont.systemFont(ofSize: 11, weight: .semibold) : NSFont.systemFont(ofSize: 11, weight: .regular)
                let wsColor: NSColor = ws.apps.isEmpty && !ws.isFocused ? .secondaryLabelColor : .labelColor
                btn.attributedTitle = NSAttributedString(
                    string: "\(prefix)\(ws.id) — \(apps)",
                    attributes: [.font: wsFont, .foregroundColor: wsColor]
                )
                btn.alignment = .left
                btn.target = self
                btn.action = #selector(workspaceClicked(_:))
                btn.identifier = NSUserInterfaceItemIdentifier(ws.id)
                btn.wantsLayer = true
                btn.layer?.cornerRadius = 4
                container.addSubview(btn)
                colButtons[column].append(btn)
                y -= 20
            }
            y -= spacing
        }

        return container
    }

    private func makeLabel(_ text: String, font: NSFont, color: NSColor) -> NSTextField {
        let lbl = NSTextField(labelWithString: text)
        lbl.font = font
        lbl.textColor = color
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }

    // MARK: - Actions

    @objc private func panelButtonClicked(_ sender: NSButton) {
        let action = sender.identifier?.rawValue ?? ""
        close()
        onAction?(action)
    }

    @objc private func workspaceClicked(_ sender: NSButton) {
        let wsId = sender.identifier?.rawValue ?? ""
        close()
        onWorkspaceClick?(wsId)
    }
}

// MARK: - Hover button

class HoverButton: NSButton {
    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let ta = trackingArea { removeTrackingArea(ta) }
        trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self)
        addTrackingArea(trackingArea!)
    }

    override func mouseEntered(with event: NSEvent) {
        layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.08).cgColor
    }

    override func mouseExited(with event: NSEvent) {
        layer?.backgroundColor = nil
    }
}
