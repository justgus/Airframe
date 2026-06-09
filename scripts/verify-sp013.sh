#!/usr/bin/env bash
set -euo pipefail

echo "== AirframeCore controlled mutation tests =="
swift test --package-path AirframeCore

echo "== AICockpit controlled mutation command tests =="
swift test --package-path AICockpit

echo "== Missing approval safety check =="
set +e
output="$(
  swift run --package-path AICockpit aicockpit github comment T-0067 \
    --backend github-issues \
    --body "SP-013 missing approval safety check" \
    --output json
)"
status=$?
set -e

if [[ "$status" -eq 0 ]]; then
  echo "verify-sp013: github comment unexpectedly succeeded without --approve" >&2
  exit 1
fi

if [[ "$output" != *"requires confirmation"* ]]; then
  echo "verify-sp013: missing approval output did not report confirmation requirement" >&2
  echo "$output" >&2
  exit 1
fi

echo "SP-013 verification passed."
