# EP-009: Live Demonstration Runtime Configuration

**Status:** Closed  
**Owner:** Human / Airframe Planning  
**Start Date:** 2026-06-04  
**Target Close Date:** 2026-06-04  
**Close Date:** 2026-06-04

## Goal

Enable Airframe to run against the live `justgus/Airframe` project configuration instead of only embedded sample data.

## Scope Completed

- Defined and documented the live Airframe workspace configuration contract.
- Added runtime configuration selection for AICockpit.
- Added runtime configuration selection for AgileCockpit.
- Added project-local live demo configuration and usage documentation.
- Verified that both app paths can report live Airframe project identity without GitHub issue reads or writes.

## Out Of Scope

- Live GitHub issue read adapter implementation.
- GitHub issue mutation support beyond approved task status synchronization.
- Global app or CLI installation.

## Related Sprint

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-009 | Implement live demo runtime configuration for AICockpit and AgileCockpit. | Closed |

## Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0046 | Define live demo workspace configuration contract | Implemented - Verified |
| T-0047 | Implement AICockpit runtime configuration selection | Implemented - Verified |
| T-0048 | Implement AgileCockpit runtime configuration selection | Implemented - Verified |
| T-0049 | Add Airframe live demo project configuration and usage docs | Implemented - Verified |
| T-0050 | Verify Slice 1 live project identity and fallback behavior | Implemented - Verified |

## Closeout

The user verified EP-009 on 2026-06-04. SP-009 was closed, and GitHub issues #46 through #50 were labeled `status-verified` and closed.

