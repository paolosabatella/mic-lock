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

## Install with an AI agent

The easiest way: open this repo in a coding agent such as Claude Code, Codex or Cursor and tell it:

> Build and install MicLock, then verify it works.

The repo includes [AGENTS.md](AGENTS.md) (also read by Claude Code via `CLAUDE.md`) with step-by-step install, verification and troubleshooting instructions for agents.

## Build and install it yourself

### Requirements

- macOS 13 (Ventura) or later
- The Xcode Command Line Tools. Check with `swift --version`; if it's missing, install them with:

  ```bash
  xcode-select --install
  ```

  The full Xcode app is not needed.

### Steps

1. Get the code:

   ```bash
   git clone https://github.com/paolosabatella/mic-lock.git
   cd mic-lock
   ```

2. Build and install:

   ```bash
   ./build.sh --install
   ```

   This builds `MicLock.app`, signs it ad hoc, copies it to `/Applications` and launches it. A mic icon appears in the menu bar. To build without installing, run `./build.sh`; the app is then in `build/MicLock.app`.

3. Optional: open the menu bar icon and turn on **Launch at Login**.

Building from source means macOS doesn't show a Gatekeeper warning, because the app never got the "downloaded from the internet" flag.

### Check that it works

Connect your AirPods, then run:

```bash
swift scripts/verify.swift
```

It switches the default input to the AirPods mic, as macOS does when they connect, and checks that MicLock switches it back. It prints `PASS`, `FAIL` or `SKIP` (when MicLock isn't running or no Bluetooth mic is connected).

### Updating

```bash
git pull
./build.sh --install
```

### Troubleshooting

- **`swift: command not found`:** install the Command Line Tools with `xcode-select --install`.
- **An app still records from the AirPods:** that app picks its own mic. Set its input to "System Default" in its settings.
- **Launch at Login shows an error:** MicLock must run from `/Applications`. Reinstall with `./build.sh --install`.

## Uninstall

1. Turn off **Launch at Login** in the menu.
2. Choose **Quit MicLock**.
3. Delete `/Applications/MicLock.app`.

## License

[MIT](LICENSE)
