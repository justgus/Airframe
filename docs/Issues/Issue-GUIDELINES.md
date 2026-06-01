# Issue Guidelines

Issues track bugs, regressions, and unintended behavior in Agile Airframe. Planned improvements belong in Tasks.

## Lifecycle

```text
Backlog -> Active -> Resolved - Not Verified -> Resolved - Verified
        -> Closed
```

## Statuses

- **Open**: Issue identified and in the backlog.
- **In Progress**: Issue assigned to a Sprint and being investigated or fixed.
- **Resolved - Not Verified**: Fix is implemented and ready for human verification.
- **Resolved - Verified**: User has explicitly verified the fix.
- **Closed**: User has directed that the issue should be closed without verification.

## GitHub Issue Mapping

Every Airframe Issue must have exactly one GitHub Issue number. Every GitHub Issue used for Issue tracking must identify exactly one Airframe Issue ID.

Rules:

- The GitHub Issue title must begin with `[I-XXXX]`.
- The Issue record must include `**GitHub Issue:** #NNN`.
- The GitHub Issue body must include `Airframe Type: Issue` and `Airframe ID: I-XXXX`.
- A GitHub Issue may not represent more than one Airframe Issue.
- Resolving, verifying, or closing an Issue must update both the local Issue record and the linked GitHub Issue.

## Authorization

AI Cockpit / agents may create Issues, move assigned Issues to In Progress, document root cause and resolution, and mark fixes Resolved - Not Verified.

Only a human may mark an Issue Resolved - Verified or close an Issue without verification.

## File Organization

```text
docs/Issues/
├── Issue-GUIDELINES.md
├── Issue-Documentation.md
├── Issue-backlog.md
├── Issue-active.md
├── Verified/
│   └── Issue-verified-XXXX-YYYY.md
└── Closed/
    └── Issue-closed-XXXX-YYYY.md
```

## Issue Template

```markdown
## I-XXXX: [Title]

**Status:** Open / In Progress / Resolved - Not Verified / Resolved - Verified / Closed
**GitHub Issue:** #NNN
**Platform:** macOS / iOS / visionOS / All platforms / Not applicable
**Component:** [Affected component]
**Severity:** Critical / High / Medium / Low
**Epic:** [EP-XXX or None]
**Sprint:** [SP-XXX or Not Assigned]
**Date Identified:** YYYY-MM-DD
**Fix Date:** YYYY-MM-DD
**Verification Date:** YYYY-MM-DD

**Description:**
[Problem description.]

**Expected Behavior:**
[Expected behavior.]

**Actual Behavior:**
[Actual behavior.]

**Steps to Reproduce:**
1. [Step]

**Impact:**
- [Impact]

**Root Cause Analysis:**
[Technical explanation.]

**Resolution:**
[Implementation details.]

**Files Affected:**
- `[path]`: [Change]

**Evidence:**
- [Test command, screenshot, artifact, PR, or commit reference]

**Verification:**
1. [Verification step]

**Related Items:**
- [Task, Sprint, or Epic reference]
```

## Update Checklist

- Update `Issue-Documentation.md` when an Issue is created, assigned, resolved, verified, or closed.
- Keep active unresolved Issues in `Issue-active.md`.
- Keep unassigned open Issues in `Issue-backlog.md`.
- Move verified and closed records into the appropriate archive folders.
