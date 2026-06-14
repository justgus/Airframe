# EP-017: Workflow Status Dashboard and Mutation Authority

**Status:** Closed
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-12
**Target Close Date:** 2026-06-14
**Close Date:** 2026-06-14

## Goal

Make AgileCockpit’s dashboard reflect Airframe’s artifact-specific workflow statuses, add drill-down visibility from status counts to item details, enforce Agile authorization before implementation, and define the mutation boundaries between AICockpit and AgileCockpit.

## Scope Completed

- Replaced generic dashboard metrics with artifact-specific workflow status tiles.
- Added status row drill-down from counts to ID/title lists and rendered item details.
- Added process guardrails preventing implementation without Epic, Sprint, and Task authorization.
- Added AICockpit local and GitHub work item create/update capability, excluding Task/Issue verification.
- Added AgileCockpit human-facing verification mutation capability for Tasks and Issues.

## Out Of Scope

- AICockpit applying Verified status to Tasks or Issues.
- AICockpit performing human-only Sprint or Epic closure.
- Silent or implicit GitHub mutation without explicit approval.
- Implementing the draft patch before an assigned Sprint is active.

## Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-017 | Deliver workflow status dashboard and process guardrails | Closed |
| SP-018 | Add AICockpit local and GitHub work item mutation support | Closed |
| SP-019 | Add AgileCockpit human verification mutations | Closed |

## Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0086 | Reconcile Agile artifact workflow documentation and process guardrails | Implemented - Verified |
| T-0087 | Define artifact-specific status presentation model | Implemented - Verified |
| T-0088 | Replace dashboard metrics with workflow status tiles | Implemented - Verified |
| T-0089 | Add interactive dashboard status drill-down | Implemented - Verified |
| T-0090 | Verify dashboard workflow and integrate draft patch | Implemented - Verified |
| T-0091 | Define AICockpit work item mutation command contract | Implemented - Verified |
| T-0092 | Implement AICockpit local work item mutation support | Implemented - Verified |
| T-0093 | Implement controlled GitHub work item mutation support | Implemented - Verified |
| T-0094 | Add AICockpit Sprint and Epic planning mutation support | Implemented - Verified |
| T-0095 | Verify AICockpit mutation authority boundaries | Implemented - Verified |
| T-0096 | Define AgileCockpit human mutation authority contract | Implemented - Verified |
| T-0097 | Implement AgileCockpit local verification mutations | Implemented - Verified |
| T-0098 | Implement AgileCockpit controlled GitHub verification mutations | Implemented - Verified |
| T-0099 | Add human verification UI flows for Tasks and Issues | Implemented - Verified |
| T-0100 | Verify AICockpit and AgileCockpit authority separation | Implemented - Verified |

## Related Issues

None.

## Notes

SP-017 was activated on 2026-06-12. Existing uncommitted dashboard/status changes made before Sprint activation were reviewed under T-0086 through T-0090 before those Tasks were marked Implemented - Not Verified.

T-0086 through T-0090 were implemented on 2026-06-12 and later human-verified. No Task or Issue was moved to Verified by AI.

## Closeout

The user closed EP-017 on 2026-06-14 after the related sprints were manually closed.
