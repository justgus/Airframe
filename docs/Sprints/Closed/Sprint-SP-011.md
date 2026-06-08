# SP-011: AgileCockpit Live Project View Planning

**Status:** Closed  
**Epic:** EP-011: AgileCockpit Live Project View  
**Goal:** Implement Slice 3 so AgileCockpit shows live `justgus/Airframe` project state through the read-only `github-issues` backend, matching the verified AICockpit live state without presenting fixture data as live behavior.  
**Start Date:** 2026-06-08  
**End Date:** 2026-06-08  
**Close Date:** 2026-06-08  
**Capacity:** Not formally estimated

## Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0056 | Wire AgileCockpit live backend configuration | High | Implemented - Verified |
| T-0057 | Load live GitHub dashboard counts in AgileCockpit | High | Implemented - Verified |
| T-0058 | Show live sprint and epic planning state | High | Implemented - Verified |
| T-0059 | Show live implemented-not-verified work | High | Implemented - Verified |
| T-0060 | Verify AgileCockpit live project view behavior | Medium | Implemented - Verified |

## Assigned Issues

None.

## Retrospective

**Completed:**
- AgileCockpit configured loading now supports the read-only `github-issues` backend.
- AgileCockpit launch failure handling preserves live project identity instead of falling back to sample data.
- Live demo configuration now points to `github-issues`, SP-011, and EP-011.
- Focused AgileCockpit tests cover live dashboard, planning, verification, and failure-state behavior.

**Returned to Backlog:**
- None.

**What went well:**
- Existing AirframeCore GitHub issue mapping APIs were sufficient for AgileCockpit live views.

**What to improve:**
- A dedicated manual app launch script would make live UI verification more repeatable.

**Carry-forward notes:**
- Slice 4 can package the project-local launch path after SP-011 closeout.

## Closeout

The user verified SP-011 on 2026-06-08. All assigned tasks were marked Implemented - Verified and GitHub issues #56 through #60 were closed.
