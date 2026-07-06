#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

without_github_credentials() {
  env \
    -u GH_TOKEN \
    -u GITHUB_TOKEN \
    -u GITHUB_ENTERPRISE_TOKEN \
    -u AIRFRAME_GITHUB_TOKEN \
    "$@"
}

echo "== Offline regression assumptions =="
echo "- Repository: $repo_root"
echo "- GitHub token environment variables are removed for verification commands."
echo "- Tests must use local fixtures, canonical state, or explicitly stubbed transports."
echo

echo "== AirframeCore offline regression =="
without_github_credentials swift test --package-path "$repo_root/AirframeCore"
echo

echo "== AICockpit offline regression =="
without_github_credentials swift test --package-path "$repo_root/AICockpit"
echo

echo "== AgileCockpit offline regression =="
without_github_credentials xcodebuild \
  test \
  -project "$repo_root/AgileCockpit/AgileCockpit.xcodeproj" \
  -scheme AgileCockpit \
  -destination 'platform=macOS'

