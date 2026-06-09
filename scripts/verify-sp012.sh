#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
demo_dir="${AIRFRAME_LIVE_DEMO_DIR:-$repo_root/demos/LiveDemo}"
config_path="${AIRFRAME_CONFIG_PATH:-$repo_root/.airframe/airframe-workspace.json}"

echo "== Install project-local demo artifacts =="
"$repo_root/scripts/install-live-demo.sh"

echo "== Verify installed artifact paths =="
test -x "$demo_dir/bin/aicockpit"
test -d "$demo_dir/Applications/AgileCockpit.app"

echo "== Verify installed aicockpit configuration =="
"$demo_dir/bin/aicockpit" config diagnose \
  --config "$config_path" \
  --output json

echo "== Verify installed aicockpit live GitHub summary =="
"$demo_dir/bin/aicockpit" project summary \
  --config "$config_path" \
  --backend github-issues \
  --output json

echo "== Verify AgileCockpit automated tests =="
xcodebuild \
  -workspace "$repo_root/Airframe.xcworkspace" \
  -scheme AgileCockpit \
  -destination 'platform=macOS' \
  -derivedDataPath "$demo_dir/DerivedData" \
  test

echo "SP-012 verification passed."
