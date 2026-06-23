# SP-027: AICockpit Canonical State Integration

**Status:** Closed
**Epic:** EP-020: Canonical Airframe Workflow State
**Goal:** Move AICockpit read paths and diagnostics onto canonical workflow state.
**Start Date:** 2026-06-18
**End Date:** 2026-06-18
**Close Date:** 2026-06-18
**Capacity:** TBD

## Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0124 | Move AICockpit project summary to canonical records | High | Verified |
| T-0125 | Move AICockpit task packet generation to canonical records | High | Verified |
| T-0126 | Add AICockpit canonical state diagnostics command | High | Verified |
| T-0127 | Verify AICockpit authority boundaries against canonical state | High | Verified |

## Assigned Issues

None.

## Sprint Notes

- SP-027 used the SP-025 canonical store foundation and SP-026 import/projection behavior.
- The Sprint moved AICockpit project summary, task packet generation, and state diagnostics onto canonical workflow state.
- Agent authority boundaries stayed unchanged while AICockpit read paths moved onto canonical records.
- GitHub Issues #124 through #127 track the assigned Tasks.

## Retrospective

**Completed:**
- AICockpit project summary can derive counts and next-task selection from canonical records.
- AICockpit task packets can be assembled from canonical Task, Sprint, Epic, Issue, and evidence records.
- AICockpit exposes read-only canonical state diagnostics.
- Regression coverage verifies AICockpit authority boundaries against canonical state.

**Returned to Backlog:**
- None.

**What went well:**
- The canonical read migration stayed contained in AirframeCore and AICockpit while preserving existing output compatibility.

**What to improve:**
- SP-028 should bring the human-facing AgileCockpit dashboard and planning views onto the same canonical state path.

## Closeout

The user marked SP-027 closed on 2026-06-18 after verifying T-0124 through T-0127.

## Evidence

- `swift test --package-path AirframeCore` passed on 2026-06-18 with 69 tests after SP-027 implementation.
- `swift test --package-path AICockpit` passed on 2026-06-18 with 31 tests after SP-027 implementation.
- `git diff --check` passed on 2026-06-18 after SP-027 implementation.
- GitHub Issues #124 through #127 carried `status-verified` before SP-027 archival.
- T-0124 through T-0127 were moved to `docs/Tasks/Verified/Task-verified-0124-0127.md`.

## Follow-Up

- SP-028 activated for AgileCockpit canonical state integration work.
