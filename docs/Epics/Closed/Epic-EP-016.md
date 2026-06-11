# EP-016: AICockpit to AgileCockpit Refresh Synchronization

**Status:** Closed
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-11
**Target Close Date:** 2026-06-11
**Close Date:** 2026-06-11

## Goal

Keep AgileCockpit synchronized with repository and backend state after AICockpit or script-driven mutations.

## Scope Completed

- Defined the refresh synchronization contract and failure semantics.
- Added a shared Airframe refresh notification primitive.
- Emitted refresh after successful AICockpit mutations.
- Reloaded AgileCockpit from canonical state after refresh signals and local file changes.
- Verified refresh synchronization and documented evidence.

## Out Of Scope

- Treating notification payloads as authoritative state.
- Building a full XPC service or localhost server for the initial refresh path.
- Adding broad planning or workflow features unrelated to refresh synchronization.
- Human-only acceptance, verification, sprint closure, or epic closure in AICockpit.
- Silent or implicit GitHub writes.

## Related Sprint

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-016 | Synchronize AgileCockpit after AICockpit mutations | Closed |

## Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0081 | Define refresh synchronization contract and failure semantics | Implemented - Verified |
| T-0082 | Add shared Airframe refresh notification primitive | Implemented - Verified |
| T-0083 | Emit refresh after successful AICockpit mutations | Implemented - Verified |
| T-0084 | Reload AgileCockpit from source of truth after refresh signals and file changes | Implemented - Verified |
| T-0085 | Verify refresh synchronization and document evidence | Implemented - Verified |

## Closeout

The user verified EP-016 / SP-016 on 2026-06-11. T-0081 through T-0085 were marked Implemented - Verified, their GitHub issues were closed, and the tasks were moved to the verified task archive.
