# EP-014: Live Demo Rehearsal and Readiness

**Status:** Closed
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-10
**Target Close Date:** 2026-06-10
**Close Date:** 2026-06-10

## Goal

Prove the installed project-local demo can run a full Airframe live workflow against `justgus/Airframe`, including read-only discovery, AgileCockpit review, and explicitly approved GitHub mutation paths, without relying on fixture-backed behavior or global install state.

## Scope Completed

- Defined the Slice 6 demo script, success criteria, constraints, and rollback expectations.
- Rehearsed project-local AICockpit live GitHub workflow commands.
- Rehearsed AgileCockpit live project review using the installed project-local app.
- Verified controlled GitHub write safety with explicit approval requirements and audit evidence paths.
- Documented the final live demo runbook, expected outputs, known limitations, and rollback notes.

## Out Of Scope

- Global installation into `/Applications`, `/usr/local/bin`, shell startup files, or package managers.
- Silent or implicit GitHub writes.
- Fixture-backed behavior presented as live GitHub behavior.
- New workflow authority semantics beyond the approved controlled mutation contract.
- Project board, pull request, or repository mutations outside GitHub Issues.

## Related Sprint

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-014 | Rehearse the end-to-end live demo for Slice 6 | Closed |

## Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0071 | Define Slice 6 end-to-end demo script and success criteria | Implemented - Verified |
| T-0072 | Rehearse project-local AICockpit live GitHub workflow | Implemented - Verified |
| T-0073 | Rehearse AgileCockpit live project review workflow | Implemented - Verified |
| T-0074 | Verify controlled GitHub write demo with explicit approval | Implemented - Verified |
| T-0075 | Document final live demo runbook and rollback notes | Implemented - Verified |

## Closeout

The user verified EP-014 and Live Demo GitHub Plan Slice 6 on 2026-06-10. SP-014 was closed, and T-0071 through T-0075 were moved to the verified task archive.
