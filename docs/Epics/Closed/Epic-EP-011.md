# EP-011: AgileCockpit Live Project View

**Status:** Closed  
**Owner:** Human / Airframe Planning  
**Start Date:** 2026-06-06  
**Target Close Date:** 2026-06-08  
**Close Date:** 2026-06-08

## Goal

Implement Slice 3 of the Live Demo GitHub Plan so AgileCockpit shows the same live Airframe project state as AICockpit through the read-only `github-issues` backend.

## Scope Completed

- Displayed `justgus/Airframe` and `github-issues` backend identity in AgileCockpit live mode.
- Loaded live GitHub issue-backed dashboard counts through AirframeCore.
- Showed sprint and epic planning state from live mapped work records.
- Showed implemented-not-verified work in the verification view when live GitHub data contains it.
- Added clear GitHub access failure state without silently falling back to sample or fixture data.

## Out Of Scope

- GitHub issue mutation beyond approved task verification closeout.
- Long-lived token storage in Airframe-generated files.
- Project-local installation work from Slice 4.
- Controlled GitHub mutation support from Slice 5.

## Related Sprint

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-011 | Implement AgileCockpit live project views for Slice 3. | Closed |

## Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0056 | Wire AgileCockpit live backend configuration | Implemented - Verified |
| T-0057 | Load live GitHub dashboard counts in AgileCockpit | Implemented - Verified |
| T-0058 | Show live sprint and epic planning state | Implemented - Verified |
| T-0059 | Show live implemented-not-verified work | Implemented - Verified |
| T-0060 | Verify AgileCockpit live project view behavior | Implemented - Verified |

## Closeout

The user verified EP-011 on 2026-06-08. SP-011 was closed, and GitHub issues #56 through #60 were labeled `status-verified` and closed.
