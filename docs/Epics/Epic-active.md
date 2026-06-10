# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

---

## EP-014: Live Demo Rehearsal and Readiness

**Status:** Complete-pending-close
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-10
**Target Close Date:** TBD
**Close Date:** TBD

## Goal

Prove the installed project-local demo can run a full Airframe live workflow against `justgus/Airframe`, including read-only discovery, AgileCockpit review, and explicitly approved GitHub mutation paths, without relying on fixture-backed behavior or global install state.

## Rationale

Slices 1 through 5 established runtime configuration, live GitHub issue reads, AgileCockpit live views, project-local installation, and controlled GitHub mutations. Slice 6 should rehearse the full demo as an integrated workflow and capture the final runbook before the live demonstration is treated as ready.

## Scope

- Define the Slice 6 demo script, success criteria, constraints, and rollback expectations.
- Rehearse project-local AICockpit live GitHub workflow commands.
- Rehearse AgileCockpit live project review using the installed project-local app.
- Verify a controlled GitHub write demonstration with explicit approval and audit evidence.
- Document the final live demo runbook, expected outputs, known limitations, and rollback notes.

## Out of Scope

- Global installation into `/Applications`, `/usr/local/bin`, shell startup files, or package managers.
- Silent or implicit GitHub writes.
- Fixture-backed behavior presented as live GitHub behavior.
- New workflow authority semantics beyond the approved controlled mutation contract.
- Project board, pull request, or repository mutations outside GitHub Issues.

## Acceptance Criteria

1. Slice 6 has a concrete demo script with success criteria and rollback notes.
2. AICockpit runs against the project-local install and live `github-issues` backend.
3. AgileCockpit displays live project review state from the project-local install.
4. Controlled GitHub write demonstration requires explicit approval and records audit evidence.
5. Final runbook documents expected commands, outputs, approval checkpoints, limitations, and cleanup.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-014 | Rehearse the end-to-end live demo for Slice 6 | Review |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0071 | Define Slice 6 end-to-end demo script and success criteria | Implemented - Not Verified |
| T-0072 | Rehearse project-local AICockpit live GitHub workflow | Implemented - Not Verified |
| T-0073 | Rehearse AgileCockpit live project review workflow | Implemented - Not Verified |
| T-0074 | Verify controlled GitHub write demo with explicit approval | Implemented - Not Verified |
| T-0075 | Document final live demo runbook and rollback notes | Implemented - Not Verified |

### Notes

- Source plan: [Live Demo GitHub Plan](../Live-Demo-GitHub-Plan.md), Slice 6.
- GitHub issues #71 through #75 were created for T-0071 through T-0075 on 2026-06-10 and opened as active SP-014 work.
- SP-014 implementation passed `scripts/verify-sp014.sh`, `swift test --package-path AirframeCore`, and `swift test --package-path AICockpit` on 2026-06-10 and is awaiting human verification.

---

*Last Updated: 2026-06-10 (SP-014 implemented and awaiting verification)*
