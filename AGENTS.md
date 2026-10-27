# AGENTS.md

Instructions for AI coding agents (Claude Code, Codex, Cursor and others) working in this repo. Humans: see [README.md](README.md).

## What this is

MicLock is a macOS menu bar app (about 150 lines of Swift) that keeps the Mac's built-in microphone as the default input. When the default input changes to a Bluetooth device such as AirPods, it switches it back to the built-in mic.

## If the user asks you to install MicLock

Run these steps in order and stop at the first failure.

1. Check the platform: `sw_vers -productVersion` must be 13.0 or later. MicLock is macOS only.
2. Check the toolchain: `swift --version`. If `swift` is missing, ask the user to run `xcode-select --install` and wait for it to finish. It opens a system dialog, so you can't complete it for them.
3. Build and install: `./build.sh --install`. This builds `build/MicLock.app`, quits any running MicLock, replaces `/Applications/MicLock.app` and launches it. It needs no `sudo`.
4. Confirm it's running: `pgrep -x MicLock` should print a process ID.
5. Verify it works: `swift scripts/verify.swift`.
   - Exit code 0 (PASS): MicLock switched the input back to the built-in mic.
   - Exit code 2 (SKIP): no Bluetooth mic is connected. Ask the user to connect their AirPods and run it again.
   - Exit code 1 (FAIL): see Troubleshooting below.
6. Tell the user they can turn on **Launch at Login** from the mic icon in the menu bar. That needs a click; there's no command for it.

## Uninstall

```bash
pkill -x MicLock
rm -rf /Applications/MicLock.app
```

If the user turned on Launch at Login, ask them to turn it off from the menu before quitting. Otherwise a stale entry stays in System Settings → General → Login Items until they remove it there.

## Project layout

| Path | Purpose |
| --- | --- |
| `Sources/MicLock/main.swift` | The whole app: CoreAudio helpers, the listener and the menu bar UI |
| `Package.swift` | Swift Package Manager manifest, one executable target |
| `Info.plist` | App bundle metadata. `LSUIElement` hides the Dock icon |
| `build.sh` | Builds the `.app` bundle, ad-hoc signs it, and installs it with `--install` |
| `scripts/verify.swift` | End-to-end check against the running app, as described above |

`.build/` and `build/` are build output and are git-ignored.

## How it works

- A block listener on `kAudioHardwarePropertyDefaultInputDevice` (on the system audio object) calls `enforce()` on the main queue. There is no polling and no timer; keep it that way.
- `enforce()` acts only when MicLock is turned on and the new default input's `kAudioDevicePropertyTransportType` is Bluetooth or Bluetooth LE. It then picks the first device with built-in transport and input streams. Device names are never hardcoded.
- The on/off state is stored in `UserDefaults` under the key `enabled`, which defaults to on.
- Launch at Login uses `SMAppService.mainApp`. It works only from a signed `.app` bundle, ideally in `/Applications`, not from `swift run`.

## Rules for changes

- Keep the app a single file and dependency-free. The no-Xcode, `swiftc`/SwiftPM build is a feature.
- Don't add polling, timers or background helpers.
- Don't override non-Bluetooth inputs. Users choose USB and virtual mics on purpose.
- After any change, run `./build.sh --install` and then `swift scripts/verify.swift`. The build should produce no warnings.
- Keep the bundle identifier `ch.ps14.miclock` unless the user asks otherwise. `scripts/verify.swift` looks the app up by it.

## Troubleshooting

- **verify.swift fails, but MicLock is running:** **Keep Built-in Mic** may be turned off. Check with `defaults read ch.ps14.miclock enabled`: `0` means off, while `1` or "does not exist" means on. Ask the user to turn it on from the menu.
- **The Launch at Login click shows an error:** the app is probably not running from `/Applications`. Reinstall with `./build.sh --install`.
- **The input still switches to AirPods in one app:** that app selects its own mic instead of following the system default. Point the user to that app's audio input setting and have them choose "System Default".
