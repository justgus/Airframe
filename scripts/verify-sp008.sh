#!/usr/bin/env bash
set -euo pipefail

echo "== AirframeCore =="
swift test --package-path AirframeCore

echo "== AICockpit =="
swift test --package-path AICockpit

echo "== AgileCockpit =="
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test

echo "SP-008 verification passed."
