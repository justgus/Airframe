# SP-025: Canonical Store Schema and Validation

**Status:** Closed
**Epic:** EP-020: Canonical Airframe Workflow State
**Goal:** Define the canonical store schema, workflow policy records, and validation diagnostics.
**Start Date:** 2026-06-17
**End Date:** 2026-06-18
**Close Date:** 2026-06-18
**Capacity:** TBD

## Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0116 | Define canonical workflow record schemas | High | Verified |
| T-0117 | Implement repo-local JSON canonical store | High | Verified |
| T-0118 | Encode workflow policy definitions in AirframeCore | High | Verified |
| T-0119 | Add canonical state validation diagnostics | High | Verified |

## Assigned Issues

None.

## Sprint Notes

- SP-025 started the EP-020 canonical workflow-state implementation.
- The Sprint established the record model, local JSON store foundation, workflow policy definitions, and diagnostics needed before Markdown import/projection and client integrations proceed.
- GitHub Issues #116 through #119 track the assigned Tasks.

## Retrospective

**Completed:**
- Canonical workflow records were defined in AirframeCore.
- Repo-local JSON canonical persistence was added.
- Workflow policy definitions were encoded in AirframeCore.
- Canonical state diagnostics were added for active ID errors, closed Epic/open work conflicts, and relationship drift.

**Returned to Backlog:**
- None.

**What went well:**
- The foundation stayed contained in AirframeCore and has unit coverage for the EP-018 class of inconsistency.

**What to improve:**
- SP-026 should keep import and projection behavior deterministic so Markdown can become a generated view rather than a mutable source of truth.

## Closeout

The user marked SP-025 closed on 2026-06-18 after verifying T-0116 through T-0119.

## Evidence

- `swift test --package-path AirframeCore` passed with 60 tests before SP-025 archival.
- AICockpit live summary reported `activeTaskCount: 0` and `unverifiedTaskCount: 0` before archive.
- GitHub Issues #116 through #119 carried `status-verified`.
- T-0116 through T-0119 were moved to `docs/Tasks/Verified/Task-verified-0116-0119.md`.

## Follow-Up

- SP-026 activated for Markdown import and deterministic projection work.
