# Active Tasks

Tasks listed here are assigned to a Sprint and actively being implemented.

Currently: **5 active Tasks**

---

## T-0076: Define AgileCockpit planning operation contract

**Status:** Active
**GitHub Issue:** #77
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-015
**Sprint Assigned:** SP-015
**Date Requested:** 2026-06-10
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
AgileCockpit needs a clear planning operation contract before UI controls or backend mutations are added.

**Desired Behavior:**
Human planning actions have explicit authority, confirmation, backend capability, audit, and denial behavior.

**Requirements:**
1. Define allowed, denied, and unsupported planning actions for AgileCockpit.
2. Identify human-only actions and confirmation requirements.
3. Preserve AICockpit as agent-facing and non-human-acceptance only.

**Acceptance Criteria:**
1. The planning operation contract identifies each Slice 7 action and authority class.
2. Unsupported backend behavior is explicitly specified.
3. Follow-on implementation tasks can use the contract without inventing policy in UI code.

**Evidence:**
- TBD

## T-0077: Add AirframeCore planning APIs for artifact operations

**Status:** Active
**GitHub Issue:** #79
**Component:** AirframeCore
**Priority:** High
**Epic:** EP-015
**Sprint Assigned:** SP-015
**Date Requested:** 2026-06-10
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
AgileCockpit must route planning operations through AirframeCore instead of implementing workflow logic directly.

**Desired Behavior:**
AirframeCore exposes canonical planning operations for task/issue creation, assignment, transitions, sprint operations, and epic operations.

**Requirements:**
1. Add or extend Core APIs for artifact planning operations.
2. Enforce authority, workflow, and backend capability checks in AirframeCore.
3. Return structured results suitable for AgileCockpit display and tests.

**Acceptance Criteria:**
1. Core tests cover allowed, denied, and unsupported planning operations.
2. Existing AICockpit and AgileCockpit behavior remains compatible.
3. Backend capability limits are surfaced without silent mutation.

**Evidence:**
- TBD

## T-0078: Implement AgileCockpit task and issue planning UI

**Status:** Active
**GitHub Issue:** #80
**Component:** AgileCockpit
**Priority:** High
**Epic:** EP-015
**Sprint Assigned:** SP-015
**Date Requested:** 2026-06-10
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
AgileCockpit should become the human-facing surface for managing Tasks and Issues, not only viewing them.

**Desired Behavior:**
Authorized human users can create, review, and move Tasks and Issues through AirframeCore-backed UI controls.

**Requirements:**
1. Add task and issue planning controls to AgileCockpit.
2. Show backend capability and disabled states clearly.
3. Route all operations through AirframeCore.

**Acceptance Criteria:**
1. AgileCockpit tests cover task and issue planning UI behavior.
2. Denied or unsupported operations are visible and explain why.
3. No UI path bypasses AirframeCore authority or workflow checks.

**Evidence:**
- TBD

## T-0079: Implement AgileCockpit sprint and epic management UI

**Status:** Active
**GitHub Issue:** #78
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-015
**Sprint Assigned:** SP-015
**Date Requested:** 2026-06-10
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Sprint and Epic open/close and assignment controls are human planning actions that belong in AgileCockpit.

**Desired Behavior:**
Authorized human users can request sprint and epic management operations through confirmation-gated AgileCockpit controls.

**Requirements:**
1. Add sprint and epic management controls to AgileCockpit.
2. Require explicit confirmation for sensitive operations.
3. Use AirframeCore authority, workflow, and audit behavior for every operation.

**Acceptance Criteria:**
1. Sprint and epic controls are covered by tests.
2. Human-only close/open operations are not exposed to AICockpit.
3. Denied and unsupported operations produce clear UI status.

**Evidence:**
- TBD

## T-0080: Verify planning management workflow and documentation

**Status:** Active
**GitHub Issue:** #76
**Component:** AirframeCore / AICockpit / AgileCockpit / Documentation
**Priority:** Medium
**Epic:** EP-015
**Sprint Assigned:** SP-015
**Date Requested:** 2026-06-10
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Slice 7 changes planning workflow behavior across the core, CLI compatibility surface, GUI, and documentation.

**Desired Behavior:**
The planning management workflow is verified end to end with clear docs and no regression in AICockpit boundaries.

**Requirements:**
1. Verify AirframeCore planning APIs and authority behavior.
2. Verify AgileCockpit planning controls and denied/unsupported states.
3. Document the workflow and AICockpit/AgileCockpit responsibility split.

**Acceptance Criteria:**
1. Relevant Core, AICockpit, and AgileCockpit tests pass.
2. Documentation explains how humans manage planning through AgileCockpit.
3. AICockpit remains barred from human-only acceptance and closeout actions.

**Evidence:**
- TBD

---

T-0071 through T-0075 were human-verified on 2026-06-10 and moved to [Verified/Task-verified-0071-0075.md](Verified/Task-verified-0071-0075.md).

*Last Updated: 2026-06-10 (SP-015 activated with T-0076 through T-0080)*
