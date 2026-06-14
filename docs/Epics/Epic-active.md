# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

---

## EP-017: Workflow Status Dashboard and Mutation Authority

**Status:** Active
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-12
**Target Close Date:** TBD
**Close Date:** TBD

**Goal:**
Make AgileCockpit’s dashboard reflect Airframe’s artifact-specific workflow statuses, add drill-down visibility from status counts to item details, enforce Agile authorization before implementation, and define the mutation boundaries between AICockpit and AgileCockpit.

**Rationale:**
The current dashboard metrics are task-centric and do not expose the full workflow state for Epics, Sprints, Tasks, and Issues. The planning flow also revealed that AICockpit cannot yet create or update work items, while AgileCockpit must own human-only verification mutations that AICockpit is forbidden to perform.

**Scope:**
- Replace generic dashboard metrics with artifact-specific workflow status tiles.
- Add status row drill-down from counts to ID/title lists and rendered item details.
- Add process guardrails preventing implementation without Epic, Sprint, and Task authorization.
- Add AICockpit local and GitHub work item create/update capability, excluding Task/Issue verification.
- Add AgileCockpit human-facing verification mutation capability for Tasks and Issues.

**Out of Scope:**
- AICockpit applying Verified status to Tasks or Issues.
- AICockpit performing human-only Sprint or Epic closure.
- Silent or implicit GitHub mutation without explicit approval.
- Implementing the draft patch before an assigned Sprint is active.

**Acceptance Criteria:**
1. Dashboard status tiles show Epics, Sprints, Tasks, and Issues with valid workflow statuses and counts.
2. Status labels use smaller text than entity/tile labels, and defined status symbols appear beside status labels.
3. Status rows open matching work item lists, and work items open rendered details.
4. AICockpit can create and update work items locally and on GitHub under authority and approval rules.
5. AICockpit cannot apply Verified to any Task or Issue, locally or on GitHub, even with approval.
6. AgileCockpit can apply human-only Task and Issue verification mutations with audit evidence.
7. Future implementation work requires an Epic, active Sprint, and assigned Task preflight.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-017 | Deliver workflow status dashboard and process guardrails | Active |
| SP-018 | Add AICockpit local and GitHub work item mutation support | Backlog |
| SP-019 | Add AgileCockpit human verification mutations | Backlog |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0086 | Reconcile Agile artifact workflow documentation and process guardrails | Implemented - Not Verified |
| T-0087 | Define artifact-specific status presentation model | Implemented - Not Verified |
| T-0088 | Replace dashboard metrics with workflow status tiles | Implemented - Not Verified |
| T-0089 | Add interactive dashboard status drill-down | Implemented - Not Verified |
| T-0090 | Verify dashboard workflow and integrate draft patch | Implemented - Not Verified |
| T-0091 | Define AICockpit work item mutation command contract | Backlog |
| T-0092 | Implement AICockpit local work item mutation support | Backlog |
| T-0093 | Implement controlled GitHub work item mutation support | Backlog |
| T-0094 | Add AICockpit Sprint and Epic planning mutation support | Backlog |
| T-0095 | Verify AICockpit mutation authority boundaries | Backlog |
| T-0096 | Define AgileCockpit human mutation authority contract | Backlog |
| T-0097 | Implement AgileCockpit local verification mutations | Backlog |
| T-0098 | Implement AgileCockpit controlled GitHub verification mutations | Backlog |
| T-0099 | Add human verification UI flows for Tasks and Issues | Backlog |
| T-0100 | Verify AICockpit and AgileCockpit authority separation | Backlog |

### Related Issues

None.

### Notes

SP-017 was activated on 2026-06-12. Existing uncommitted dashboard/status changes made before Sprint activation were reviewed under T-0086 through T-0090 before those Tasks were marked Implemented - Not Verified.

T-0086 through T-0090 were implemented on 2026-06-12 and are awaiting human verification. No Task or Issue was moved to Verified by AI.

---

EP-016 was human-verified and closed on 2026-06-11. See [Closed/Epic-EP-016.md](Closed/Epic-EP-016.md).

*Last Updated: 2026-06-12 (T-0086 through T-0090 implemented pending human verification)*
