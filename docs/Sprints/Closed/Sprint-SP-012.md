# SP-012: Project-Local Installation

**Status:** Closed
**Epic:** EP-012
**Goal:** Install Airframe live demo artifacts into a repeatable project-local layout without changing global system state.
**Start Date:** 2026-06-08
**End Date:** 2026-06-09
**Capacity:** Not formally estimated

### Assigned Tasks

| Task | Status |
| ---- | ---- |
| T-0061 |  |
| T-0062 |  |
| T-0063 |  |
| T-0064 |  |
| T-0065 |  |

### Assigned Issues

None.

**Notes:**
- Completed: - Project-local demo layout is documented under `demos/LiveDemo/README.md`. - `scripts/install-live-demo.sh` builds and installs `aicockpit` and `AgileCockpit.app` into `demos/LiveDemo/`. - `scripts/verify-sp012.sh` passed on 2026-06-09, including installed CLI diagnostics, live `github-issues` project summary, artifact checks, and AgileCockpit automated tests.
- Returned to Backlog: - None.
- What went well: - The project-local layout kept all generated artifacts under `demos/LiveDemo/` and avoided global install locations.
- What to improve: - Future live demo slices should close the previous sprint before opening the next one.
- Carry-forward notes: - Slice 5 can build on the project-local install flow without adding global install state.
