# SP-016: Refresh Synchronization for AgileCockpit

**Status:** Closed
**Epic:** EP-016
**Goal:** Keep AgileCockpit synchronized with canonical Airframe state after AICockpit or script-driven mutations.
**Start Date:** 2026-06-11
**End Date:** 2026-06-11
**Capacity:** Not formally estimated

### Assigned Tasks

| Task | Status |
| ---- | ---- |
| T-0081 |  |
| T-0082 |  |
| T-0083 |  |
| T-0084 |  |
| T-0085 |  |

### Assigned Issues

None.

**Notes:**
- Completed: - Refresh synchronization contract was documented. - Shared Airframe refresh notification primitive was added. - AICockpit mutation paths now post refresh only after success. - AgileCockpit now reloads from source of truth after refresh signals and local file changes. - Focused Core, CLI, and AgileCockpit tests passed.
- Returned to Backlog: - None.
- What to improve: - Full AgileCockpit UI smoke tests should be revisited separately; SP-016 verification intentionally used the stable AgileCockpit unit target.
