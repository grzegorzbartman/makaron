// Prints "1" if any connected screen has a notch (safeAreaInsets.top > 0).
// Compiled binary avoids the ~1s `swift -e` interpreter cold start on every
// notch-cache miss (see _has_builtin_notch in bin/makaron-ui-helpers).
import AppKit

let hasNotch = NSScreen.screens.contains { $0.safeAreaInsets.top > 0 }
print(hasNotch ? "1" : "0")
