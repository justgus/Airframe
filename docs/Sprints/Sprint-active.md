# Active Sprint

---

## SP-014: End-to-End Live Demo Rehearsal

**Status:** Review
**Epic:** EP-014: Live Demo Rehearsal and Readiness
**Goal:** Rehearse the full project-local Airframe live demo against `justgus/Airframe`, including read-only discovery, AgileCockpit review, and explicitly approved controlled GitHub mutation paths.
**Start Date:** 2026-06-10
**End Date:** TBD
**Capacity:** Not formally estimated

### Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0071 | Define Slice 6 end-to-end demo script and success criteria | High | Implemented - Not Verified |
| T-0072 | Rehearse project-local AICockpit live GitHub workflow | High | Implemented - Not Verified |
| T-0073 | Rehearse AgileCockpit live project review workflow | High | Implemented - Not Verified |
| T-0074 | Verify controlled GitHub write demo with explicit approval | High | Implemented - Not Verified |
| T-0075 | Document final live demo runbook and rollback notes | Medium | Implemented - Not Verified |

### Assigned Issues

None.

### Sprint Notes

- Scope is EP-014 / Live Demo GitHub Plan Slice 6.
- Use project-local installed artifacts under `demos/LiveDemo/`.
- Do not present fixture-backed behavior as live GitHub behavior.
- GitHub mutations must remain explicit, approved, and auditable.
- Final readiness requires a runbook with expected outputs, approval checkpoints, known limitations, and rollback notes.

### Retrospective

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

---

*Last Updated: 2026-06-10 (T-0071 through T-0075 implemented and awaiting verification)*
