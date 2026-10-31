#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="SoundcoreBridge"
APP_DIR="$ROOT_DIR/build/$APP_NAME.app"
APP_BINARY="$APP_DIR/Contents/MacOS/$APP_NAME"

case "$MODE" in
    run|--debug|--logs|--telemetry|--verify) ;;
    *) echo "Usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2; exit 2 ;;
esac

pkill -x "$APP_NAME" 2>/dev/null || true
cd "$ROOT_DIR"
swift build --product soundcorectl
BUILD_BINARY="$(swift build --show-bin-path)/soundcorectl"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BUILD_BINARY" "$APP_BINARY"
cp Resources/Info.plist "$APP_DIR/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP_DIR/Contents/Resources/AppIcon.icns"

PLIST="$APP_DIR/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable $APP_NAME" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundlePackageType string APPL" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :LSMinimumSystemVersion string 13.0" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :NSPrincipalClass string NSApplication" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$PLIST"
xattr -d com.apple.FinderInfo "$APP_DIR" 2>/dev/null || true
codesign --force --sign - "$APP_DIR"

case "$MODE" in
    --debug) exec lldb -- "$APP_BINARY" ;;
    --logs)
        open -n "$APP_DIR"
        touch /tmp/soundcorebridge.log
        exec tail -n 40 -F /tmp/soundcorebridge.log
        ;;
    --telemetry)
        open -n "$APP_DIR"
        exec /usr/bin/log stream --info --style compact --predicate 'process == "SoundcoreBridge"'
        ;;
    --verify)
        open -n "$APP_DIR"
        sleep 2
        pgrep -x "$APP_NAME" >/dev/null
        echo "Running: $APP_DIR"
        ;;
    run) open -n "$APP_DIR" ;;
esac
