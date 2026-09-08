#!/usr/bin/env bash
set -euo pipefail

echo "error: scripts/import-github-issues.sh was retired by SP-042." >&2
echo "GitHub Issue import must create or update canonical records through AICockpit, then regenerate docs/generated/." >&2
echo "The Legacy Issue Markdown files are compatibility views and must not be mutated." >&2
exit 2
