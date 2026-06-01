#!/usr/bin/env bash
set -euo pipefail

repo="${GITHUB_REPOSITORY:-justgus/Airframe}"
today="$(date +%F)"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

require_cmd gh
require_cmd jq
require_cmd perl

next_issue_id() {
  local max_id
  max_id="$(
    {
      grep -Rho '^## I-[0-9][0-9][0-9][0-9]:' docs/Issues 2>/dev/null | sed 's/^## I-//; s/:$//' || true
      grep -ho '^| I-[0-9][0-9][0-9][0-9] |' docs/GitHub-Issue-Mapping.md 2>/dev/null | sed 's/^| I-//; s/ |$//' || true
    } | sed 's/I-//' | sort -n | tail -1
  )"
  if [[ -z "$max_id" ]]; then
    printf 'I-0001'
  else
    printf 'I-%04d' "$((10#$max_id + 1))"
  fi
}

update_issue_documentation() {
  local count next_id
  count="$(grep -c '^## I-[0-9][0-9][0-9][0-9]:' docs/Issues/Issue-backlog.md 2>/dev/null || true)"
  next_id="$(next_issue_id)"

  perl -0pi -e "s/Currently: \\*\\*\\d+ backlogged Issues\\*\\*/Currently: **$count backlogged Issues**/g" docs/Issues/Issue-Documentation.md
  perl -0pi -e "s/- \\*\\*Total Issues:\\*\\* \\d+/- **Total Issues:** $count/g" docs/Issues/Issue-Documentation.md
  perl -0pi -e "s/- \\*\\*Backlogged:\\*\\* \\d+/- **Backlogged:** $count/g" docs/Issues/Issue-Documentation.md
  perl -0pi -e "s/- \\*\\*Next available:\\*\\* I-[0-9][0-9][0-9][0-9]/- **Next available:** $next_id/g" docs/Issues/Issue-Documentation.md
  perl -0pi -e "s/Currently: \\*\\*\\d+ verified Issues\\*\\* \\| Next available: \\*\\*I-[0-9][0-9][0-9][0-9]\\*\\*/Currently: **0 verified Issues** | Next available: **$next_id**/g" docs/Issues/Issue-Documentation.md
  perl -0pi -e "s/\\*Last Updated: .*?\\*/\\*Last Updated: $today (GitHub issue sync)\\*/g" docs/Issues/Issue-Documentation.md
}

insert_backlog_index_row() {
  local id="$1" gh_number="$2" title="$3" severity="$4"
  perl -0pi -e "s/(\\| ----- \\| ------------ \\| ----- \\| -------- \\| ------ \\|\\n)/\$1| $id | #$gh_number | $title | $severity | Open |\\n/" docs/Issues/Issue-Documentation.md
}

append_issue_backlog_entry() {
  local id="$1" gh_number="$2" title="$3" body="$4" severity="$5"
  perl -0pi -e "s/\\n\\*No backlogged Issues\\.\\*\\n//g" docs/Issues/Issue-backlog.md
  cat >> docs/Issues/Issue-backlog.md <<EOF

## $id: $title

**Status:** Open
**GitHub Issue:** #$gh_number
**Platform:** Not applicable
**Component:** TBD
**Severity:** $severity
**Epic:** None
**Sprint:** Not Assigned
**Date Identified:** $today
**Fix Date:** TBD
**Verification Date:** TBD

**Description:**
Imported from GitHub Issue #$gh_number.

$(printf '%s\n' "$body" | sed 's/^/> /')

**Expected Behavior:**
TBD.

**Actual Behavior:**
TBD.

**Steps to Reproduce:**
1. TBD.

**Impact:**
- TBD.

**Root Cause Analysis:**
TBD.

**Resolution:**
TBD.

**Files Affected:**
- TBD.

**Evidence:**
- GitHub Issue #$gh_number

**Verification:**
1. TBD.

**Related Items:**
- None.

---
EOF
  perl -0pi -e "s/\\*Last Updated: .*?\\*/\\*Last Updated: $today (GitHub issue sync)\\*/g" docs/Issues/Issue-backlog.md
}

append_mapping_entry() {
  local id="$1" gh_number="$2" title="$3"
  if grep -q '^No Airframe Issues are currently defined' docs/GitHub-Issue-Mapping.md; then
    perl -0pi -e 's/No Airframe Issues are currently defined\. Next local Issue ID: `I-[0-9]{4}`\./| Airframe Issue | GitHub Issue | Title |\n| -------------- | ------------ | ----- |/g' docs/GitHub-Issue-Mapping.md
  fi
  perl -0pi -e "s/(## Current Issue Mapping\\n\\n(?:\\|[^\\n]*\\n)+)/\$1| $id | #$gh_number | $title |\\n/s" docs/GitHub-Issue-Mapping.md
  perl -0pi -e "s/\\*Last Updated: .*?\\*/\\*Last Updated: $today (GitHub issue sync)\\*/g" docs/GitHub-Issue-Mapping.md
}

issues_json="$(gh issue list --repo "$repo" --state open --limit 1000 --json number,title,body,labels)"

imported=0

while read -r issue; do
  number="$(jq -r '.number' <<<"$issue")"
  title="$(jq -r '.title' <<<"$issue")"
  body="$(jq -r '.body // ""' <<<"$issue")"

  if [[ "$title" =~ ^\[(T|I)-[0-9]{4}\] ]] || grep -q 'Airframe ID:' <<<"$body"; then
    continue
  fi

  id="$(next_issue_id)"
  severity="Medium"
  new_title="[$id] $title"
  new_body="$(printf 'Airframe Type: Issue\nAirframe ID: %s\nSeverity: %s\nStatus: Open\n\nImported from GitHub Issue #%s during nightly sync.\n\n---\n\n%s' "$id" "$severity" "$number" "$body")"

  gh issue edit "$number" --repo "$repo" --title "$new_title" --body "$new_body" --add-label airframe-issue --add-label status-backlog >/dev/null
  insert_backlog_index_row "$id" "$number" "$title" "$severity"
  append_issue_backlog_entry "$id" "$number" "$title" "$body" "$severity"
  append_mapping_entry "$id" "$number" "$title"
  imported=$((imported + 1))
  echo "Imported GitHub Issue #$number as $id"
done < <(echo "$issues_json" | jq -c '.[]')

if [[ "$imported" -gt 0 ]]; then
  update_issue_documentation
fi

echo "GitHub issue import complete. Imported: $imported."
