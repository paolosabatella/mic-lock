// Checks that a running MicLock switches the default input back to the built-in mic.
// It sets the default input to a connected Bluetooth mic, as macOS does when AirPods
// connect, then checks the default input a moment later.
//
// Run: swift scripts/verify.swift
// Exit codes: 0 = pass, 1 = fail, 2 = skipped (MicLock not running or no Bluetooth mic connected).
import AppKit
import CoreAudio

func address(_ selector: AudioObjectPropertySelector,
             _ scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> AudioObjectPropertyAddress {
    AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: kAudioObjectPropertyElementMain)
}

let system = AudioObjectID(kAudioObjectSystemObject)

func defaultInput() -> AudioDeviceID {
    var addr = address(kAudioHardwarePropertyDefaultInputDevice)
    var id = AudioDeviceID(0)
    var size = UInt32(MemoryLayout<AudioDeviceID>.size)
    AudioObjectGetPropertyData(system, &addr, 0, nil, &size, &id)
    return id
}

func setDefaultInput(_ id: AudioDeviceID) -> Bool {
    var addr = address(kAudioHardwarePropertyDefaultInputDevice)
    var id = id
    return AudioObjectSetPropertyData(system, &addr, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &id) == noErr
}

func devices() -> [AudioDeviceID] {
    var addr = address(kAudioHardwarePropertyDevices)
    var size: UInt32 = 0
    AudioObjectGetPropertyDataSize(system, &addr, 0, nil, &size)
    var ids = [AudioDeviceID](repeating: 0, count: Int(size) / MemoryLayout<AudioDeviceID>.size)
    AudioObjectGetPropertyData(system, &addr, 0, nil, &size, &ids)
    return ids
}

func transport(_ id: AudioDeviceID) -> UInt32 {
    var addr = address(kAudioDevicePropertyTransportType)
    var type: UInt32 = 0
    var size = UInt32(MemoryLayout<UInt32>.size)
    AudioObjectGetPropertyData(id, &addr, 0, nil, &size, &type)
    return type
}

func hasInput(_ id: AudioDeviceID) -> Bool {
    var addr = address(kAudioDevicePropertyStreams, kAudioObjectPropertyScopeInput)
    var size: UInt32 = 0
    return AudioObjectGetPropertyDataSize(id, &addr, 0, nil, &size) == noErr && size > 0
}

func name(_ id: AudioDeviceID) -> String {
    var addr = address(kAudioObjectPropertyName)
    var name: Unmanaged<CFString>?
    var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
    guard AudioObjectGetPropertyData(id, &addr, 0, nil, &size, &name) == noErr, let name else { return "?" }
    return name.takeRetainedValue() as String
}

let inputs = devices().filter(hasInput)
print("Input devices:")
for id in inputs { print("  \(name(id))\(id == defaultInput() ? "  (default)" : "")") }

guard NSRunningApplication.runningApplications(withBundleIdentifier: "ch.ps14.miclock").first != nil else {
    print("SKIP: MicLock is not running. Start it with: open /Applications/MicLock.app")
    exit(2)
}
guard let bluetooth = inputs.first(where: {
    [kAudioDeviceTransportTypeBluetooth, kAudioDeviceTransportTypeBluetoothLE].contains(transport($0))
}) else {
    print("SKIP: no Bluetooth microphone is connected. Connect AirPods and run again.")
    exit(2)
}

let original = defaultInput()
print("Setting default input to \(name(bluetooth))...")
guard setDefaultInput(bluetooth) else {
    print("FAIL: could not set the default input.")
    exit(1)
}
Thread.sleep(forTimeInterval: 1)

let after = defaultInput()
if transport(after) == kAudioDeviceTransportTypeBuiltIn {
    print("PASS: MicLock switched the input back to \(name(after)).")
    exit(0)
}
_ = setDefaultInput(original)
print("FAIL: default input is still \(name(after)). Is \"Keep Built-in Mic\" turned on in the menu?")
exit(1)
