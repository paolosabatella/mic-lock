# MicLock

A tiny macOS menu bar app that keeps your Mac's built-in microphone as the default input, even when AirPods (or any other Bluetooth headset) connect.

## Why

When AirPods connect, macOS makes their microphone the default input. That has two downsides:

- The AirPods mic is noticeably worse than the built-in one, and slower to start recording (a problem for dictation apps like Superwhisper).
- While the AirPods mic is in use, Bluetooth falls back to a low-quality call profile, so music and other output sound worse too.

MicLock switches the input back to the built-in mic as soon as macOS hands it to a Bluetooth device. Apps that follow the system default input then use the built-in mic automatically, with no per-app setup.

## How it works

- **Event-driven, no polling.** MicLock registers a CoreAudio listener on `kAudioHardwarePropertyDefaultInputDevice` and stays idle until macOS reports a change.
- **Only Bluetooth is overridden.** If the new default input uses Bluetooth or Bluetooth LE transport, MicLock switches to the built-in mic. USB, virtual and other inputs you pick on purpose are left alone.
- **No hardcoded names.** The built-in mic is found by its transport type, so it works on any Mac with one.

## Menu

- **Keep Built-in Mic:** turn MicLock on or off, for example for a call where you want the AirPods mic. The setting is remembered.
- **Launch at Login:** registers MicLock with `SMAppService`, so it shows up in System Settings → General → Login Items.
- **Quit MicLock**

The menu bar icon is a filled mic while MicLock is on and a crossed-out mic while it's off.

## Install

Requirements: macOS 13 or later, and the Xcode Command Line Tools (`xcode-select --install`). Xcode itself is not needed.

```bash
git clone https://github.com/paolosabatella/mic-lock.git
cd mic-lock
./build.sh --install
```

This builds `MicLock.app`, signs it ad hoc, copies it to `/Applications` and launches it. Run `./build.sh` without `--install` to build into `build/MicLock.app` only.

## Uninstall

1. Turn off **Launch at Login** in the menu.
2. Choose **Quit MicLock**.
3. Delete `/Applications/MicLock.app`.

## License

[MIT](LICENSE)
