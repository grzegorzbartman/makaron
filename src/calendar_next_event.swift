import EventKit
import Foundation

let store = EKEventStore()
let sem = DispatchSemaphore(value: 0)
var accessGranted = false
if #available(macOS 14.0, *) {
    store.requestFullAccessToEvents { ok, _ in
        accessGranted = ok
        sem.signal()
    }
} else {
    store.requestAccess(to: .event) { ok, _ in
        accessGranted = ok
        sem.signal()
    }
}
sem.wait()

guard accessGranted else {
    exit(2)
}

let now = Date()
let end = Calendar.current.date(byAdding: .day, value: 14, to: now)!
let predicate = store.predicateForEvents(withStart: now.addingTimeInterval(-86400), end: end, calendars: nil)
var events = store.events(matching: predicate)
events.sort { $0.startDate < $1.startDate }

let chosen: EKEvent? = {
    if let cur = events.first(where: { $0.startDate <= now && $0.endDate > now }) {
        return cur
    }
    return events.first(where: { $0.startDate > now })
}()

guard let ev = chosen else {
    print("")
    exit(0)
}

let title = ev.title ?? ""
let ts = Int(ev.startDate.timeIntervalSince1970)
print("\(ts)\t\(title)")
