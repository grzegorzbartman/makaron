import AppKit

// Dock autohide through the private CoreDock calls System Events uses, so no
// Automation or Accessibility permission is needed (SketchyBar plugins have neither).
// A Dock respawned by macOS can come back with autohide on but its space still
// reserved in NSScreen.visibleFrame; re-toggling autohide clears it.
//   status   autohide=<0|1> reserve=<pt>
//   on|off   set autohide (opposite first, so the window server always re-applies it)
//   heal     autohide pref on + Dock space reserved -> re-toggle; exit 1 if it stays reserved

typealias Getter = @convention(c) () -> Bool
typealias Setter = @convention(c) (Bool) -> Void

let lib = dlopen("/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices", RTLD_NOW)
guard let getSym = dlsym(lib, "CoreDockGetAutoHideEnabled"), let setSym = dlsym(lib, "CoreDockSetAutoHideEnabled") else {
    FileHandle.standardError.write("makaron-dock: CoreDock unavailable\n".data(using: .utf8)!)
    exit(2)
}
let getAutohide = unsafeBitCast(getSym, to: Getter.self)
let setAutohide = unsafeBitCast(setSym, to: Setter.self)

func prefAutohide() -> Bool {
    CFPreferencesCopyAppValue("autohide" as CFString, "com.apple.dock" as CFString) as? Bool ?? false
}

// Largest Dock-side inset (bottom, left, right) of visibleFrame on any screen; the top is the menu bar.
func reserve() -> Int {
    NSScreen.screens.map { s in
        let f = s.frame, v = s.visibleFrame
        return max(v.minY - f.minY, v.minX - f.minX, f.maxX - v.maxX)
    }.map { Int($0.rounded()) }.max() ?? 0
}

func kick(_ on: Bool) {
    setAutohide(!on)
    Thread.sleep(forTimeInterval: 0.5)
    setAutohide(on)
    Thread.sleep(forTimeInterval: 0.5)
}

switch CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "status" {
case "status":
    print("autohide=\(getAutohide() ? 1 : 0) reserve=\(reserve())")
case "on":
    kick(true)
case "off":
    kick(false)
case "heal":
    guard prefAutohide(), !getAutohide() || reserve() > 0 else { print("ok"); exit(0) }
    kick(true)
    let left = reserve()
    print(left > 0 ? "stuck reserve=\(left)" : "healed")
    exit(left > 0 ? 1 : 0)
default:
    FileHandle.standardError.write("usage: makaron-dock status|on|off|heal\n".data(using: .utf8)!)
    exit(2)
}
