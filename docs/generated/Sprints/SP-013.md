# SP-013: Controlled GitHub Mutation Planning

**Status:** Closed
**Epic:** EP-013
**Goal:** Plan and implement the Slice 5 work needed to support explicit, auditable, and approval-gated GitHub issue mutations without weakening Airframe authority boundaries.
**Start Date:** 2026-06-09
**End Date:** 2026-06-10
**Capacity:** Not formally estimated

### Assigned Tasks

| Task | Status |
| ---- | ---- |
| T-0066 |  |
| T-0067 |  |
| T-0068 |  |
| T-0069 |  |
| T-0070 |  |

### Assigned Issues

None.

**Notes:**
- Completed: - Controlled GitHub mutation approval/result models and backend capabilities were added in AirframeCore. - GitHub issue comment, evidence comment, and status-label mutation APIs are approval-gated. - AICockpit exposes explicit controlled mutation commands. - Missing approval is verified to fail before live GitHub lookup/write. - `scripts/verify-sp013.sh` and AgileCockpit tests passed.
- Returned to Backlog: - None.
- What went well: - Slice 5 added bounded live GitHub write paths while preserving explicit approval and audit requirements.
- What to improve: - Keep closeout records synchronized with GitHub labels immediately after human verification.
- Carry-forward notes: - Future live write demonstrations should continue to require explicit user approval before mutating GitHub state.
