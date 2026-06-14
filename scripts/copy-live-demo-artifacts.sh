#!/usr/bin/env bash
set -euo pipefail

if [[ "${AIRFRAME_SKIP_LIVE_DEMO_INSTALL:-0}" == "1" ]]; then
  echo "LiveDemo artifact copy skipped because AIRFRAME_SKIP_LIVE_DEMO_INSTALL=1."
  exit 0
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
demo_dir="${AIRFRAME_LIVE_DEMO_DIR:-$repo_root/demos/LiveDemo}"
swift_scratch_path="$demo_dir/.build/aicockpit"

mkdir -p "$demo_dir/bin" "$demo_dir/Applications"

if [[ -z "${BUILT_PRODUCTS_DIR:-}" ]]; then
  echo "copy-live-demo-artifacts: BUILT_PRODUCTS_DIR is not set" >&2
  exit 1
fi

agile_app_path="$BUILT_PRODUCTS_DIR/AgileCockpit.app"
if [[ ! -d "$agile_app_path" ]]; then
  echo "copy-live-demo-artifacts: expected app artifact at $agile_app_path" >&2
  exit 1
fi

swift build \
  --package-path "$repo_root/AICockpit" \
  --scratch-path "$swift_scratch_path" \
  -c debug \
  --product aicockpit

aicockpit_bin_path="$(
  swift build \
    --package-path "$repo_root/AICockpit" \
    --scratch-path "$swift_scratch_path" \
    -c debug \
    --show-bin-path
)/aicockpit"

install -m 755 "$aicockpit_bin_path" "$demo_dir/bin/aicockpit"
rm -rf "$demo_dir/Applications/AgileCockpit.app"
ditto "$agile_app_path" "$demo_dir/Applications/AgileCockpit.app"

installed_app_path="$demo_dir/Applications/AgileCockpit.app"
rm -rf "$installed_app_path/Contents/PlugIns"
rm -rf "$installed_app_path/Contents/Frameworks"/XCTest*.framework
rm -rf "$installed_app_path/Contents/Frameworks"/XCT*.framework
rm -rf "$installed_app_path/Contents/Frameworks"/XCUIAutomation.framework
rm -rf "$installed_app_path/Contents/Frameworks"/Testing.framework
rm -f "$installed_app_path/Contents/Frameworks"/libXCTestSwiftSupport.dylib
sign_identity="${AIRFRAME_LIVE_DEMO_SIGN_IDENTITY:--}"
binary_sign_args=(--force --sign "$sign_identity")
bundle_sign_args=(--force --sign "$sign_identity")
if [[ "$sign_identity" != "-" && "${ENABLE_HARDENED_RUNTIME:-NO}" == "YES" ]]; then
  binary_sign_args+=(--options runtime)
  bundle_sign_args+=(--options runtime)
fi
xcent_path="${TARGET_TEMP_DIR:-}/AgileCockpit.app.xcent"
if [[ -f "$xcent_path" ]]; then
  bundle_sign_args+=(--entitlements "$xcent_path")
fi
find "$installed_app_path/Contents/MacOS" -type f -perm -111 -print0 |
  while IFS= read -r -d '' executable_path; do
    codesign "${binary_sign_args[@]}" "$executable_path"
  done
codesign "${bundle_sign_args[@]}" "$installed_app_path"

echo "Installed LiveDemo artifacts:"
echo "CLI: $demo_dir/bin/aicockpit"
echo "App: $installed_app_path"
