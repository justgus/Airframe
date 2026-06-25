# SP-014: End-to-End Live Demo Rehearsal

**Status:** Closed
**Epic:** EP-014
**Goal:** Rehearse the full project-local Airframe live demo against `justgus/Airframe`, including read-only discovery, AgileCockpit review, and explicitly approved controlled GitHub mutation paths.
**Start Date:** 2026-06-10
**End Date:** 2026-06-10
**Capacity:** Not formally estimated

### Assigned Tasks

| Task | Status |
| ---- | ---- |
| T-0071 |  |
| T-0072 |  |
| T-0073 |  |
| T-0074 |  |
| T-0075 |  |

### Assigned Issues

None.

**Notes:**
- Completed: - Slice 6 demo script and runbook were documented in `docs/Live-Demo-Runbook.md`. - Project-local AICockpit live GitHub workflow was rehearsed through `scripts/verify-sp014.sh`. - AgileCockpit project-local review workflow was covered by the SP-014 verification script and automated tests. - Controlled GitHub write safety was verified through the missing-approval failure path. - AirframeCore GitHub CLI transport was fixed to avoid pipe-buffer deadlock on large `gh` output.
- Returned to Backlog: - None.
- What went well: - The full project-local verification caught and then verified a real live-backend transport issue.
- What to improve: - Future live GitHub command wrappers should include bounded timeouts or equivalent clear failure behavior.
- Carry-forward notes: - The automated SP-014 verification intentionally does not perform an approved live GitHub mutation; that remains a manual, explicitly approved demo step.
