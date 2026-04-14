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

let args = CommandLine.arguments

if args.contains("--list-calendars") {
    let calendars = store.calendars(for: .event)
    for cal in calendars.sorted(by: { $0.title < $1.title }) {
        let src = cal.source?.title ?? ""
        print("\(cal.calendarIdentifier)\t\(cal.title)\t\(src)")
    }
    exit(0)
}

var filterCalendarIDs: Set<String>? = nil
if let calArg = args.first(where: { $0.hasPrefix("--calendars=") }) {
    let ids = String(calArg.dropFirst("--calendars=".count))
        .split(separator: ",").map { String($0) }
    if !ids.isEmpty {
        filterCalendarIDs = Set(ids)
    }
}

func selectedCalendars() -> [EKCalendar]? {
    guard let ids = filterCalendarIDs else { return nil }
    let all = store.calendars(for: .event)
    let filtered = all.filter { ids.contains($0.calendarIdentifier) }
    return filtered.isEmpty ? nil : filtered
}

let listToday = args.contains("--today")
let now = Date()

if listToday {
    let cal = Calendar.current
    let startOfDay = cal.startOfDay(for: now)
    let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay)!
    let predicate = store.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: selectedCalendars())
    var events = store.events(matching: predicate)
        .filter { $0.isAllDay || $0.endDate > now }
    events.sort { $0.startDate < $1.startDate }
    for ev in events {
        let title = ev.title ?? ""
        let ts = Int(ev.startDate.timeIntervalSince1970)
        let allDay = ev.isAllDay ? "1" : "0"
        print("\(ts)\t\(allDay)\t\(title)")
    }
    exit(0)
}

let end = Calendar.current.date(byAdding: .day, value: 14, to: now)!
let predicate = store.predicateForEvents(withStart: now.addingTimeInterval(-86400), end: end, calendars: selectedCalendars())
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
