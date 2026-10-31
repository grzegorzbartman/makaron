// Prints "<builtin_width> <builtin_height> <screen_count>" in points:
//   builtin_width/height - logical size of the built-in display (the scaled
//                          resolution, e.g. 1470 956 on a MacBook Air 13),
//                          "0 0" when it is off (clamshell / external only)
//   screen_count         - number of active displays
// Feeds the laptop/desktop layout profile in bin/makaron-ui-helpers: points
// decide how many windows fit, so detection never depends on model names.
// Compiled binary avoids the ~1s `swift -e` interpreter cold start.
import AppKit

var width = 0, height = 0
for screen in NSScreen.screens {
    guard let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID,
          CGDisplayIsBuiltin(id) != 0 else { continue }
    width = Int(screen.frame.width.rounded())
    height = Int(screen.frame.height.rounded())
    break
}
print("\(width) \(height) \(NSScreen.screens.count)")
