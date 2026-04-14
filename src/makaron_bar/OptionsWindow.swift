import AppKit
import Carbon
import EventKit

private class FlippedView: NSView {
    override var isFlipped: Bool { true }
}

class OptionsWindowController {
    private var window: NSPanel?
    private var segments: [BarItem: NSSegmentedControl] = [:]
    private var calendarCheckboxes: [NSButton] = []
    private let config = BarConfig.shared
    private var hotkeyField: HotkeyField?
    var onChanged: (() -> Void)?
    var onHotkeyChanged: (() -> Void)?

    private let W: CGFloat = 400
    private let pad: CGFloat = 20
    private let innerPad: CGFloat = 14
    private let rowH: CGFloat = 32
    private let lblW: CGFloat = 100

    func show() {
        if let w = window, w.isVisible {
            w.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: W, height: 600),
            styleMask: [.titled, .closable, .nonactivatingPanel, .utilityWindow],
            backing: .buffered, defer: false
        )
        panel.title = "MakaronBar Options"
        panel.isFloatingPanel = true
        panel.becomesKeyOnlyIfNeeded = false
        panel.level = .floating
        panel.isReleasedWhenClosed = false

        calendarCheckboxes = []
        segments = [:]

        let scroll = NSScrollView(frame: NSRect(x: 0, y: 0, width: W, height: 600))
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        scroll.autohidesScrollers = true

        let cv = FlippedView()
        cv.frame = NSRect(x: 0, y: 0, width: W, height: 2000)
        scroll.documentView = cv
        var y: CGFloat = pad

        y = buildGeneralSection(in: cv, y: y)
        y += 16
        y = buildItemsSection(in: cv, y: y)
        y += 16
        y = buildCalendarsSection(in: cv, y: y)
        y += pad

        cv.frame = NSRect(x: 0, y: 0, width: W, height: y)

