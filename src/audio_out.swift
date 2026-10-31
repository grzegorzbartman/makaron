// Prints "<transport> <volume>" for the default output device:
//   transport - "bluetooth" or "other"
//   volume    - 0-100, "-" when the device has no volume control (e.g. HDMI)
// Replaces osascript + system_profiler (~0.3s) in plugins/volume.sh.
import CoreAudio
import AudioToolbox

func address(_ selector: AudioObjectPropertySelector,
             _ scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> AudioObjectPropertyAddress {
    AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: kAudioObjectPropertyElementMain)
}

func read<T>(_ object: AudioObjectID, _ addr: AudioObjectPropertyAddress, _ initial: T) -> T? {
    var addr = addr
    var value = initial
    var size = UInt32(MemoryLayout<T>.size)
    let status = withUnsafeMutableBytes(of: &value) {
        AudioObjectGetPropertyData(object, &addr, 0, nil, &size, $0.baseAddress!)
    }
    return status == noErr ? value : nil
}

guard let device = read(AudioObjectID(kAudioObjectSystemObject),
                        address(kAudioHardwarePropertyDefaultOutputDevice), AudioDeviceID(0)),
      device != kAudioObjectUnknown else {
    print("other -")
    exit(0)
}

let transport = read(device, address(kAudioDevicePropertyTransportType), UInt32(0)) ?? 0
let bluetooth = transport == kAudioDeviceTransportTypeBluetooth || transport == kAudioDeviceTransportTypeBluetoothLE

let volume = read(device, address(kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
                                  kAudioDevicePropertyScopeOutput), Float32(-1)) ?? -1

print("\(bluetooth ? "bluetooth" : "other") \(volume < 0 ? "-" : String(Int((volume * 100).rounded())))")
