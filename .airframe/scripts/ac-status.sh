#!/usr/bin/env bash
# Prints workspace context and project dashboard summary.
set -euo pipefail
source "$(dirname "$0")/_ac_common.sh"

ac_run context
echo ""
ac_run project summary --backend canonical --output json
