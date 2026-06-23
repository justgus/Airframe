# SP-027: AICockpit Canonical State Integration

**Status:** Closed
**Epic:** EP-020
**Goal:** Move AICockpit read paths and diagnostics onto canonical workflow state.
**Start Date:** 2026-06-18
**End Date:** 2026-06-18
**Capacity:** TBD

### Assigned Tasks

| Task | Status |
| ---- | ---- |
| T-0124 |  |
| T-0125 |  |
| T-0126 |  |
| T-0127 |  |

### Assigned Issues

None.

**Notes:**
- Completed: - AICockpit project summary can derive counts and next-task selection from canonical records. - AICockpit task packets can be assembled from canonical Task, Sprint, Epic, Issue, and evidence records. - AICockpit exposes read-only canonical state diagnostics. - Regression coverage verifies AICockpit authority boundaries against canonical state.
- Returned to Backlog: - None.
- What went well: - The canonical read migration stayed contained in AirframeCore and AICockpit while preserving existing output compatibility.
- What to improve: - SP-028 should bring the human-facing AgileCockpit dashboard and planning views onto the same canonical state path.
