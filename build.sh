#!/bin/bash
# Builds MicLock.app and installs it into /Applications.
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release
APP=build/MicLock.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/MicLock "$APP/Contents/MacOS/MicLock"
cp Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"

if [[ "${1:-}" == "--install" ]]; then
    pkill -x MicLock || true
    rm -rf /Applications/MicLock.app
    cp -R "$APP" /Applications/
    open /Applications/MicLock.app
    echo "Installed /Applications/MicLock.app"
fi
