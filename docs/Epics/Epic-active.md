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
| SP-023 | Archive closed Sprint and Epic records into the documented closed layout and refresh the indexes. | Closed |
| SP-024 | Prove the closeout workflow with tests and keep the documentation synchronized. | Active |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0101 | Define Epic acceptance criteria verification model | Implemented - Verified |
| T-0102 | Extend planning model for Epic and Sprint close eligibility | Implemented - Verified |
| T-0103 | Add Epic acceptance-criteria loading and summary rendering | Implemented - Verified |
| T-0104 | Add Epic Acceptance Criteria tab to the planning panel | Implemented - Verified |
| T-0105 | Add verification actions for Epic acceptance criteria | Implemented - Verified |
| T-0106 | Add accessibility, selection, and evidence behavior for the criteria tab | Implemented - Verified |
| T-0107 | Gate Sprint close on verified Tasks and Issues | Implemented - Verified |
| T-0108 | Gate Epic close on verified acceptance criteria | Implemented - Verified |
| T-0109 | Add close-action messaging and disabled-state behavior | Implemented - Verified |
| T-0110 | Move closed Sprint records into `docs/Sprints/Closed/` | Implemented - Verified |
| T-0111 | Move closed Epic records into `docs/Epics/Closed/` | Implemented - Verified |
| T-0112 | Rewrite sprint and epic index files on close | Implemented - Verified |
| T-0113 | Add tests for Epic acceptance-criteria verification | Implemented - Verified |
| T-0114 | Add tests for Sprint and Epic archive updates | Implemented - Verified |
| T-0115 | Add tests for offline local-only closeout behavior | Implemented - Not Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |
| I-0005 | AgileCockpit header emphasizes app identity over project identity | Implemented - Verified |
| I-0006 | AgileCockpit cannot run concurrent project instances | Implemented - Verified |
| I-0010 | Sprint close does not archive Markdown Sprint record | Implemented - Verified |
| I-0011 | Epic close does not archive Markdown Epic record | Implemented - Verified |
| I-0012 | Close actions do not refresh Sprint and Epic indexes | Implemented - Verified |
| I-0013 | Epic close eligibility ignores open Sprints | Implemented - Verified |

*Last Updated: 2026-06-25*
