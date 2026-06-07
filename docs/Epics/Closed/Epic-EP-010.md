# EP-010: Read-Only GitHub Adapter

**Status:** Closed  
**Owner:** Human / Airframe Planning  
**Start Date:** 2026-06-05  
**Target Close Date:** 2026-06-06  
**Close Date:** 2026-06-06

## Goal

Implement Slice 2 of the Live Demo GitHub Plan by reading GitHub issues from `justgus/Airframe` and mapping them into Airframe work records.

## Scope Completed

- Added read-only GitHub issue listing through the `gh` CLI transport.
- Added individual GitHub issue inspection by number.
- Parsed Airframe task metadata from issue body content and labels.
- Derived sprint, epic, priority, and status values from GitHub issue metadata.
- Exposed read-only GitHub backend capabilities honestly through AirframeCore and AICockpit.
- Verified live read-only AICockpit project summary and task packet commands.

## Out Of Scope

- GitHub issue mutation beyond approved task verification closeout.
- Long-lived token storage in Airframe-generated files.
- AgileCockpit live project view work from Slice 3.
- Project-local installation work from Slice 4.

## Related Sprint

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-010 | Implement read-only live GitHub issue access through `gh` and map issues into Airframe work records. | Closed |

## Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0051 | Define live GitHub issue transport and failure contract | Implemented - Verified |
| T-0052 | Implement read-only GitHub issue listing backend | Implemented - Verified |
| T-0053 | Implement GitHub issue-to-work-record parsing | Implemented - Verified |
| T-0054 | Wire github-issues into AICockpit commands | Implemented - Verified |
| T-0055 | Verify read-only GitHub adapter behavior and docs | Implemented - Verified |

## Closeout

The user verified EP-010 on 2026-06-06. SP-010 was closed, and GitHub issues #51 through #55 were labeled `status-verified` and closed.
