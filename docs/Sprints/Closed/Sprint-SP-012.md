# SP-012: Project-Local Installation

**Status:** Closed
**Epic:** EP-012: Project-Local Installation
**Goal:** Install Airframe live demo artifacts into a repeatable project-local layout without changing global system state.
**Start Date:** 2026-06-08
**End Date:** 2026-06-09
**Close Date:** 2026-06-09
**Capacity:** Not formally estimated

## Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0061 | Define project-local demo artifact layout | High | Implemented - Verified |
| T-0062 | Install aicockpit into the project-local demo layout | High | Implemented - Verified |
| T-0063 | Install AgileCockpit.app into the project-local demo layout | High | Implemented - Verified |
| T-0064 | Document project-local demo installation and verification | Medium | Implemented - Verified |
| T-0065 | Verify project-local installation without manual Cockpit launch | Medium | Implemented - Verified |

## Assigned Issues

None.

## Retrospective

**Completed:**
- Project-local demo layout is documented under `demos/LiveDemo/README.md`.
- `scripts/install-live-demo.sh` builds and installs `aicockpit` and `AgileCockpit.app` into `demos/LiveDemo/`.
- `scripts/verify-sp012.sh` passed on 2026-06-09, including installed CLI diagnostics, live `github-issues` project summary, artifact checks, and AgileCockpit automated tests.

**Returned to Backlog:**
- None.

**What went well:**
- The project-local layout kept all generated artifacts under `demos/LiveDemo/` and avoided global install locations.

**What to improve:**
- Future live demo slices should close the previous sprint before opening the next one.

**Carry-forward notes:**
- Slice 5 can build on the project-local install flow without adding global install state.

## Closeout

The user verified SP-012 on 2026-06-09. All assigned tasks were marked Implemented - Verified and GitHub issues #61 through #65 were closed.
