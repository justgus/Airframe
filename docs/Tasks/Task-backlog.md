# Task Backlog

Tasks listed here are proposed and not assigned to an active Sprint.

Currently: **6 backlog Tasks**

---

## T-0154: Define canonical plan review record and decision model

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AirframeCore canonical model
**Priority:** Medium
**Epic:** EP-023
**Sprint Assigned:** SP-036

**Acceptance Criteria:**
1. Canonical state can represent proposed implementation plans, including scope, file changes, commands, external effects, and verification criteria.
2. Plan decision state supports pending, approved, deferred, and rejected outcomes.
3. Plan records link to target Epic, Sprint, Tasks, actor context, and audit or evidence records where applicable.

## T-0155: Add AirframeCore authority and audit support for plan decisions

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AirframeCore authority and audit policy
**Priority:** Medium
**Epic:** EP-023
**Sprint Assigned:** SP-036

**Acceptance Criteria:**
1. Approve, defer, and reject plan decisions require human authority.
2. Agents cannot approve their own implementation plans.
3. Plan decisions emit auditable decision records without weakening verification or closeout gates.

## T-0156: Add AICockpit plan submission and read commands

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AICockpit agent-facing plan proposal commands
**Priority:** Medium
**Epic:** EP-023
**Sprint Assigned:** SP-036

**Acceptance Criteria:**
1. AICockpit can submit a proposed implementation plan to canonical state.
2. AICockpit can read plan status and details for agent workflow coordination.
3. AICockpit cannot approve, defer, reject, verify, or close plan-controlled work through human-only paths.

## T-0157: Add AgileCockpit plan review UI

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AgileCockpit human-facing plan review surface
**Priority:** Medium
**Epic:** EP-023
**Sprint Assigned:** SP-036

**Acceptance Criteria:**
1. AgileCockpit displays proposed plan scope, file changes, commands, external effects, and verification criteria.
2. The plan review surface clearly shows current decision state and target work context.
3. Plan review UI remains distinct from implementation verification and Sprint/Epic closeout UI.

## T-0158: Wire AgileCockpit human plan decision actions

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AgileCockpit approve defer reject actions through AirframeCore
**Priority:** Medium
**Epic:** EP-023
**Sprint Assigned:** SP-036

**Acceptance Criteria:**
1. A human reviewer can approve, defer, or reject a proposed plan from AgileCockpit.
2. Decision actions update canonical plan state and audit or evidence records as designed.
3. AICockpit and other agent contexts remain unable to perform human-only plan decision actions.

## T-0159: Add plan review regression coverage and workflow documentation

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** Regression coverage and documentation for plan review workflow
**Priority:** Medium
**Epic:** EP-023
**Sprint Assigned:** SP-036

**Acceptance Criteria:**
1. Regression tests cover canonical model, command, UI, and authority boundaries for plan review.
2. Documentation explains plan submission, human approval, deferral, rejection, and implementation handoff.
3. Verification evidence identifies commands run and residual risks.

---
*Last Updated: 2026-07-06*
