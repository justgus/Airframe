# SP-028: AgileCockpit Canonical State Integration

**Status:** Closed
**Epic:** EP-020
**Goal:** Move AgileCockpit dashboard, planning, and data-health views onto canonical workflow state.
**Start Date:** 2026-06-18
**End Date:** 2026-06-23
**Capacity:** TBD

### Assigned Tasks

| Task | Status |
| ---- | ---- |
| T-0128 |  |
| T-0129 |  |
| T-0130 |  |
| T-0131 |  |

### Assigned Issues

| Issue | Status |
| ---- | ---- |
| I-0007 |  |
| I-0008 |  |

**Notes:**
- Completed: - AgileCockpit dashboard and planning views render from canonical records. - AgileCockpit data health diagnostics surface canonical validation and backend reconciliation problems. - Backend status and relationship label drift can be repaired through the Apply Repair UI and CLI paths. - The canonical store remains the internal source of workflow state while Markdown remains exportable documentation.
- Returned to Backlog: - None.
- What went well: - The final UI migration reused AirframeCore canonical diagnostics and repair actions instead of adding a separate AgileCockpit-only workflow model.
- What to improve: - Follow-up work should remove remaining Markdown-primary assumptions after downstream projects have migrated with the retained helper paths.
