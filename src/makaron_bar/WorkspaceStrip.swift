import AppKit

extension NSImage {
    func image(with tintColor: NSColor) -> NSImage {
        let img = self.copy() as! NSImage
        img.lockFocus()
        tintColor.set()
        NSRect(origin: .zero, size: img.size).fill(using: .sourceAtop)
        img.unlockFocus()
        img.isTemplate = false
        return img
    }
}

struct BarLabel {
    let text: String
    let highlight: Bool
}

class WorkspaceStripView: NSView {
    var workspaces: [Workspace] = []
    var theme: MakaronTheme = .default
    var barLabels: [BarLabel] = []
    var onWorkspaceClick: ((String) -> Void)?
    var onMenuClick: (() -> Void)?

    private let cellHeight: CGFloat = 16
    private let pillPadding: CGFloat = 5
    private let cellSpacing: CGFloat = 1
    private let pillRadius: CGFloat = 4
    private let fontSize: CGFloat = 11
    private let barFontSize: CGFloat = 10
    private let iconSize: CGFloat = 14
    private let iconPadding: CGFloat = 6
    private let borderWidth: CGFloat = 1.5
    private let separatorPadding: CGFloat = 6

    private var menuIconWidth: CGFloat {
        return iconSize + iconPadding
    }

    override var intrinsicContentSize: NSSize {
        var totalWidth: CGFloat = menuIconWidth + 2
        for ws in workspaces {
            totalWidth += cellWidth(for: ws) + cellSpacing
        }
        if !barLabels.isEmpty {
            let font = NSFont.monospacedDigitSystemFont(ofSize: barFontSize, weight: .regular)
            for lbl in barLabels {
                totalWidth += separatorPadding
                let size = (lbl.text as NSString).size(withAttributes: [.font: font])
                totalWidth += size.width + 4
            }
        }
        totalWidth += 2
        return NSSize(width: max(totalWidth, 30), height: 22)
    }

    private func cellWidth(for ws: Workspace) -> CGFloat {
        let font = ws.isFocused
            ? NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .bold)
            : NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
        let size = (ws.id as NSString).size(withAttributes: [.font: font])
        if ws.isFocused {
            return size.width + pillPadding * 2
        }
        return size.width + 6
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        drawMenuIcon()

        var x: CGFloat = menuIconWidth + 2

        for ws in workspaces {
            let w = cellWidth(for: ws)
            let cellRect = NSRect(x: x, y: (bounds.height - cellHeight) / 2, width: w, height: cellHeight)

            if ws.isFocused {
                let pill = NSBezierPath(roundedRect: cellRect, xRadius: pillRadius, yRadius: pillRadius)
                pill.lineWidth = borderWidth
                theme.labelColor.setStroke()
                pill.stroke()
            }

            let font = ws.isFocused
                ? NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .bold)
                : NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)

            let color: NSColor
            if ws.isFocused {
                color = theme.labelColor
            } else if !ws.apps.isEmpty {
                color = theme.labelColor
            } else {
                color = theme.labelColor.withAlphaComponent(0.3)
            }

            let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
            let str = NSAttributedString(string: ws.id, attributes: attrs)
            let strSize = str.size()
            let strX = cellRect.midX - strSize.width / 2
            let strY = cellRect.midY - strSize.height / 2
            str.draw(at: NSPoint(x: strX, y: strY))

            if !ws.apps.isEmpty && !ws.isFocused {
                let dotSize: CGFloat = 3
                let dotY = cellRect.minY - 1
                let dotX = cellRect.midX - dotSize / 2
                let dotRect = NSRect(x: dotX, y: dotY, width: dotSize, height: dotSize)
                let dot = NSBezierPath(ovalIn: dotRect)
                color.setFill()
                dot.fill()
            }

            x += w + cellSpacing
        }

        if !barLabels.isEmpty {
            let sepColor = theme.labelColor.withAlphaComponent(0.15)
            let barFont = NSFont.monospacedDigitSystemFont(ofSize: barFontSize, weight: .regular)
            let dimColor = theme.labelColor.withAlphaComponent(0.6)

            for lbl in barLabels {
                x += separatorPadding / 2
                let sep = NSBezierPath()
                sep.move(to: NSPoint(x: x, y: bounds.height * 0.2))
                sep.line(to: NSPoint(x: x, y: bounds.height * 0.8))
                sep.lineWidth = 1
                sepColor.setStroke()
                sep.stroke()
                x += separatorPadding / 2

                let c = lbl.highlight ? theme.labelColor : dimColor
                let attrs: [NSAttributedString.Key: Any] = [.font: barFont, .foregroundColor: c]
                let attrStr = NSAttributedString(string: lbl.text, attributes: attrs)
                let size = attrStr.size()
                let y = (bounds.height - size.height) / 2
                attrStr.draw(at: NSPoint(x: x + 2, y: y))
                x += size.width + 4
            }
        }
    }

    private func drawMenuIcon() {
        let iconFont = NSFont.systemFont(ofSize: 13, weight: .regular)
        let attrs: [NSAttributedString.Key: Any] = [.font: iconFont]
        let icon = NSAttributedString(string: "🍝", attributes: attrs)
        let size = icon.size()
        let x: CGFloat = (iconPadding / 2)
        let y = (bounds.height - size.height) / 2
        icon.draw(at: NSPoint(x: x, y: y))
    }

    override func mouseDown(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)

        if loc.x < menuIconWidth {
            onMenuClick?()
            return
        }

        var x: CGFloat = menuIconWidth + 2
        for ws in workspaces {
            let w = cellWidth(for: ws)
            let cellRect = NSRect(x: x, y: 0, width: w, height: bounds.height)
            if cellRect.contains(loc) {
                onWorkspaceClick?(ws.id)
                return
            }
            x += w + cellSpacing
        }
    }

    func update(workspaces: [Workspace], theme: MakaronTheme, barLabels: [BarLabel] = []) {
        self.workspaces = workspaces
        self.theme = theme
        self.barLabels = barLabels
        invalidateIntrinsicContentSize()
        needsDisplay = true
    }
}
