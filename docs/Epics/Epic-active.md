# Epic Active

Epics listed here are drafted, active, or complete-pending-close and are the current focus of planning or execution.

---

## EP-018: AgileCockpit Sprint and Epic Status Controls

**Status:** Active
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-15
**Target Close Date:** TBD
**Close Date:** TBD

**Goal:**
Add human-facing AgileCockpit controls for Sprint and Epic status mutation, including Epic acceptance-criteria verification, Sprint close gating, and Epic close gating with archive updates.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-020 | Add Epic acceptance-criteria state and close-eligibility tracking to the planning model. | Closed |
| SP-021 | Add a dedicated Epic acceptance-criteria tab with human verification actions. | Closed |
| SP-022 | Enable Sprint close and Epic complete/close only when prerequisites are satisfied. | Closed |
| SP-023 | Archive closed Sprint and Epic records into the documented closed layout and refresh the indexes. | Active |
| SP-024 | Prove the closeout workflow with tests and keep the documentation synchronized. | Planning |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0101 | Define Epic acceptance criteria verification model | Verified |
| T-0102 | Extend planning model for Epic and Sprint close eligibility | Verified |
| T-0103 | Add Epic acceptance-criteria loading and summary rendering | Verified |
| T-0104 | Add Epic Acceptance Criteria tab to the planning panel | Verified |
| T-0105 | Add verification actions for Epic acceptance criteria | Verified |
| T-0106 | Add accessibility, selection, and evidence behavior for the criteria tab | Verified |
| T-0107 | Gate Sprint close on verified Tasks and Issues | Implemented - Not Verified |
| T-0108 | Gate Epic close on verified acceptance criteria | Implemented - Not Verified |
| T-0109 | Add close-action messaging and disabled-state behavior | Implemented - Not Verified |
| T-0110 | Move closed Sprint records into `docs/Sprints/Closed/` | Backlog |
| T-0111 | Move closed Epic records into `docs/Epics/Closed/` | Backlog |
| T-0112 | Rewrite sprint and epic index files on close | Backlog |
| T-0113 | Add tests for Epic acceptance-criteria verification | Backlog |
| T-0114 | Add tests for Sprint and Epic archive updates | Backlog |
| T-0115 | Add tests for offline local-only closeout behavior | Backlog |

*Last Updated: 2026-06-25 (EP-018 active with SP-023 active and SP-024 planning)*
