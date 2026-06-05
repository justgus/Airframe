# Active Sprint

---

## SP-009: Live Demo Runtime Configuration

**Status:** Review
**Epic:** EP-009: Live Demonstration Runtime Configuration
**Goal:** Implement the Slice 1 runtime configuration path so AICockpit and AgileCockpit can run against the live Airframe project identity without embedded sample data or GitHub writes.
**Start Date:** 2026-06-04
**End Date:** TBD
**Capacity:** TBD

### Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0046 | Define live demo workspace configuration contract | High | Implemented - Not Verified |
| T-0047 | Implement AICockpit runtime configuration selection | High | Implemented - Not Verified |
| T-0048 | Implement AgileCockpit runtime configuration selection | High | Implemented - Not Verified |
| T-0049 | Add Airframe live demo project configuration and usage docs | Medium | Implemented - Not Verified |
| T-0050 | Verify Slice 1 live project identity and fallback behavior | High | Implemented - Not Verified |

### Assigned Issues

| Issue | Title | Severity | Status |
| ----- | ----- | -------- | ------ |
| None | No defect issues assigned. | N/A | N/A |

### Sprint Notes

- GitHub issues #46 through #50 were created for T-0046 through T-0050 after explicit approval.
- The Sprint must not implement live GitHub issue reads or writes; it only prepares live project configuration support.

### Retrospective

**Completed:**
- Runtime configuration resolver added in AirframeCore.
- AICockpit runtime config/store selection implemented.
- AgileCockpit runtime config model loading implemented.
- Airframe live demo config and usage docs added.
- Direct verification commands passed.

**Returned to Backlog:**
- TBD

**What went well:**
- Slice 1 stayed read-only with respect to GitHub issue data after the planned status-label transitions.

**What to improve:**
- Manual app launch verification with environment variables should be performed during human verification.

**Carry-forward notes:**
- Slice 2 should implement read-only `github-issues` adapter behavior.

---

*Last Updated: 2026-06-04 (SP-009 in review pending human verification)*
