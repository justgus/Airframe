# SP-028: AgileCockpit Canonical State Integration

**Status:** Closed
**Epic:** EP-020: Canonical Airframe Workflow State
**Goal:** Move AgileCockpit dashboard, planning, and data-health views onto canonical workflow state.
**Start Date:** 2026-06-18
**End Date:** 2026-06-23
**Close Date:** 2026-06-23
**Capacity:** TBD

## Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0128 | Move AgileCockpit dashboard and planning views to canonical records | High | Verified |
| T-0129 | Add AgileCockpit data health diagnostics surface | High | Verified |
| T-0130 | Add AgileCockpit repair preview flow for canonical diagnostics | High | Verified |
| T-0131 | Verify end-to-end canonical workflow state behavior | High | Verified |

## Assigned Issues

| Issue | Title | Severity | Status |
| ----- | ----- | -------- | ------ |
| I-0007 | Verification tab can stall or fail silently while loading queue details | High | Verified |
| I-0008 | Canonical state cannot represent Review Sprints and backend label reconciliation | High | Verified |

## Sprint Notes

- SP-028 built on SP-025 canonical records, SP-026 import/projection behavior, and SP-027 AICockpit canonical read paths.
- AgileCockpit dashboard, planning, and data-health surfaces now use canonical workflow state as the primary state source.
- Backend label reconciliation repairs are previewed in AgileCockpit and can be applied through the human-facing UI or the `aicockpit state repair` CLI path with explicit approval.
- The legacy Markdown mutation helpers remain in place as migration helpers for projects still using the old Agile Airframe artifact layout.
- GitHub Issues #128 through #131 track the assigned Tasks, #132 tracks I-0007, and #133 tracks I-0008.

## Retrospective

**Completed:**
- AgileCockpit dashboard and planning views render from canonical records.
- AgileCockpit data health diagnostics surface canonical validation and backend reconciliation problems.
- Backend status and relationship label drift can be repaired through the Apply Repair UI and CLI paths.
- The canonical store remains the internal source of workflow state while Markdown remains exportable documentation.

**Returned to Backlog:**
- None.

**What went well:**
- The final UI migration reused AirframeCore canonical diagnostics and repair actions instead of adding a separate AgileCockpit-only workflow model.

**What to improve:**
- Follow-up work should remove remaining Markdown-primary assumptions after downstream projects have migrated with the retained helper paths.

## Closeout

The user marked I-0008 human-verified and authorized SP-028 closure on 2026-06-23. T-0128 through T-0131 were verified as part of SP-028 closeout.

## Evidence

- `swift test --package-path AirframeCore` passed on 2026-06-23 with 72 tests.
- `swift test --package-path AICockpit` passed on 2026-06-23 with 31 tests.
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-23.
- I-0008 was human-verified on 2026-06-23.
- GitHub Issue #133 carries `status-verified` after human verification.
- T-0128 through T-0131 were moved to `docs/Tasks/Verified/Task-verified-0128-0131.md`.
- I-0008 was moved to `docs/Issues/Verified/Issue-verified-0008.md`.

## Follow-Up

- Continue EP-020 conversion cleanup by retiring Markdown-primary paths only after migration coverage confirms downstream projects can transition safely.
