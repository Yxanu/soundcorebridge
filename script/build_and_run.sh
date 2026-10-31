#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="SoundcoreBridge"
OUTPUT_DIR="$ROOT_DIR/build"

case "$MODE" in
    run|--debug|--logs|--telemetry|--verify) ;;
    *) echo "Usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2; exit 2 ;;
esac

pkill -x "$APP_NAME" 2>/dev/null || true
cd "$ROOT_DIR"
swift build --product soundcorectl
BUILD_BINARY="$(swift build --show-bin-path)/soundcorectl"
# File Provider attaches FinderInfo to bundles under Documents, even inside a
# .nosync directory on this host. Sign and launch a clean temporary bundle, and
# archive that exact bundle for a portable copy in the workspace.
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/soundcorebridge-build.XXXXXX")"
APP_DIR="$STAGING_DIR/$APP_NAME.app"
APP_BINARY="$APP_DIR/Contents/MacOS/$APP_NAME"
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
xattr -dr com.apple.FinderInfo "$APP_DIR" 2>/dev/null || true
codesign --force --sign - "$APP_DIR"
codesign --verify --strict "$APP_DIR"
mkdir -p "$OUTPUT_DIR"
ARCHIVE_PATH="$OUTPUT_DIR/SoundcoreBridge-Liberty5.zip"
ditto -c -k --norsrc --keepParent "$APP_DIR" "$ARCHIVE_PATH"
echo "Portable app: $ARCHIVE_PATH"

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
