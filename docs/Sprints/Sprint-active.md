# Active Sprint

---

## SP-013: Controlled GitHub Mutation Planning

**Status:** Review
**Epic:** EP-013: Controlled GitHub Mutations
**Goal:** Plan and implement the Slice 5 work needed to support explicit, auditable, and approval-gated GitHub issue mutations without weakening Airframe authority boundaries.
**Start Date:** 2026-06-09
**End Date:** TBD
**Capacity:** Not formally estimated

### Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0066 | Define controlled GitHub mutation authority contract | High | Implemented - Not Verified |
| T-0067 | Add GitHub issue comment mutation support | High | Implemented - Not Verified |
| T-0068 | Add controlled GitHub status label transition support | High | Implemented - Not Verified |
| T-0069 | Wire explicit mutation commands and UI affordances | High | Implemented - Not Verified |
| T-0070 | Verify controlled mutation safety and documentation | Medium | Implemented - Not Verified |

### Assigned Issues

None.

### Sprint Notes

- Scope is EP-013 / Live Demo GitHub Plan Slice 5.
- GitHub write support must stay disabled by default or require an explicit opt-in path.
- Each write path must be explicit in the command/action name or arguments.
- User approval is required before live demonstration writes.
- Audit records are required for every write.
- AICockpit must not perform human-only acceptance operations.

### Retrospective

**Completed:**
- Controlled GitHub mutation approval/result models and backend capabilities were added in AirframeCore.
- GitHub issue comment, evidence comment, and status-label mutation APIs are approval-gated.
- AICockpit exposes explicit controlled mutation commands.
- Missing approval is verified to fail before live GitHub lookup/write.
- `scripts/verify-sp013.sh` and AgileCockpit tests passed.

**Returned to Backlog:**
- None.

**What went well:**
- TBD.

**What to improve:**
- TBD.

**Carry-forward notes:**
- TBD.

---

*Last Updated: 2026-06-09 (T-0066 through T-0070 implemented and awaiting verification)*
