import AppKit
import Carbon
import EventKit

class OptionsWindowController {
    private var window: NSPanel?
    private var segments: [BarItem: NSSegmentedControl] = [:]
    private var calendarCheckboxes: [NSButton] = []
    private let config = BarConfig.shared
    private var hotkeyField: HotkeyField?
    var onChanged: (() -> Void)?
    var onHotkeyChanged: (() -> Void)?

    func show() {
        if let w = window, w.isVisible {
            w.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 0),
            styleMask: [.titled, .closable, .nonactivatingPanel, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        panel.title = "MakaronBar Options"
        panel.isFloatingPanel = true
        panel.becomesKeyOnlyIfNeeded = false
        panel.level = .floating
        panel.isReleasedWhenClosed = false

        calendarCheckboxes = []
        let contentView = NSView()
        let padding: CGFloat = 16
        let rowHeight: CGFloat = 32
        let labelWidth: CGFloat = 100
        let segWidth: CGFloat = 200
        var y: CGFloat = padding

        // Hotkey recorder
        let hkLabel = NSTextField(labelWithString: "Hotkey")
        hkLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        hkLabel.frame = NSRect(x: padding, y: y + 5, width: labelWidth, height: 20)
        contentView.addSubview(hkLabel)

        let field = HotkeyField(frame: NSRect(x: padding + labelWidth, y: y + 2, width: segWidth, height: 26))
        field.currentHotkey = config.readHotkeyString()
        field.onChanged = { [weak self] newValue in
            self?.config.writeHotkeyString(newValue)
            self?.onHotkeyChanged?()
        }
        contentView.addSubview(field)
        hotkeyField = field
        y += rowHeight

        let hint = NSTextField(labelWithString: "Click the field, then press your shortcut. Restart to apply.")
        hint.font = NSFont.systemFont(ofSize: 10, weight: .regular)
        hint.textColor = .secondaryLabelColor
        hint.frame = NSRect(x: padding, y: y, width: 310, height: 14)
        contentView.addSubview(hint)
        y += 22

        // Separator
        let sep = NSBox(frame: NSRect(x: padding, y: y, width: 308, height: 1))
        sep.boxType = .separator
        contentView.addSubview(sep)
        y += 12

        // Workspace display mode
        let wsLabel = NSTextField(labelWithString: "Workspaces")
        wsLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        wsLabel.frame = NSRect(x: padding, y: y + 5, width: labelWidth, height: 20)
        contentView.addSubview(wsLabel)

        let wsSeg = NSSegmentedControl(labels: ["All", "Active Only", "Current Only"], trackingMode: .selectOne, target: self, action: #selector(workspaceDisplayChanged(_:)))
        wsSeg.segmentStyle = .rounded
        wsSeg.frame = NSRect(x: padding + labelWidth, y: y + 2, width: segWidth, height: 26)
        switch config.workspaceDisplay {
        case .all: wsSeg.selectedSegment = 0
        case .focused: wsSeg.selectedSegment = 1
        case .current: wsSeg.selectedSegment = 2
        }
        contentView.addSubview(wsSeg)
        y += rowHeight

        let sep2 = NSBox(frame: NSRect(x: padding, y: y, width: 308, height: 1))
        sep2.boxType = .separator
        contentView.addSubview(sep2)
        y += 12

        // Item visibility controls
        let items = BarItem.allCases.reversed()

        for item in items {
            let label = NSTextField(labelWithString: item.displayName)
            label.font = NSFont.systemFont(ofSize: 13, weight: .medium)
            label.frame = NSRect(x: padding, y: y + 5, width: labelWidth, height: 20)
            contentView.addSubview(label)

            let seg = NSSegmentedControl(labels: ["Off", "Menu", "Top Bar"], trackingMode: .selectOne, target: self, action: #selector(segmentChanged(_:)))
            seg.segmentStyle = .rounded
            seg.frame = NSRect(x: padding + labelWidth, y: y + 2, width: segWidth, height: 26)
            seg.tag = item.hashValue

            switch config.visibility(for: item) {
            case .off: seg.selectedSegment = 0
            case .menu: seg.selectedSegment = 1
            case .bar: seg.selectedSegment = 2
            }

            segments[item] = seg
            contentView.addSubview(seg)

            y += rowHeight

            if item == .calendar {
                let calAccess = checkCalendarAccess()
                if !calAccess {
                    let calHint = NSTextField(wrappingLabelWithString: "⚠ No calendar access — grant in System Settings → Privacy & Security → Calendars")
                    calHint.font = NSFont.systemFont(ofSize: 10)
                    calHint.textColor = .systemOrange
                    calHint.frame = NSRect(x: padding + 4, y: y, width: 310, height: 28)
                    contentView.addSubview(calHint)
                    y += 32
                } else {
                    let calendars = Self.fetchCalendarsDirectly()
                    if !calendars.isEmpty {
                        let selected = config.selectedCalendars
                        let allSelected = selected.isEmpty
                        for cal in calendars {
                            let cb = NSButton(checkboxWithTitle: "\(cal.title)  (\(cal.source))", target: self, action: #selector(calendarCheckboxChanged(_:)))
                            cb.font = NSFont.systemFont(ofSize: 11)
                            cb.frame = NSRect(x: padding + 12, y: y, width: 300, height: 18)
                            cb.state = allSelected || selected.contains(cal.id) ? .on : .off
                            cb.identifier = NSUserInterfaceItemIdentifier(cal.id)
                            calendarCheckboxes.append(cb)
                            contentView.addSubview(cb)
                            y += 20
                        }
                        y += 4
                    }
                }
            }
        }

        y += padding / 2
        let totalHeight = y + padding

        contentView.frame = NSRect(x: 0, y: 0, width: 340, height: totalHeight)
        panel.contentView = contentView
        panel.setContentSize(NSSize(width: 340, height: totalHeight))
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        window = panel
    }

    @objc private func segmentChanged(_ sender: NSSegmentedControl) {
        for (item, seg) in segments {
            if seg === sender {
                let vis: ItemVisibility
                switch sender.selectedSegment {
                case 0: vis = .off
                case 2: vis = .bar
                default: vis = .menu
                }
                config.setVisibility(vis, for: item)
                onChanged?()
                return
            }
        }
    }

    @objc private func calendarCheckboxChanged(_ sender: NSButton) {
        var selected: Set<String> = []
        let allOn = calendarCheckboxes.allSatisfy { $0.state == .on }
        if allOn {
            selected = []
        } else {
            for cb in calendarCheckboxes {
                if cb.state == .on, let id = cb.identifier?.rawValue {
                    selected.insert(id)
                }
            }
            if selected.isEmpty {
                sender.state = .on
                selected.insert(sender.identifier!.rawValue)
            }
        }
        config.setSelectedCalendars(selected)
        onChanged?()
    }

    @objc private func workspaceDisplayChanged(_ sender: NSSegmentedControl) {
        let mode: WorkspaceDisplayMode
        switch sender.selectedSegment {
        case 0: mode = .all
        case 2: mode = .current
        default: mode = .focused
        }
        config.setWorkspaceDisplay(mode)
        onChanged?()
    }

    func close() {
        window?.close()
    }

    private func checkCalendarAccess() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(macOS 14.0, *) {
            return status == .fullAccess
        }
        return status == .authorized
    }

    private static func fetchCalendarsDirectly() -> [(id: String, title: String, source: String)] {
        let store = EKEventStore()
        return store.calendars(for: .event)
            .map { (id: $0.calendarIdentifier, title: $0.title, source: $0.source?.title ?? "") }
            .sorted { $0.title.lowercased() < $1.title.lowercased() }
    }
}

// MARK: - Hotkey recorder field

class HotkeyField: NSView {
    var currentHotkey: String = "cmd+shift+m"
    var onChanged: ((String) -> Void)?
    private var isRecording = false
    private var label: NSTextField!
    private var bgLayer: CALayer?

    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.separatorColor.cgColor
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor

        label = NSTextField(labelWithString: "")
        label.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        label.alignment = .center
        label.frame = bounds.insetBy(dx: 4, dy: 3)
        label.autoresizingMask = [.width, .height]
        addSubview(label)

        updateDisplay()
    }

    private func updateDisplay() {
        if isRecording {
            label.stringValue = "Press shortcut…"
            label.textColor = .systemBlue
            layer?.borderColor = NSColor.systemBlue.cgColor
        } else {
            label.stringValue = formatForDisplay(currentHotkey)
            label.textColor = .labelColor
            layer?.borderColor = NSColor.separatorColor.cgColor
        }
    }

    private func formatForDisplay(_ hotkey: String) -> String {
        var parts: [String] = []
        let lower = hotkey.lowercased()
        let tokens = lower.split(separator: "+").map { $0.trimmingCharacters(in: .whitespaces) }
        for t in tokens {
            switch t {
            case "ctrl", "control": parts.append("⌃")
            case "option", "opt", "alt": parts.append("⌥")
            case "cmd", "command": parts.append("⌘")
            case "shift": parts.append("⇧")
            default: parts.append(t.uppercased())
            }
        }
        return parts.joined(separator: "")
    }

    override func mouseDown(with event: NSEvent) {
        isRecording = true
        updateDisplay()
        window?.makeFirstResponder(self)
    }

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        guard isRecording else { super.keyDown(with: event); return }

        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard !flags.isEmpty else { return }

        var parts: [String] = []
        if flags.contains(.control) { parts.append("ctrl") }
        if flags.contains(.option) { parts.append("option") }
        if flags.contains(.shift) { parts.append("shift") }
        if flags.contains(.command) { parts.append("cmd") }

        let keyName = keyNameFor(event.keyCode)
        if !keyName.isEmpty {
            parts.append(keyName)
        } else {
            return
        }

        currentHotkey = parts.joined(separator: "+")
        isRecording = false
        updateDisplay()
        onChanged?(currentHotkey)
    }

    override func resignFirstResponder() -> Bool {
        isRecording = false
        updateDisplay()
        return super.resignFirstResponder()
    }

    private func keyNameFor(_ code: UInt16) -> String {
        let map: [UInt16: String] = [
            0: "a", 11: "b", 8: "c", 2: "d", 14: "e", 3: "f", 5: "g", 4: "h",
            34: "i", 38: "j", 40: "k", 37: "l", 46: "m", 45: "n", 31: "o", 35: "p",
            12: "q", 15: "r", 1: "s", 17: "t", 32: "u", 9: "v", 13: "w", 7: "x",
            16: "y", 6: "z", 49: "space", 48: "tab", 53: "escape",
            18: "1", 19: "2", 20: "3", 21: "4", 23: "5", 22: "6", 26: "7", 28: "8",
            25: "9", 29: "0", 122: "f1", 120: "f2", 99: "f3", 118: "f4",
            96: "f5", 97: "f6", 98: "f7", 100: "f8", 101: "f9", 109: "f10",
            103: "f11", 111: "f12",
        ]
        return map[code] ?? ""
    }
}