        let visibleH = min(y, 700)
        panel.setContentSize(NSSize(width: W, height: visibleH))
        scroll.frame = NSRect(x: 0, y: 0, width: W, height: visibleH)
        panel.contentView = scroll
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window = panel
    }

    // MARK: - General

    private func buildGeneralSection(in cv: NSView, y startY: CGFloat) -> CGFloat {
        var y = startY
        addSectionLabel("General", in: cv, y: y)
        y += 22

        let boxContent: [(CGFloat) -> CGFloat] = [
            { y in self.addGroupRow("AeroSpace", in: cv, y: y) { ctrlX, ctrlW in
                let seg = NSSegmentedControl(labels: ["All", "Active Only", "Current Only"],
                                              trackingMode: .selectOne, target: self,
                                              action: #selector(self.workspaceDisplayChanged(_:)))
                seg.segmentStyle = .rounded
                seg.frame = NSRect(x: ctrlX, y: y + 4, width: ctrlW, height: 24)
                switch self.config.workspaceDisplay {
                case .all: seg.selectedSegment = 0
                case .focused: seg.selectedSegment = 1
                case .current: seg.selectedSegment = 2
                }
                cv.addSubview(seg)
            }},
            { y in self.addGroupRow("Hotkey", in: cv, y: y) { ctrlX, ctrlW in
                let field = HotkeyField(frame: NSRect(x: ctrlX, y: y + 4, width: ctrlW, height: 24))
                field.currentHotkey = self.config.readHotkeyString()
                field.onChanged = { [weak self] val in
                    self?.config.writeHotkeyString(val)
                    self?.onHotkeyChanged?()
                }
                self.hotkeyField = field
                cv.addSubview(field)
            }},
        ]

        let boxY = y
        for row in boxContent { y = row(y) }
        addGroupBox(in: cv, y: boxY, height: y - boxY)

        y += 4
        let hint = NSTextField(labelWithString: "Click the hotkey field and press your shortcut. Restart to apply.")
        hint.font = NSFont.systemFont(ofSize: 10)
        hint.textColor = .tertiaryLabelColor
        hint.frame = NSRect(x: pad + 4, y: y, width: W - pad * 2, height: 14)
        cv.addSubview(hint)
        y += 18
        return y
    }

    // MARK: - Status Bar Items

    private func buildItemsSection(in cv: NSView, y startY: CGFloat) -> CGFloat {
        var y = startY
        addSectionLabel("Status Bar Items", in: cv, y: y)
        y += 22

        let boxY = y
        for item in BarItem.allCases {
            y = addGroupRow(item.displayName, in: cv, y: y) { ctrlX, ctrlW in
                let seg = NSSegmentedControl(labels: ["Off", "Menu", "Top Bar"],
                                              trackingMode: .selectOne, target: self,
                                              action: #selector(self.segmentChanged(_:)))
                seg.segmentStyle = .rounded
                seg.frame = NSRect(x: ctrlX, y: y + 4, width: ctrlW, height: 24)
                seg.tag = item.hashValue
                switch self.config.visibility(for: item) {
                case .off: seg.selectedSegment = 0
                case .menu: seg.selectedSegment = 1
                case .bar: seg.selectedSegment = 2
                }
                self.segments[item] = seg
                cv.addSubview(seg)
            }
        }
        addGroupBox(in: cv, y: boxY, height: y - boxY)
        return y
    }

    // MARK: - Calendars

    private func buildCalendarsSection(in cv: NSView, y startY: CGFloat) -> CGFloat {
        var y = startY
        addSectionLabel("Calendars", in: cv, y: y)
        y += 22

        let boxY = y

        guard checkCalendarAccess() else {
            let warn = NSTextField(wrappingLabelWithString: "⚠ No calendar access — grant in System Settings → Privacy & Security → Calendars")
            warn.font = NSFont.systemFont(ofSize: 11)
            warn.textColor = .systemOrange
            warn.frame = NSRect(x: pad + innerPad, y: y + 8, width: W - pad * 2 - innerPad * 2, height: 36)
            cv.addSubview(warn)
            y += 52
            addGroupBox(in: cv, y: boxY, height: y - boxY)
            return y
        }

        let calendars = Self.fetchCalendarsDirectly()
        let selected = config.selectedCalendars
        let allSelected = selected.isEmpty

        if calendars.isEmpty {
            let empty = NSTextField(labelWithString: "No calendars found.")
            empty.font = NSFont.systemFont(ofSize: 12)
            empty.textColor = .secondaryLabelColor
            empty.frame = NSRect(x: pad + innerPad, y: y + 8, width: W - pad * 2 - innerPad * 2, height: 20)
            cv.addSubview(empty)
            y += 36
        } else {
            y += 8
            for cal in calendars {
                let cb = NSButton(checkboxWithTitle: "\(cal.title)  ·  \(cal.source)",
                                  target: self, action: #selector(calendarCheckboxChanged(_:)))
                cb.font = NSFont.systemFont(ofSize: 12)
                cb.frame = NSRect(x: pad + innerPad, y: y, width: W - pad * 2 - innerPad * 2, height: 20)
                cb.state = allSelected || selected.contains(cal.id) ? .on : .off
                cb.identifier = NSUserInterfaceItemIdentifier(cal.id)
                calendarCheckboxes.append(cb)
                cv.addSubview(cb)
                y += 22
            }
            y += 6
        }

        addGroupBox(in: cv, y: boxY, height: y - boxY)

        y += 4
        let hint = NSTextField(labelWithString: "All selected = show events from all calendars.")
        hint.font = NSFont.systemFont(ofSize: 10)
        hint.textColor = .tertiaryLabelColor
        hint.frame = NSRect(x: pad + 4, y: y, width: W - pad * 2, height: 14)
        cv.addSubview(hint)
        y += 18

        return y
    }

    // MARK: - UI building blocks

    private func addSectionLabel(_ title: String, in cv: NSView, y: CGFloat) {
        let lbl = NSTextField(labelWithString: title)
        lbl.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = .labelColor
        lbl.frame = NSRect(x: pad + 4, y: y, width: W - pad * 2, height: 18)
        cv.addSubview(lbl)
    }

    private func addGroupRow(_ label: String, in cv: NSView, y: CGFloat,
                             control: (_ ctrlX: CGFloat, _ ctrlW: CGFloat) -> Void) -> CGFloat {
        let lbl = NSTextField(labelWithString: label)
        lbl.font = NSFont.systemFont(ofSize: 13)
        lbl.frame = NSRect(x: pad + innerPad, y: y + 6, width: lblW, height: 20)
        cv.addSubview(lbl)

        let ctrlX = pad + innerPad + lblW
        let ctrlW = W - pad * 2 - innerPad * 2 - lblW
        control(ctrlX, ctrlW)

        return y + rowH
    }

    private func addGroupBox(in cv: NSView, y: CGFloat, height: CGFloat) {
        let box = NSView(frame: NSRect(x: pad, y: y, width: W - pad * 2, height: height))
        box.wantsLayer = true
        box.layer?.cornerRadius = 10
        box.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        cv.addSubview(box, positioned: .below, relativeTo: nil)
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
