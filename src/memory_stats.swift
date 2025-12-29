import Darwin

func getMemoryStats() -> (used: UInt64, total: UInt64)? {
    var stats = vm_statistics64()
    var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
    
    let result = withUnsafeMutablePointer(to: &stats) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
        }
    }
    
    guard result == KERN_SUCCESS else { return nil }
    
    let pageSize = UInt64(vm_kernel_page_size)
    
    // Match Activity Monitor's calculation:
    // Memory Used = App Memory + Wired Memory + Compressed
    // App Memory = (internal - purgeable) pages
    let appMemory = (UInt64(stats.internal_page_count) - UInt64(stats.purgeable_count)) * pageSize
    let wired = UInt64(stats.wire_count) * pageSize
    let compressed = UInt64(stats.compressor_page_count) * pageSize
    
    let used = appMemory + wired + compressed
    
    var totalMem: UInt64 = 0
    var size = MemoryLayout<UInt64>.size
    sysctlbyname("hw.memsize", &totalMem, &size, nil, 0)
    
    return (used, totalMem)
}

if let stats = getMemoryStats() {
    let usedGB = stats.used / (1024 * 1024 * 1024)
    let totalGB = stats.total / (1024 * 1024 * 1024)
    print("\(usedGB)/\(totalGB) GB")
} else {
    print("N/A")
}

