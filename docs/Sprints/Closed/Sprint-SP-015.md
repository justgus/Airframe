# SP-015: Human Planning Controls for Agile Artifacts

**Status:** Closed
**Epic:** EP-015: AgileCockpit Planning Management
**Goal:** Add human-facing AgileCockpit planning controls for Epics, Sprints, Tasks, and Issues while preserving AirframeCore authority and workflow boundaries.
**Start Date:** 2026-06-10
**End Date:** 2026-06-11
**Close Date:** 2026-06-11
**Capacity:** Not formally estimated

## Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0076 | Define AgileCockpit planning operation contract | High | Implemented - Verified |
| T-0077 | Add AirframeCore planning APIs for artifact operations | High | Implemented - Verified |
| T-0078 | Implement AgileCockpit task and issue planning UI | High | Implemented - Verified |
| T-0079 | Implement AgileCockpit sprint and epic management UI | High | Implemented - Verified |
| T-0080 | Verify planning management workflow and documentation | Medium | Implemented - Verified |

## Assigned Issues

None.

## Sprint Notes

- Scope was EP-015 / Slice 7 planning management.
- AgileCockpit remained the human-facing planning surface.
- AirframeCore remained the authority, workflow, backend capability, and audit source of truth.
- AICockpit remained agent-facing and did not perform human-only acceptance, verification, sprint closure, or epic closure.
- GitHub mutations remained explicit, approved, and auditable.

## Retrospective

**Completed:**
- Planning-management task scope was defined and tracked through GitHub Issues.
- Live `github-issues` backend capability limits were confirmed before the next planning step.
- The next refresh-synchronization slice was split into EP-016 / SP-016 tasks before continuing implementation.

**Returned to Backlog:**
- None.

**What to improve:**
- Implementation work should not begin after technical-plan approval until Epic, Sprint, and Task artifacts are explicitly created or updated.

## Closeout

The user verified SP-015 on 2026-06-11. All assigned tasks were marked Implemented - Verified and moved to the verified task archive.
