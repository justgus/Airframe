# Enhancement Request Guidelines

Enhancement Requests track larger proposed capabilities, requirement changes, and intentional evolution of Agile Airframe. Smaller implementation items may be represented as Tasks.

## Lifecycle

```text
Proposed -> In Progress -> Implemented - Not Verified -> Implemented - Verified
         -> Closed
```

## Authorization

AI Cockpit / agents may create proposed ERs, document requirements, implement approved work, and mark ERs Implemented - Not Verified.

Only a human may mark an ER Implemented - Verified, approve or reject proposed enhancements, change priority, or close an ER.

## File Organization

```text
docs/ERs/
├── ER-Guidelines.md
├── ER-Documentation.md
├── ER-unverified.md
└── Verified/
    └── ER-verified-XXXX.md
```

## ER Template

```markdown
## ER-XXXX: [Brief Title]

**Status:** Proposed / In Progress / Implemented - Not Verified / Implemented - Verified / Closed
**Component:** [Primary component]
**Priority:** Critical / High / Medium / Low
**Epic:** [EP-XXX or None]
**Sprint:** [SP-XXX or Not Assigned]
**Date Requested:** YYYY-MM-DD
**Date Implemented:** YYYY-MM-DD
**Date Verified:** YYYY-MM-DD

**Rationale:**
[Why this enhancement is needed.]

**Current Behavior:**
[Current behavior.]

**Desired Behavior:**
[Desired behavior.]

**Requirements:**
1. [Requirement]

**Acceptance Criteria:**
1. [Criterion]

**Design Approach:**
[Approach.]

**Components Affected:**
- [Component]: [Impact]

**Implementation Details:**
[Filled in during implementation.]

**Evidence:**
- [Test command, artifact, PR, or commit reference]

**Test Steps:**
1. [Verification step]

**Notes:**
[Tradeoffs or follow-up.]
```

## Update Checklist

- Update `ER-Documentation.md` whenever an ER is created, changes status, is verified, or is closed.
- Keep proposed, in-progress, and implemented-but-unverified ERs in `ER-unverified.md`.
- Move verified ERs into `Verified/`.
