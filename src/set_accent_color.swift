import Foundation

guard CommandLine.arguments.count > 1,
      let value = Int(CommandLine.arguments[1]),
      (-1...6).contains(value) else {
    fputs("Usage: set_accent_color <-1..6>\n", stderr)
    exit(1)
}

UserDefaults.standard.set(value, forKey: "AppleAccentColor")
UserDefaults.standard.synchronize()

DistributedNotificationCenter.default().postNotificationName(
    NSNotification.Name("AppleColorPreferencesChangedNotification"),
    object: nil,
    userInfo: nil,
    deliverImmediately: true
)
