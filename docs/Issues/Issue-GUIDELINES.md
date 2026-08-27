# Issue Guidelines

Issues track bugs, regressions, and unintended behavior in Agile Airframe. Planned improvements belong in Tasks.

## Authority and interfaces

- AirframeCore workflow policy and canonical records under `.airframe/state/` define current Issue state.
- Use AICockpit for agent discovery, evidence, and authorized transitions. Use AgileCockpit for human-only verification and closure.
- `docs/generated/Issues/` is deterministic output from canonical state and must never be hand-edited.
- Files under `docs/Issues/` are historical archives, compatibility views, or redirects. They are not workflow mutation surfaces or independent current-state authorities.
- GitHub is an optional synchronization backend, not the canonical record.

For documentation consistency work, follow [Audit Guidelines](../Audits/Audit-Guidelines.md), including its canonical authority order and Findings, Rulings, and Remediation phase gates.

## Lifecycle

```text
Backlog -> In Progress -> Resolved - Not Verified -> Resolved - Verified
        -> Closed
```

## Statuses

- **Backlog**: Issue is defined but not assigned to an active Sprint or currently being worked.
- **In Progress**: Issue assigned to a Sprint and being investigated or fixed.
- **Resolved - Not Verified**: Fix is implemented and ready for human verification.
- **Resolved - Verified**: User has explicitly verified the fix.
- **Closed**: User has directed that the issue should be closed without verification.

## Display Labels

- **Resolved** means **Resolved - Not Verified**.
- **Verified** means **Resolved - Verified**.

## GitHub Issue Mapping

GitHub mapping is optional. Canonical Issue records must distinguish these mapping conditions with explicit system-supported states: backend not configured, intentionally local, pending synchronization, mapped, and mapping error. Until those states are implemented, a missing GitHub Issue is not by itself invalid under a local-only profile.

Rules:

- Create a GitHub Issue only when the workspace backend and requested workflow require one.
- A new GitHub Issue created without an Airframe ID is imported as a backlogged Airframe Issue by the nightly sync.
- A mapped GitHub Issue title must begin with `[I-XXXX]`.
- A mapped Issue record must carry the backend mapping canonically; Markdown may project `**GitHub Issue:** #NNN`.
- The GitHub Issue body must include `Airframe Type: Issue` and `Airframe ID: I-XXXX`.
- A GitHub Issue may not represent more than one Airframe Issue.
- Canonical transitions must regenerate projections and synchronize an existing GitHub mapping when the backend is configured and reachable.
- Backend list and summary operations must paginate to completeness. Any incomplete result must disclose that it is partial, its applied limit and retrieved count, continuation state when available, and the reason it is incomplete.
- Synchronizing a previously human-Verified canonical state does not grant an agent authority to perform a new verification.

See `docs/procedures/GitHub-Issue-Sync-Procedure.md` for the required synchronization procedure.

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

Historical archives remain supported. Mutable working files and indexes must be retired as current-state authorities; a retained Legacy path must be either a deterministic canonical projection or an unambiguous redirect to `docs/generated/Issues/` or AgileCockpit.

## Issue Template

```markdown
## I-XXXX: [Title]

**Status:** Backlog / In Progress / Resolved - Not Verified / Resolved - Verified / Closed
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

- Perform Issue creation, assignment, resolution, verification, and closure through the authorized canonical interface.
- Attach evidence to canonical records and preserve the human-only boundary for verification and closure.
- Regenerate deterministic Issue projections after canonical changes; do not hand-edit them.
- Synchronize mapped GitHub Issues when configured and reachable, reporting partial or failed synchronization explicitly.
- Preserve historical archives. Do not move or edit Legacy working files as the source of a status transition.
