# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

---

## EP-015: AgileCockpit Planning Management

**Status:** Active
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-10
**Target Close Date:** TBD
**Close Date:** TBD

## Goal

Make AgileCockpit the human-facing surface for managing Epics, Sprints, Tasks, and Issues instead of only viewing them.

## Rationale

AgileCockpit currently provides dashboard, verification, sprint/epic read views, metrics, and audit visibility. Slice 7 should add planning-management capability while preserving AirframeCore as the canonical authority boundary and AICockpit as the agent-facing interface.

## Scope

- Define the AgileCockpit planning operation contract.
- Add AirframeCore planning APIs for artifact operations.
- Add AgileCockpit task and issue planning UI.
- Add AgileCockpit sprint and epic management UI.
- Verify the planning workflow, authority boundaries, backend capability handling, and documentation.

## Out of Scope

- Silent or implicit GitHub writes.
- Global installation into `/Applications`, `/usr/local/bin`, shell startup files, or package managers.
- Replacing GitHub Projects, Jira, Linear, or other general project-management systems.
- AICockpit performing human-only acceptance, verification, sprint closure, or epic closure.
- Project board, pull request, or repository mutations outside the explicitly approved planning scope.

## Acceptance Criteria

1. AgileCockpit can show whether the current backend supports each planning operation.
2. Authorized human users can request allowed planning actions through AgileCockpit.
3. AirframeCore validates and audits every planning operation.
4. Denied or unsupported operations are visible and explain why.
5. Tests cover task/issue planning, sprint/epic controls, authority denial, and backend capability limits.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-015 | Add human planning controls for Agile Artifacts | Active |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0076 | Define AgileCockpit planning operation contract | Active |
| T-0077 | Add AirframeCore planning APIs for artifact operations | Active |
| T-0078 | Implement AgileCockpit task and issue planning UI | Active |
| T-0079 | Implement AgileCockpit sprint and epic management UI | Active |
| T-0080 | Verify planning management workflow and documentation | Active |

### Notes

- EP-015 / SP-015 were approved by the user on 2026-06-10 after EP-014 / SP-014 closeout.
- AICockpit remains the agent-facing CLI and must not perform human-only planning closeout operations.
- AgileCockpit planning operations must route through AirframeCore.

---

EP-014 was human-verified and closed on 2026-06-10. See [Closed/Epic-EP-014.md](Closed/Epic-EP-014.md).

*Last Updated: 2026-06-10 (EP-015 activated)*
