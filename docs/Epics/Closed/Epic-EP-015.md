# EP-015: AgileCockpit Planning Management

**Status:** Closed
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-10
**Target Close Date:** 2026-06-11
**Close Date:** 2026-06-11

## Goal

Make AgileCockpit the human-facing surface for managing Epics, Sprints, Tasks, and Issues instead of only viewing them.

## Scope Completed

- Defined the AgileCockpit planning operation contract.
- Added the AirframeCore planning API scope for artifact operations.
- Defined AgileCockpit task and issue planning UI behavior.
- Defined AgileCockpit sprint and epic management UI behavior.
- Verified the planning workflow, authority boundaries, backend capability handling, and documentation expectations.

## Out Of Scope

- Silent or implicit GitHub writes.
- Global installation into `/Applications`, `/usr/local/bin`, shell startup files, or package managers.
- Replacing GitHub Projects, Jira, Linear, or other general project-management systems.
- AICockpit performing human-only acceptance, verification, sprint closure, or epic closure.
- Project board, pull request, or repository mutations outside the explicitly approved planning scope.

## Related Sprint

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-015 | Add human planning controls for Agile Artifacts | Closed |

## Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0076 | Define AgileCockpit planning operation contract | Implemented - Verified |
| T-0077 | Add AirframeCore planning APIs for artifact operations | Implemented - Verified |
| T-0078 | Implement AgileCockpit task and issue planning UI | Implemented - Verified |
| T-0079 | Implement AgileCockpit sprint and epic management UI | Implemented - Verified |
| T-0080 | Verify planning management workflow and documentation | Implemented - Verified |

## Closeout

The user authorized EP-015 / SP-015 closeout on 2026-06-11. T-0076 through T-0080 were marked Implemented - Verified, their GitHub issues were closed, and the tasks were moved to the verified task archive.
