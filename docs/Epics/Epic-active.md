# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

## EP-018: AgileCockpit Sprint and Epic Status Controls

**Status:** Active
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-15
**Target Close Date:** TBD
**Close Date:** TBD

**Goal:**
Add human-facing AgileCockpit controls for Sprint and Epic status mutation, including Epic acceptance-criteria verification, Sprint close gating, and Epic close gating with archive updates.

**Rationale:**
EP-017, SP-017, SP-018, and SP-019 established the workflow dashboard, mutation authority, and Task/Issue verification flows. The remaining gap is that AgileCockpit still cannot help a human verify Epic acceptance criteria or close and archive a Sprint or Epic after the assigned work is complete.

**Scope:**
- Add an Epic Acceptance Criteria tab to the Sprint & Epic panel.
- Show each Epic acceptance criterion and allow it to be marked verified by a human reviewer.
- Gate Sprint close on all assigned Tasks and Issues being verified.
- Gate Epic complete and close on all acceptance criteria being verified.
- Archive closed Sprint and Epic records into the documented `Closed/` layout and update index files.
- Preserve existing human-only authority boundaries and keep agent-facing tools out of the close path.

**Out of Scope:**
- Granting AICockpit Sprint or Epic close authority.
- Automatic close without explicit human action.
- Creating GitHub issues for Epics or Sprints where no remote artifact store exists.
- Reworking the already closed EP-017/SP-017/SP-018/SP-019 history.

**Acceptance Criteria:**
1. AgileCockpit shows Epic acceptance criteria in a dedicated tab or equivalent panel.
2. A human can mark Epic acceptance criteria verified in the UI.
3. A Sprint close action is enabled only after all Sprint Tasks and Issues are verified.
4. An Epic complete or close action is enabled only after all Epic acceptance criteria are verified.
5. Closing a Sprint archives the Sprint record and updates the Sprint index.
6. Closing an Epic archives the Epic record and updates the Epic index.
7. Tests cover local workspace behavior and live GitHub-issues workspace behavior where applicable.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-020 | Add Epic acceptance-criteria state and close-eligibility tracking to the planning model. | Active |
| SP-021 | Add a dedicated Epic acceptance-criteria tab with human verification actions. | Backlog |
| SP-022 | Enable Sprint close and Epic complete/close only when prerequisites are satisfied. | Backlog |
| SP-023 | Archive closed Sprint and Epic records into the documented closed layout and refresh the indexes. | Backlog |
| SP-024 | Prove the closeout workflow with tests and keep the documentation synchronized. | Backlog |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0101 | Define Epic acceptance criteria verification model | Active |
| T-0102 | Extend planning model for Epic and Sprint close eligibility | Active |
| T-0103 | Add Epic acceptance-criteria loading and summary rendering | Active |
| T-0104 | Add Epic Acceptance Criteria tab to the planning panel | Backlog |
| T-0105 | Add verification actions for Epic acceptance criteria | Backlog |
| T-0106 | Add accessibility, selection, and evidence behavior for the criteria tab | Backlog |
| T-0107 | Gate Sprint close on verified Tasks and Issues | Backlog |
| T-0108 | Gate Epic close on verified acceptance criteria | Backlog |
| T-0109 | Add close-action messaging and disabled-state behavior | Backlog |
| T-0110 | Move closed Sprint records into `docs/Sprints/Closed/` | Backlog |
| T-0111 | Move closed Epic records into `docs/Epics/Closed/` | Backlog |
| T-0112 | Rewrite sprint and epic index files on close | Backlog |
| T-0113 | Add tests for Epic acceptance-criteria verification | Backlog |
| T-0114 | Add tests for Sprint and Epic archive updates | Backlog |
| T-0115 | Add tests for offline local-only closeout behavior | Backlog |

### Related Issues

None.

### Notes

- The new Epic is intentionally split from EP-017 because it extends the planning surface rather than the workflow dashboard and mutation-authority foundation.
- Sprint/Epic closeout remains a human action; the app should only enable the action when the state is ready.

*Last Updated: 2026-06-15 (EP-018 activated with SP-020)*
