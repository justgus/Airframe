# Active Sprint

---

## SP-012: Project-Local Installation

**Status:** Review
**Epic:** EP-012: Project-Local Installation
**Goal:** Install Airframe live demo artifacts into a repeatable project-local layout without changing global system state.
**Start Date:** 2026-06-08
**End Date:** TBD
**Capacity:** Not formally estimated

### Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0061 | Define project-local demo artifact layout | High | Implemented - Not Verified |
| T-0062 | Install aicockpit into the project-local demo layout | High | Implemented - Not Verified |
| T-0063 | Install AgileCockpit.app into the project-local demo layout | High | Implemented - Not Verified |
| T-0064 | Document project-local demo installation and verification | Medium | Implemented - Not Verified |
| T-0065 | Verify project-local installation without manual Cockpit launch | Medium | Implemented - Not Verified |

### Assigned Issues

None.

### Sprint Notes

- Scope is EP-012 / Live Demo GitHub Plan Slice 4.
- Candidate artifact layout is `demos/LiveDemo/bin/aicockpit`, `demos/LiveDemo/Applications/AgileCockpit.app`, and `demos/LiveDemo/README.md`.
- Verification should prove installed artifacts use `.airframe/airframe-workspace.json` and backend `github-issues`.
- Manual AICockpit and AgileCockpit runs are deferred until all slices are complete; SP-012 verification should use tests and command evidence.
- Global install locations are out of scope unless explicitly approved.

### Retrospective

**Completed:**
- Project-local demo layout is documented under `demos/LiveDemo/README.md`.
- `scripts/install-live-demo.sh` builds and installs `aicockpit` and `AgileCockpit.app` into `demos/LiveDemo/`.
- `scripts/verify-sp012.sh` passed on 2026-06-09, including installed CLI diagnostics, live `github-issues` project summary, artifact checks, and AgileCockpit automated tests.

**Returned to Backlog:**
- None.

**What went well:**
- TBD.

**What to improve:**
- TBD.

**Carry-forward notes:**
- TBD.

---

*Last Updated: 2026-06-09 (T-0061 through T-0065 implemented and awaiting verification)*
