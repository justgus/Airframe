# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

---

## EP-012: Project-Local Installation

**Status:** Complete-pending-close
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-08
**Target Close Date:** TBD
**Close Date:** TBD

## Goal

Implement Slice 4 of the Live Demo GitHub Plan so Airframe demo artifacts can be installed and launched from a project-local location without changing global system state.

## Rationale

Airframe now has live read-only GitHub-backed behavior in AICockpit and AgileCockpit. The next demo slice needs a repeatable local installation layout so the live demo can be run from the repository without installing into `/Applications`, `/usr/local/bin`, shell startup files, or other global locations.

## Scope

- Define and create a project-local demo artifact layout under `demos/LiveDemo/`.
- Include a project-local `aicockpit` executable artifact.
- Include a project-local `AgileCockpit.app` artifact.
- Document repeatable build, install, and launch commands.
- Verify installed artifacts run against `.airframe/airframe-workspace.json` with backend `github-issues`.

## Out of Scope

- Global installation into `/Applications`, `/usr/local/bin`, shell startup files, or package managers.
- Controlled GitHub mutation support from Slice 5.
- Long-lived credential storage in Airframe-generated files.
- Changing Airframe workflow authority or GitHub backend semantics.

## Acceptance Criteria

1. Project-local demo artifacts exist under `demos/LiveDemo/` or another explicitly approved project-local path.
2. The installed `aicockpit` artifact can run a live `github-issues` project summary from the project-local layout.
3. The installed `AgileCockpit.app` artifact can be launched from the project-local layout.
4. `demos/LiveDemo/README.md` documents repeatable build, install, launch, and verification commands.
5. The implementation does not write to global install locations.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-012 | Project-local installation for Slice 4 | Review |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0061 | Define project-local demo artifact layout | Implemented - Not Verified |
| T-0062 | Install aicockpit into the project-local demo layout | Implemented - Not Verified |
| T-0063 | Install AgileCockpit.app into the project-local demo layout | Implemented - Not Verified |
| T-0064 | Document project-local demo installation and verification | Implemented - Not Verified |
| T-0065 | Verify project-local installation without manual Cockpit launch | Implemented - Not Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

- Source plan: [Live Demo GitHub Plan](../Live-Demo-GitHub-Plan.md), Slice 4.
- Proposed layout from the source plan:
  - `demos/LiveDemo/bin/aicockpit`
  - `demos/LiveDemo/Applications/AgileCockpit.app`
  - `demos/LiveDemo/README.md`
- Manual AICockpit and AgileCockpit runs are deferred until all slices are complete; SP-012 verification should use tests and command evidence.
- T-0061 through T-0065 were created with mapped GitHub Issues on 2026-06-08.
- SP-012 implementation passed `scripts/verify-sp012.sh` on 2026-06-09 and is awaiting human verification.

---

*Last Updated: 2026-06-09 (SP-012 implemented and awaiting verification)*
