# SP-009: Live Demo Runtime Configuration

**Status:** Closed  
**Epic:** EP-009: Live Demonstration Runtime Configuration  
**Goal:** Implement the Slice 1 runtime configuration path so AICockpit and AgileCockpit can run against the live Airframe project identity without embedded sample data or GitHub writes.  
**Start Date:** 2026-06-04  
**End Date:** 2026-06-04  
**Close Date:** 2026-06-04  
**Capacity:** Not formally estimated

## Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0046 | Define live demo workspace configuration contract | High | Implemented - Verified |
| T-0047 | Implement AICockpit runtime configuration selection | High | Implemented - Verified |
| T-0048 | Implement AgileCockpit runtime configuration selection | High | Implemented - Verified |
| T-0049 | Add Airframe live demo project configuration and usage docs | Medium | Implemented - Verified |
| T-0050 | Verify Slice 1 live project identity and fallback behavior | High | Implemented - Verified |

## Assigned Issues

None.

## Retrospective

**Completed:**
- Runtime configuration resolver added in AirframeCore.
- AICockpit runtime config/store selection implemented.
- AgileCockpit runtime config model loading implemented.
- Airframe live demo config and usage docs added.
- Direct verification commands passed.

**Returned to Backlog:**
- None.

**What went well:**
- Slice 1 established live project identity without implementing live GitHub issue reads prematurely.

**What to improve:**
- Manual AgileCockpit app launch with environment variables remains useful for demonstration rehearsal.

**Carry-forward notes:**
- Slice 2 should implement read-only `github-issues` adapter behavior.

## Closeout

The user verified SP-009 on 2026-06-04. All assigned tasks were marked Implemented - Verified and GitHub issues #46 through #50 were closed.

