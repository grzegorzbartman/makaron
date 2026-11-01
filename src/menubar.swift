import Foundation

// Sets "Automatically hide and show the menu bar" the way System Settings does:
// both global keys + the Control Center option, then the notifications that make the
// window server apply it live. A bare `defaults write` skips the notifications and is ignored.
let modes: [String: (option: Int, hide: Bool, visibleInFullscreen: Bool)] = [
    "always": (0, true, false),
    "desktop": (1, true, true),
    "fullscreen": (2, false, false),
    "never": (3, false, true),
]

let global = kCFPreferencesAnyApplication
let user = kCFPreferencesCurrentUser
let host = kCFPreferencesAnyHost
let controlCenter = "com.apple.controlcenter" as CFString

func bool(_ key: String) -> Bool {
    CFPreferencesCopyValue(key as CFString, global, user, host) as? Bool ?? false
}

let arg = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "status"

if arg == "status" {
    let hide = bool("_HIHideMenuBar"), fs = bool("AppleMenuBarVisibleInFullscreen")
    print(modes.first { $0.value.hide == hide && $0.value.visibleInFullscreen == fs }!.key)
    exit(0)
}

guard let mode = modes[arg] else {
    FileHandle.standardError.write("usage: makaron-menubar always|desktop|fullscreen|never|status\n".data(using: .utf8)!)
    exit(2)
}

CFPreferencesSetValue("_HIHideMenuBar" as CFString, mode.hide as CFBoolean, global, user, host)
CFPreferencesSetValue("AppleMenuBarVisibleInFullscreen" as CFString, mode.visibleInFullscreen as CFBoolean, global, user, host)
CFPreferencesSetAppValue("AutoHideMenuBarOption" as CFString, mode.option as CFNumber, controlCenter)
guard CFPreferencesSynchronize(global, user, host), CFPreferencesAppSynchronize(controlCenter) else { exit(1) }

// Keep the WindowServer flag in sync like System Events does (private, optional; alone it does not move the bar).
if let sky = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_LAZY),
   let cidSym = dlsym(sky, "SLSMainConnectionID"), let setSym = dlsym(sky, "SLSSetMenuBarAutohideEnabled") {
    let cid = unsafeBitCast(cidSym, to: (@convention(c) () -> Int32).self)()
    _ = unsafeBitCast(setSym, to: (@convention(c) (Int32, Bool) -> Int32).self)(cid, mode.hide)
}

let center = DistributedNotificationCenter.default()
for name in ["AppleInterfaceMenuBarHidingChangedNotification", "AppleInterfaceFullScreenMenuBarVisibilityChangedNotification"] {
    center.postNotificationName(.init(name), object: nil, userInfo: nil, deliverImmediately: true)
}
