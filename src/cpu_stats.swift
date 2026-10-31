// Prints total CPU usage percent (0-100) like Activity Monitor's CPU load:
// busy (user + system + nice) ticks over all ticks since the previous run.
// Ticks are kept in /tmp between runs; the first run samples over 250ms.
// `ps -A -o %cpu` reports decayed per-process averages and lags real load.
import Foundation

func ticks() -> [UInt64]? {
    var info = host_cpu_load_info()
    var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
    let status = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
        }
    }
    guard status == KERN_SUCCESS else { return nil }
    let t = info.cpu_ticks
    return [t.0, t.1, t.2, t.3].map { UInt64($0) }  // user, system, idle, nice
}

let state = "/tmp/makaron_\(getuid())_cpu_ticks"

guard var now = ticks() else { print("N/A"); exit(0) }

var prev = (try? String(contentsOfFile: state, encoding: .utf8))?
    .split(whereSeparator: { $0 == " " || $0 == "\n" }).compactMap { UInt64($0) }

if prev?.count != 4 || zip(now, prev!).contains(where: { $0 < $1 }) {
    prev = now
    usleep(250_000)
    now = ticks() ?? now
}

let delta = zip(now, prev!).map { $0 - $1 }
let total = delta.reduce(0, +)
let busy = delta[0] + delta[1] + delta[3]

try? now.map(String.init).joined(separator: " ").write(toFile: state, atomically: true, encoding: .utf8)

print(total == 0 ? 0 : min(100, Int((Double(busy) * 100 / Double(total)).rounded())))
