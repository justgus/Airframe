#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

demo_dir="${AIRFRAME_LIVE_DEMO_DIR:-$repo_root/demos/LiveDemo}"
config_path="${AIRFRAME_CONFIG_PATH:-$repo_root/.airframe/airframe-workspace.json}"
swift_scratch_path="$demo_dir/.build/aicockpit"
derived_data_path="$demo_dir/DerivedData"

mkdir -p "$demo_dir/bin" "$demo_dir/Applications"

echo "== Build aicockpit =="
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

echo "== Build AgileCockpit.app =="
xcodebuild \
  -workspace "$repo_root/Airframe.xcworkspace" \
  -scheme AgileCockpit \
  -destination 'platform=macOS' \
  -configuration Debug \
  -derivedDataPath "$derived_data_path" \
  build

agile_app_path="$derived_data_path/Build/Products/Debug/AgileCockpit.app"
if [[ ! -d "$agile_app_path" ]]; then
  echo "install-live-demo: expected app artifact was not built at $agile_app_path" >&2
  exit 1
fi

rm -rf "$demo_dir/Applications/AgileCockpit.app"
ditto "$agile_app_path" "$demo_dir/Applications/AgileCockpit.app"

echo "== Installed project-local demo artifacts =="
echo "Config: $config_path"
echo "CLI: $demo_dir/bin/aicockpit"
echo "App: $demo_dir/Applications/AgileCockpit.app"
