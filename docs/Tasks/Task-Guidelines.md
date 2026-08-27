# Task Guidelines

Tasks track planned implementation work for Agile Airframe: new features, refactors, documentation changes, and requirement updates. Bugs and regressions belong in Issues.

## Authority and interfaces

- AirframeCore workflow policy and canonical records under `.airframe/state/` define current Task state.
- Use AICockpit for agent discovery, Task packets, evidence, and authorized transitions. Use AgileCockpit for human-only verification and closure.
- `docs/generated/Tasks/` is deterministic output from canonical state and must never be hand-edited.
- Files under `docs/Tasks/` are historical archives, compatibility views, or redirects. They are not workflow mutation surfaces or independent current-state authorities.
- GitHub is an optional synchronization backend, not the canonical record.

For documentation consistency work, follow [Audit Guidelines](../Audits/Audit-Guidelines.md), including its canonical authority order and Findings, Rulings, and Remediation phase gates.

## Lifecycle

```text
Backlog -> Active -> Implemented - Not Verified -> Implemented - Verified
        -> Closed
```

## Statuses

- **Backlog**: Proposed work not assigned to an active Sprint.
- **Active**: Work assigned to a Sprint and currently being implemented.
- **Implemented - Not Verified**: Implementation is complete and evidence/test steps are ready for user review.
- **Implemented - Verified**: User has explicitly verified the task.
- **Closed**: User has directed that the task should not proceed.

## Display Labels

- **Implemented** means **Implemented - Not Verified**.
- **Verified** means **Implemented - Verified**.

## GitHub Issue Mapping

GitHub mapping is optional. Canonical Task records must distinguish these mapping conditions with explicit system-supported states: backend not configured, intentionally local, pending synchronization, mapped, and mapping error. Until those states are implemented, a missing GitHub Issue is not by itself invalid under a local-only profile.

Rules:

- Create a GitHub Issue only when the workspace backend and requested workflow require one.
- A mapped GitHub Issue title must begin with `[T-XXXX]`.
- A mapped Task record must carry the backend mapping canonically; Markdown may project `**GitHub Issue:** #NNN`.
- The GitHub Issue body must include `Airframe Type: Task` and `Airframe ID: T-XXXX`.
- A GitHub Issue may not represent more than one Airframe Task.
- Canonical transitions must regenerate projections and synchronize an existing GitHub mapping when the backend is configured and reachable.
- Backend list and summary operations must paginate to completeness. Any incomplete result must disclose that it is partial, its applied limit and retrieved count, continuation state when available, and the reason it is incomplete.
- Synchronizing a previously human-Verified canonical state does not grant an agent authority to perform a new verification.

See `docs/procedures/GitHub-Issue-Sync-Procedure.md` for the required synchronization procedure.

## Authorization

AI Cockpit / agents may:

- Create backlog Tasks.
- Move an assigned Task to Active when implementation begins.
- Mark a Task Implemented - Not Verified after implementation and self-test.
- Add implementation details, evidence, and verification steps.

Only a human may:

- Mark a Task Implemented - Verified.
- Close a Task.
- Approve sprint or epic closure resulting from Task completion.

## File Organization

```text
docs/Tasks/
├── Task-Guidelines.md
├── Task-Documentation.md
├── Task-backlog.md
├── Task-active.md
├── Task-unverified.md
└── Verified/
    ├── Task-verified-XXXX.md
    └── Task-verified-XXXX-YYYY.md
```

Historical archives remain supported. Mutable working files and indexes must be retired as current-state authorities; a retained Legacy path must be either a deterministic canonical projection or an unambiguous redirect to `docs/generated/Tasks/` or AgileCockpit.

## Task Template

```markdown
## T-XXXX: [Brief Title]

**Status:** Backlog / Active / Implemented - Not Verified / Implemented - Verified / Closed
**GitHub Issue:** #NNN
**Component:** [Primary component]
**Priority:** Critical / High / Medium / Low
**Epic:** [EP-XXX or None]
**Sprint Assigned:** [SP-XXX or Not Assigned]
**Date Requested:** YYYY-MM-DD
**Date Implemented:** YYYY-MM-DD
**Date Verified:** YYYY-MM-DD

**Rationale:**
[Why this work is needed.]

**Current Behavior:**
[How the system currently works.]

**Desired Behavior:**
[How the system should work after completion.]

**Requirements:**
1. [Requirement]

**Acceptance Criteria:**
1. [Criterion]

**Design Approach:**
[Implementation approach.]

**Components Affected:**
- [Component]: [Impact]

**Implementation Details:**
[Filled in during implementation.]

**Evidence:**
- [Test command, screenshot, artifact, PR, or commit reference]

**Test Steps:**
1. [Step]

**Notes:**
[Tradeoffs, constraints, or follow-up.]
```

## Update Checklist

- Perform Task creation, assignment, implementation, verification, and closure through the authorized canonical interface.
- Retrieve the AICockpit Task packet before assigned implementation and attach evidence to canonical work records.
- Preserve the human-only boundary for verification and closure.
- Regenerate deterministic Task projections after canonical changes; do not hand-edit them.
- Synchronize mapped GitHub Issues when configured and reachable, reporting partial or failed synchronization explicitly.
- Preserve historical archives. Do not move or edit Legacy working files as the source of a status transition.
