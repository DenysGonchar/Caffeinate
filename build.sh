#!/bin/sh
set -eu
cd "$(dirname "$0")"

APP_BUNDLE="build/Caffeinate.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources" build/module-cache
xcrun swiftc -module-cache-path build/module-cache \
    scripts/GenerateIcon.swift -o build/generate-icon
build/generate-icon "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
xcrun swiftc -parse-as-library -O \
    -target "$(uname -m)-apple-macos13.0" \
    -module-cache-path build/module-cache \
    Caffeinate.swift -o "$APP_BUNDLE/Contents/MacOS/Caffeinate"
cp Info.plist "$APP_BUNDLE/Contents/Info.plist"
codesign --force --sign - "$APP_BUNDLE"
printf 'Built %s/%s\n' "$PWD" "$APP_BUNDLE"
