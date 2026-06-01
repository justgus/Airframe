# Discrepancy Report Guidelines

Discrepancy Reports are formal defect records for problems that require documented reproduction, root cause, resolution, and verification. For ordinary implementation bugs, use Issues unless the user requests a formal DR.

## Lifecycle

```text
Open -> In Progress -> Resolved - Not Verified -> Resolved - Verified
     -> Closed
```

## Authorization

AI Cockpit / agents may create DRs, investigate, implement fixes, document root cause, and mark DRs Resolved - Not Verified.

Only a human may mark a DR Resolved - Verified or close a DR without verification.

## File Organization

```text
docs/DRs/
├── DR-GUIDELINES.md
├── DR-Documentation.md
├── DR-unverified.md
├── Verified/
│   └── DR-verified-XXXX-YYYY.md
└── Closed/
    └── DR-closed-XXXX-YYYY.md
```

## DR Template

```markdown
## DR-XXXX: [Title]

**Status:** Open / In Progress / Resolved - Not Verified / Resolved - Verified / Closed
**Platform:** macOS / iOS / visionOS / All platforms / Not applicable
**Component:** [Affected component]
**Severity:** Critical / High / Medium / Low
**Sprint:** [SP-XXX or Not Assigned]
**Date Identified:** YYYY-MM-DD
**Fix Date:** YYYY-MM-DD
**Verification Date:** YYYY-MM-DD

**Description:**
[Clear description of the discrepancy.]

**Expected Behavior:**
[What should happen.]

**Actual Behavior:**
[What actually happens.]

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
- [Test command, artifact, PR, or commit reference]

**Verification:**
1. [Verification step]

**Related Items:**
- [Issue, Task, ER, Sprint, or Epic reference]
```

## Update Checklist

- Update `DR-Documentation.md` when a DR is created, changes status, is verified, or is closed.
- Keep unresolved or unverified DRs in `DR-unverified.md`.
- Move verified and closed DRs into the appropriate archive folders.
