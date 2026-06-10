# SP-014: End-to-End Live Demo Rehearsal

**Status:** Closed
**Epic:** EP-014: Live Demo Rehearsal and Readiness
**Goal:** Rehearse the full project-local Airframe live demo against `justgus/Airframe`, including read-only discovery, AgileCockpit review, and explicitly approved controlled GitHub mutation paths.
**Start Date:** 2026-06-10
**End Date:** 2026-06-10
**Close Date:** 2026-06-10
**Capacity:** Not formally estimated

## Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0071 | Define Slice 6 end-to-end demo script and success criteria | High | Implemented - Verified |
| T-0072 | Rehearse project-local AICockpit live GitHub workflow | High | Implemented - Verified |
| T-0073 | Rehearse AgileCockpit live project review workflow | High | Implemented - Verified |
| T-0074 | Verify controlled GitHub write demo with explicit approval | High | Implemented - Verified |
| T-0075 | Document final live demo runbook and rollback notes | Medium | Implemented - Verified |

## Assigned Issues

None.

## Sprint Notes

- Scope was EP-014 / Live Demo GitHub Plan Slice 6.
- Project-local installed artifacts under `demos/LiveDemo/` were used.
- Fixture-backed behavior was not presented as live GitHub behavior.
- GitHub mutations remained explicit, approved, and auditable.
- The final runbook documents expected outputs, approval checkpoints, known limitations, and rollback notes.

## Retrospective

**Completed:**
- Slice 6 demo script and runbook were documented in `docs/Live-Demo-Runbook.md`.
- Project-local AICockpit live GitHub workflow was rehearsed through `scripts/verify-sp014.sh`.
- AgileCockpit project-local review workflow was covered by the SP-014 verification script and automated tests.
- Controlled GitHub write safety was verified through the missing-approval failure path.
- AirframeCore GitHub CLI transport was fixed to avoid pipe-buffer deadlock on large `gh` output.

**Returned to Backlog:**
- None.

**What went well:**
- The full project-local verification caught and then verified a real live-backend transport issue.

**What to improve:**
- Future live GitHub command wrappers should include bounded timeouts or equivalent clear failure behavior.

**Carry-forward notes:**
- The automated SP-014 verification intentionally does not perform an approved live GitHub mutation; that remains a manual, explicitly approved demo step.

## Closeout

The user verified SP-014 on 2026-06-10. All assigned tasks were marked Implemented - Verified and moved to the verified task archive.
