# Task Guidelines

Tasks track planned implementation work for Agile Airframe: new features, refactors, documentation changes, and requirement updates. Bugs and regressions belong in Issues.

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

## Task Template

```markdown
## T-XXXX: [Brief Title]

**Status:** Backlog / Active / Implemented - Not Verified / Implemented - Verified / Closed
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

- Update `Task-Documentation.md` whenever a Task is created, changes status, changes Sprint/Epic assignment, or is verified.
- Move detailed entries between `Task-backlog.md`, `Task-active.md`, `Task-unverified.md`, and `Verified/` as their status changes.
- Keep only one source of detailed Task truth for each active work item.
