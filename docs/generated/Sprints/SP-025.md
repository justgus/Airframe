# SP-025: Canonical Store Schema and Validation

**Status:** Closed
**Epic:** EP-020
**Goal:** Define the canonical store schema, workflow policy records, and validation diagnostics.
**Start Date:** 2026-06-17
**End Date:** 2026-06-18
**Capacity:** TBD

### Assigned Tasks

| Task | Status |
| ---- | ---- |
| T-0116 |  |
| T-0117 |  |
| T-0118 |  |
| T-0119 |  |

### Assigned Issues

None.

**Notes:**
- Completed: - Canonical workflow records were defined in AirframeCore. - Repo-local JSON canonical persistence was added. - Workflow policy definitions were encoded in AirframeCore. - Canonical state diagnostics were added for active ID errors, closed Epic/open work conflicts, and relationship drift.
- Returned to Backlog: - None.
- What went well: - The foundation stayed contained in AirframeCore and has unit coverage for the EP-018 class of inconsistency.
- What to improve: - SP-026 should keep import and projection behavior deterministic so Markdown can become a generated view rather than a mutable source of truth.
