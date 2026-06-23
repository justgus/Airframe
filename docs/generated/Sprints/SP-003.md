# SP-003: Workflow, Authority, and Audit Foundation

**Status:** Closed
**Epic:** EP-003
**Goal:** Implement the deny-by-default workflow, authority, certified context, and audit foundation used by both AICockpit and AgileCockpit.
**Start Date:** 2026-06-02
**End Date:** 2026-06-03
**Capacity:** TBD

### Assigned Tasks

| Task | Status |
| ---- | ---- |
| T-0012 |  |
| T-0013 |  |
| T-0014 |  |
| T-0015 |  |
| T-0016 |  |
| T-0017 |  |

### Assigned Issues

None.

**Notes:**
- Completed: - SP-003 activated on 2026-06-02. - T-0012 implemented and moved to Implemented - Not Verified on 2026-06-02. - T-0012 human-verified on 2026-06-02. - T-0013 implemented and moved to Implemented - Not Verified on 2026-06-02. - T-0013 human-verified on 2026-06-02. - T-0014 through T-0017 implemented and moved to Implemented - Not Verified on 2026-06-02. - AirframeCore, AICockpit, and AgileCockpit verification targets passed on 2026-06-02. - T-0014 through T-0017 human-verified on 2026-06-03. - GitHub issues #12 through #17 closed on 2026-06-03.
- Returned to Backlog: - None.
- What went well: - Authority, workflow transition, certified actor context, and audit generation now share AirframeCore policy. - Both clients expose denial/audit behavior without duplicating authorization rules.
- What to improve: - Future sprint closeout should continue batching verified task evidence records when multiple tasks are verified together.
- Carry-forward notes: - No client should implement independent authorization rules. - EP-004 should build the local backend and task packet workflow on top of the SP-003 authority boundary.
