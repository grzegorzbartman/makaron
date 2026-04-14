import AppKit

struct MakaronTheme {
    var barColor: NSColor
    var iconColor: NSColor
    var labelColor: NSColor
    var spaceBgColor: NSColor
    var spaceBorderColor: NSColor
    var spaceFocusedBgColor: NSColor
    var spaceFocusedBorderColor: NSColor
    var spaceFocusedIconColor: NSColor
    var spaceFocusedLabelColor: NSColor
    var spaceIconColor: NSColor
    var spaceLabelColor: NSColor

    static let `default` = MakaronTheme(
        barColor: .windowBackgroundColor,
        iconColor: .labelColor,
        labelColor: .labelColor,
        spaceBgColor: .controlBackgroundColor,
        spaceBorderColor: .separatorColor,
        spaceFocusedBgColor: .controlAccentColor,
        spaceFocusedBorderColor: .controlAccentColor,
        spaceFocusedIconColor: .white,
        spaceFocusedLabelColor: .white,
        spaceIconColor: .secondaryLabelColor,
        spaceLabelColor: .secondaryLabelColor
    )
}
