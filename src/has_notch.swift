// Prints "<has_notch> <top_inset>":
//   has_notch  - "1" if any connected screen has a notch (safeAreaInsets.top > 0)
//   top_inset  - height in px of the notched screen's unusable top strip
//                (frame top minus visibleFrame top), "0" when no notch.
// The inset feeds the outer.top math in bin/makaron-ui-helpers so windows
// keep a full gap below the floating bar, which extends past the notch strip.
// Compiled binary avoids the ~1s `swift -e` interpreter cold start.
import AppKit

if let s = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) {
    let inset = Int((s.frame.maxY - s.visibleFrame.maxY).rounded())
    print("1 \(max(inset, 0))")
} else {
    print("0 0")
}
