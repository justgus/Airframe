# EP-012: Project-Local Installation

**Status:** Closed
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-08
**Target Close Date:** 2026-06-09
**Close Date:** 2026-06-09

## Goal

Implement Slice 4 of the Live Demo GitHub Plan so Airframe demo artifacts can be installed and launched from a project-local location without changing global system state.

## Scope Completed

- Defined and created the project-local demo artifact layout under `demos/LiveDemo/`.
- Added a project-local `aicockpit` installation flow.
- Added a project-local `AgileCockpit.app` installation flow.
- Documented repeatable build, install, launch, and verification commands.
- Verified installed artifacts against `.airframe/airframe-workspace.json` with backend `github-issues`.

## Out Of Scope

- Global installation into `/Applications`, `/usr/local/bin`, shell startup files, or package managers.
- Controlled GitHub mutation support from Slice 5.
- Long-lived credential storage in Airframe-generated files.
- Changing Airframe workflow authority or GitHub backend semantics.

## Related Sprint

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-012 | Project-local installation for Slice 4 | Closed |

## Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0061 | Define project-local demo artifact layout | Implemented - Verified |
| T-0062 | Install aicockpit into the project-local demo layout | Implemented - Verified |
| T-0063 | Install AgileCockpit.app into the project-local demo layout | Implemented - Verified |
| T-0064 | Document project-local demo installation and verification | Implemented - Verified |
| T-0065 | Verify project-local installation without manual Cockpit launch | Implemented - Verified |

## Closeout

The user verified EP-012 on 2026-06-09. SP-012 was closed, and GitHub issues #61 through #65 were labeled `status-verified` and closed.
