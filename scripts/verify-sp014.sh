#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
demo_dir="${AIRFRAME_LIVE_DEMO_DIR:-$repo_root/demos/LiveDemo}"
config_path="${AIRFRAME_CONFIG_PATH:-$repo_root/.airframe/airframe-workspace.json}"
tmp_dir="${TMPDIR:-/tmp}/airframe-sp014-verify"

rm -rf "$tmp_dir"
mkdir -p "$tmp_dir"

assert_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq "$expected" "$file"; then
    echo "verify-sp014: expected '$expected' in $file" >&2
    echo "---- $file ----" >&2
    cat "$file" >&2
    exit 1
  fi
}

run_with_timeout() {
  local seconds="$1"
  shift
  perl -e 'alarm shift @ARGV; exec @ARGV' "$seconds" "$@"
}

echo "== Install project-local demo artifacts =="
"$repo_root/scripts/install-live-demo.sh"

echo "== Verify installed artifact paths =="
test -x "$demo_dir/bin/aicockpit"
test -d "$demo_dir/Applications/AgileCockpit.app"

echo "== Verify live demo configuration points at SP-014 / EP-014 =="
assert_contains "$config_path" '"rawValue": "SP-014"'
assert_contains "$config_path" '"rawValue": "EP-014"'
assert_contains "$config_path" '"kind": "github-issues"'
assert_contains "$config_path" '"location": "justgus/Airframe"'

echo "== Verify installed aicockpit configuration diagnostics =="
"$demo_dir/bin/aicockpit" config diagnose \
  --config "$config_path" \
  --output json > "$tmp_dir/config-diagnose.json"
assert_contains "$tmp_dir/config-diagnose.json" '"status"'
assert_contains "$tmp_dir/config-diagnose.json" '"ok"'

echo "== Verify installed aicockpit live GitHub summary =="
run_with_timeout 60 "$demo_dir/bin/aicockpit" project summary \
  --config "$config_path" \
  --backend github-issues \
  --output json > "$tmp_dir/project-summary.json"
assert_contains "$tmp_dir/project-summary.json" '"github-issues"'
assert_contains "$tmp_dir/project-summary.json" '"totalWorkItemCount"'

echo "== Verify installed aicockpit next task =="
run_with_timeout 60 "$demo_dir/bin/aicockpit" task next \
  --config "$config_path" \
  --backend github-issues \
  --output json > "$tmp_dir/task-next.json"
assert_contains "$tmp_dir/task-next.json" '"T-0071"'

echo "== Verify installed aicockpit task packet =="
run_with_timeout 60 "$demo_dir/bin/aicockpit" task packet T-0071 \
  --config "$config_path" \
  --backend github-issues \
  --output json > "$tmp_dir/task-packet-T-0071.json"
assert_contains "$tmp_dir/task-packet-T-0071.json" '"T-0071"'
assert_contains "$tmp_dir/task-packet-T-0071.json" 'Slice 6'

echo "== Verify controlled GitHub write approval gate =="
set +e
run_with_timeout 30 "$demo_dir/bin/aicockpit" github comment T-0074 \
  --config "$config_path" \
  --backend github-issues \
  --body "SP-014 missing approval safety check" \
  --output json > "$tmp_dir/missing-approval.json" 2>&1
status=$?
set -e

if [[ "$status" -eq 0 ]]; then
  echo "verify-sp014: github comment unexpectedly succeeded without --approve" >&2
  cat "$tmp_dir/missing-approval.json" >&2
  exit 1
fi
assert_contains "$tmp_dir/missing-approval.json" "requires confirmation"

echo "== Verify AgileCockpit automated tests =="
xcodebuild \
  -workspace "$repo_root/Airframe.xcworkspace" \
  -scheme AgileCockpit \
  -destination 'platform=macOS' \
  -derivedDataPath "$demo_dir/DerivedData" \
  test

echo "SP-014 verification passed."
