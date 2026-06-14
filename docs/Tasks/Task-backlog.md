# Task Backlog

Tasks listed here are proposed and not assigned to an active Sprint.

Currently: **10 backlog Tasks**

---

## T-0091: Define AICockpit work item mutation command contract

**Status:** Backlog
**GitHub Issue:** #91
**Component:** AICockpit / Documentation
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-018
**Date Requested:** 2026-06-12
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
AICockpit needs explicit command contracts for creating and updating work items locally and on GitHub.

**Acceptance Criteria:**
1. Commands are defined for creating and updating Tasks, Issues, Sprints, and Epics.
2. Local and GitHub behavior is specified.
3. Approval and authority requirements are specified.
4. AICockpit is explicitly prohibited from applying Verified to Tasks or Issues.

**Evidence:**
- TBD

## T-0092: Implement AICockpit local work item mutation support

**Status:** Backlog
**GitHub Issue:** #92
**Component:** AICockpit / AirframeCore
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-018
**Date Requested:** 2026-06-12
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Agents need local mutation capability that preserves AirframeCore workflow policy and local artifact consistency.

**Acceptance Criteria:**
1. AICockpit can create local Tasks, Issues, Sprints, and Epics.
2. AICockpit can update allowed local work item fields and statuses.
3. Invalid transitions are rejected through AirframeCore.
4. Attempts to apply Task or Issue Verified are rejected.

**Evidence:**
- TBD

## T-0093: Implement controlled GitHub work item mutation support

**Status:** Backlog
**GitHub Issue:** #93
**Component:** AICockpit / AirframeCore GitHub Backend
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-018
**Date Requested:** 2026-06-12
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
GitHub-backed projects need controlled creation and update of mapped GitHub Issues with auditability and explicit approval.

**Acceptance Criteria:**
1. AICockpit can create mapped GitHub Issues for Tasks and Issues with explicit approval.
2. AICockpit can update allowed GitHub metadata and labels with explicit approval.
3. GitHub status labels stay synchronized with local workflow status.
4. AICockpit rejects status-verified for Tasks and Issues, even with approval.

**Evidence:**
- TBD

## T-0094: Add AICockpit Sprint and Epic planning mutation support

**Status:** Backlog
**GitHub Issue:** #94
**Component:** AICockpit / AirframeCore
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-018
**Date Requested:** 2026-06-12
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Planning work should be manageable through AICockpit without granting human-only closure authority.

**Acceptance Criteria:**
1. AICockpit can create and update Sprint backlog and Planning records.
2. AICockpit can create and update Epic Proposed, Draft, Backlog, and Active records where policy allows.
3. AICockpit cannot perform human-only Sprint or Epic closure.

**Evidence:**
- TBD

## T-0095: Verify AICockpit mutation authority boundaries

**Status:** Backlog
**GitHub Issue:** #95
**Component:** Verification
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-018
**Date Requested:** 2026-06-12
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
AICockpit mutation support must prove it can do allowed planning work and cannot bypass human-only authority.

**Acceptance Criteria:**
1. Tests prove local create/update commands work for allowed artifacts.
2. Tests prove GitHub create/update commands require explicit approval.
3. Tests prove AICockpit cannot verify Tasks or Issues locally or on GitHub.
4. Tests prove human-only Sprint/Epic closure remains blocked.

**Evidence:**
- TBD

## T-0096: Define AgileCockpit human mutation authority contract

**Status:** Backlog
**GitHub Issue:** #96
**Component:** AgileCockpit / Documentation
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-019
**Date Requested:** 2026-06-12
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
If AICockpit cannot apply Verified, AgileCockpit must own the human-facing verification mutation path.

**Acceptance Criteria:**
1. AgileCockpit authority for Task and Issue verification is documented.
2. Required human context and audit evidence are documented.
3. AICockpit and AgileCockpit mutation boundaries are explicit.

**Evidence:**
- TBD

## T-0097: Implement AgileCockpit local verification mutations

**Status:** Backlog
**GitHub Issue:** #97
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-019
**Date Requested:** 2026-06-12
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
The human-facing app needs to apply local Verified status to Tasks and Issues under human authority.

**Acceptance Criteria:**
1. AgileCockpit can mark Tasks Implemented - Verified locally.
2. AgileCockpit can mark Issues Resolved - Verified locally.
3. Verification writes create audit evidence.

**Evidence:**
- TBD

## T-0098: Implement AgileCockpit controlled GitHub verification mutations

**Status:** Backlog
**GitHub Issue:** #98
**Component:** AgileCockpit / AirframeCore GitHub Backend
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-019
**Date Requested:** 2026-06-12
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Human verification in AgileCockpit must synchronize status-verified to mapped GitHub Issues when using the GitHub backend.

**Acceptance Criteria:**
1. AgileCockpit can apply status-verified to mapped Task GitHub Issues through human context.
2. AgileCockpit can apply status-verified to mapped Issue GitHub Issues through human context.
3. GitHub verification writes produce audit evidence.

**Evidence:**
- TBD

## T-0099: Add human verification UI flows for Tasks and Issues

**Status:** Backlog
**GitHub Issue:** #99
**Component:** AgileCockpit
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-019
**Date Requested:** 2026-06-12
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Human users need an ergonomic route from verification candidates to verification action.

**Acceptance Criteria:**
1. Dashboard and verification views expose eligible Task verification actions.
2. Dashboard and verification views expose eligible Issue verification actions.
3. Verification UI distinguishes Implemented/Resolved from Verified.

**Evidence:**
- TBD

## T-0100: Verify AICockpit and AgileCockpit authority separation

**Status:** Backlog
**GitHub Issue:** #100
**Component:** Verification
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-019
**Date Requested:** 2026-06-12
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
The system must prove agent-facing and human-facing mutation authority are separated end to end.

**Acceptance Criteria:**
1. Tests prove AICockpit cannot apply Task or Issue Verified.
2. Tests prove AgileCockpit can apply Task or Issue Verified through human context.
3. Tests prove audit records distinguish agent and human mutation paths.
4. Tests prove unauthorized Sprint/Epic closure remains blocked.

**Evidence:**
- TBD

---

T-0066 through T-0070 were moved to active SP-013 implementation on 2026-06-09.

*Last Updated: 2026-06-12 (T-0086 through T-0100 added to backlog)*
