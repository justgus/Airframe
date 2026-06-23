# SP-026: Markdown Import and Projection

**Status:** Closed
**Epic:** EP-020: Canonical Airframe Workflow State
**Goal:** Import current Markdown artifacts into canonical records and generate deterministic documentation projections.
**Start Date:** 2026-06-18
**End Date:** 2026-06-18
**Close Date:** 2026-06-18
**Capacity:** TBD

## Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0120 | Build Markdown artifact importer for existing work products | High | Verified |
| T-0121 | Generate deterministic Markdown projections from canonical records | High | Verified |
| T-0122 | Add import and projection regression coverage | High | Verified |
| T-0123 | Document canonical migration and projection workflow | Medium | Verified |

## Assigned Issues

None.

## Sprint Notes

- SP-026 used the SP-025 canonical record, JSON store, workflow policy, and diagnostics foundation.
- The Sprint delivered Markdown artifact import, deterministic projection, regression coverage, and migration documentation.
- GitHub Issues #120 through #123 track the assigned Tasks.

## Retrospective

**Completed:**
- Current Epic, Sprint, Task, and Issue Markdown artifacts can be imported into canonical records.
- AirframeCore can generate deterministic Markdown projections from canonical records.
- Import and projection regression coverage was added.
- The canonical migration and projection workflow was documented.

**Returned to Backlog:**
- None.

**What went well:**
- Import and projection behavior stayed contained in AirframeCore and has direct unit coverage.

**What to improve:**
- SP-027 should move AICockpit read paths onto canonical records without expanding agent authority.

## Closeout

The user marked SP-026 closed on 2026-06-18 after verifying T-0120 through T-0123.

## Evidence

- `swift test --package-path AirframeCore` passed on 2026-06-17 with 67 tests after SP-026 implementation.
- GitHub Issues #120 through #123 carried `status-verified` before SP-026 archival.
- T-0120 through T-0123 were moved to `docs/Tasks/Verified/Task-verified-0120-0123.md`.

## Follow-Up

- SP-027 activated for AICockpit canonical state integration work.
