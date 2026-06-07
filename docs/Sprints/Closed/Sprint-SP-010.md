# SP-010: Read-Only GitHub Issues Adapter

**Status:** Closed  
**Epic:** EP-010: Read-Only GitHub Adapter  
**Goal:** Implement Slice 2 so `github-issues` reads live `justgus/Airframe` GitHub Issues through `gh`, maps them to Airframe work records, and fails clearly when live access is unavailable.  
**Start Date:** 2026-06-06  
**End Date:** 2026-06-06  
**Close Date:** 2026-06-06  
**Capacity:** Not formally estimated

## Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0051 | Define live GitHub issue transport and failure contract | High | Implemented - Verified |
| T-0052 | Implement read-only GitHub issue listing backend | High | Implemented - Verified |
| T-0053 | Implement GitHub issue-to-work-record parsing | High | Implemented - Verified |
| T-0054 | Wire github-issues into AICockpit commands | High | Implemented - Verified |
| T-0055 | Verify read-only GitHub adapter behavior and docs | Medium | Implemented - Verified |

## Assigned Issues

None.

## Retrospective

**Completed:**
- Read-only `github-issues` backend capabilities and errors added.
- `gh` CLI transport implemented for issue list and issue view.
- Live GitHub issues mapped into Airframe work records using explicit metadata and labels.
- AICockpit read-only commands wired to `github-issues`.
- Mutating commands remain unavailable on the live read-only backend.
- Verification evidence and Slice 2 documentation updated.

**Returned to Backlog:**
- None.

**What went well:**
- Slice 2 established live GitHub-backed read behavior without adding remote mutation support.

**What to improve:**
- Slice 3 should make AgileCockpit surface the same live backend state and clear access failures.

**Carry-forward notes:**
- Slice 3 should keep AgileCockpit presentation logic behind AirframeCore-backed model loading and avoid treating fixture-backed state as live GitHub state.

## Closeout

The user verified SP-010 on 2026-06-06. All assigned tasks were marked Implemented - Verified and GitHub issues #51 through #55 were closed.
