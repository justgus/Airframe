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

installed_app_path="$demo_dir/Applications/AgileCockpit.app"
install_stamp_path="$installed_app_path/Contents/AirframeInstallStamp.txt"
install_time_utc="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
git_commit="$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null || echo unknown)"
source_executable_path="$agile_app_path/Contents/MacOS/AgileCockpit"
installed_executable_path="$installed_app_path/Contents/MacOS/AgileCockpit"
source_executable_mtime="$(stat -f '%Sm' -t '%Y-%m-%dT%H:%M:%S%z' "$source_executable_path" 2>/dev/null || echo unknown)"
installed_executable_mtime="$(stat -f '%Sm' -t '%Y-%m-%dT%H:%M:%S%z' "$installed_executable_path" 2>/dev/null || echo unknown)"
aicockpit_mtime="$(stat -f '%Sm' -t '%Y-%m-%dT%H:%M:%S%z' "$demo_dir/bin/aicockpit" 2>/dev/null || echo unknown)"
cat > "$install_stamp_path" <<STAMP
Installed-At-UTC: $install_time_utc
Git-Commit: $git_commit
Source-App: $agile_app_path
Installed-App: $installed_app_path
Source-Executable-MTime: $source_executable_mtime
Installed-Executable-MTime: $installed_executable_mtime
AICockpit-MTime: $aicockpit_mtime
STAMP
touch "$installed_app_path"

echo "== Installed project-local demo artifacts =="
echo "Config: $config_path"
echo "CLI: $demo_dir/bin/aicockpit"
echo "App: $installed_app_path"
echo "Install Stamp: $install_stamp_path"
