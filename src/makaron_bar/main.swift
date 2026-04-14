import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.accessory) // LSUIElement — no Dock icon
let delegate = AppDelegate()
app.delegate = delegate
app.run()
