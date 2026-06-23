# Epic Backlog

Epics listed here are proposed and queued for future planning.

---

## EP-021: Requirements Traceability and Release Evidence

**Status:** Backlog
**Owner:** Human / Airframe Planning
**Start Date:** TBD
**Target Close Date:** TBD
**Close Date:** TBD

**Goal:**
Add lightweight repo-coupled requirements traceability, test evidence summaries, release candidate gate visibility, external import/export stubs, and generated compliance documentation support without turning Airframe into a replacement for DOORS.

**Rationale:**
Airframe work products must connect implementation, tests, evidence, requirements, and release decisions. CI can provide test artifacts and build evidence, but AirframeCore must understand whether in-scope requirements have been implemented, verified, validated, deferred, waived, or blocked. Requirements are fluid during development, so the model must support change and import/export while preserving repo-local development history.

**Scope:**
- Define canonical requirement, requirement revision, trace link, test case, test result summary, deviation, waiver, release scope, and release gate records.
- Support requirement lifecycle states including Proposed, Draft, Active, Implemented, Verified, Validated, Deferred, Waived, Superseded, and Removed.
- Support traceability from requirements to Tasks, Issues, Epics, Sprints, tests, evidence, design records, source references, deviations, waivers, and release scopes.
- Support summarized test evidence linked to requirements without committing every raw local test run.
- Support optional links to CI runs, CI artifacts, build results, coverage results, and release candidate evidence.
- Add CSV and JSON import/export for requirements and traceability data, with dry-run import previews.
- Reserve adapter boundaries for future external requirements tools such as DOORS while keeping native DOORS integration out of Version 1.0.
- Add AgileCockpit views for release candidate close criteria, traceability gaps, deviations, waivers, missing test evidence, and missing human approvals.
- Add generated documentation support for Compliance Verification Matrix, Requirements Traceability Matrix, Bidirectional Requirements Traceability Matrix, deviation or waiver report, test plan, verification report, and release candidate closeout package when templates are available.

**Out of Scope:**
- Native DOORS integration.
- Full enterprise requirements management.
- Mandatory code-comment traceability for every requirement.
- Storing every raw local test run in the repository.
- Complex template authoring workflows.
- Final release closeout automation without human authority.

**Acceptance Criteria:**
1. AirframeCore defines canonical records for requirements, revisions, trace links, test evidence summaries, deviations, waivers, release scopes, and release gates.
2. Requirements can be imported from and exported to CSV.
3. Requirements can be imported from and exported to canonical JSON.
4. Import dry runs report created, updated, unchanged, removed, and conflicted records before mutation.
5. AirframeCore can identify traceability gaps for in-scope requirements.
6. Test evidence summaries can link test outcomes to requirement IDs and optional CI artifacts.
7. AgileCockpit shows release candidate gate status, including implemented, verified, validated, deferred, waived, and blocked requirement counts.
8. AirframeCore can explain why a release candidate can or cannot close.
9. Generated traceability and compliance documents can be produced from canonical state using deterministic default layouts or provided templates.
10. Tests cover import/export, traceability diagnostics, release gate evaluation, and evidence-to-requirement linking.

### Related Planning Documents

- [Architecture Modification Plan](../Architecture-Modification-Plan.md)
- [Canonical Workflow State Requirements](../requirements/CanonicalWorkflowState_Requirements.md)
- [Requirements Traceability Requirements](../requirements/RequirementsTraceability_Requirements.md)
- [Requirements Traceability Import Export Plan](../architecture/RequirementsTraceability_ImportExport_Plan.md)

### Related Sprints

TBD.

### Related Tasks

TBD.

### Related Issues

TBD.

### Notes

- This Epic should follow or overlap carefully with EP-020 only after the canonical store and workflow record model are stable enough to carry requirements and traceability records.
- CI is an evidence provider; AirframeCore owns release gate policy and requirement verification decisions.

---

## EP-018: AgileCockpit Sprint and Epic Status Controls

**Status:** Backlog
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-15
**Target Close Date:** TBD
**Close Date:** TBD

**Goal:**
Add human-facing AgileCockpit controls for Sprint and Epic status mutation, including Epic acceptance-criteria verification, Sprint close gating, and Epic close gating with archive updates.

**Rationale:**
The previous EP-017 Sprint series established the workflow dashboard, mutation authority, and Task/Issue verification flows. The remaining gap is that AgileCockpit still cannot help a human verify Epic acceptance criteria or close and archive a Sprint or Epic after the assigned work is complete.

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
- Reworking the already closed EP-017 history.

**Acceptance Criteria:**
1. [x] AgileCockpit shows Epic acceptance criteria in a dedicated tab or equivalent panel.
2. [x] A human can mark Epic acceptance criteria verified in the UI.
3. [x] A Sprint close action is enabled only after all Sprint Tasks and Issues are verified.
4. [x] An Epic complete or close action is enabled only after all Epic acceptance criteria are verified.
5. [x] Closing a Sprint archives the Sprint record and updates the Sprint index.
6. [x] Closing an Epic archives the Epic record and updates the Epic index.
7. [x] Tests cover local workspace behavior and live GitHub-issues workspace behavior where applicable.

### Related Sprints

| Sprint | Goal                                                                                              | Status  |
| ------ | ------------------------------------------------------------------------------------------------- | ------- |
| SP-020 | Add Epic acceptance-criteria state and close-eligibility tracking to the planning model.          | Closed  |
| SP-021 | Add a dedicated Epic acceptance-criteria tab with human verification actions.                     | Closed  |
| SP-022 | Enable Sprint close and Epic complete/close only when prerequisites are satisfied.                | Backlog |
| SP-023 | Archive closed Sprint and Epic records into the documented closed layout and refresh the indexes. | Backlog |
| SP-024 | Prove the closeout workflow with tests and keep the documentation synchronized.                   | Backlog |

### Related Tasks

| Task   | Title                                                                    | Status   |
| ------ | ------------------------------------------------------------------------ | -------- |
| T-0101 | Define Epic acceptance criteria verification model                       | Verified |
| T-0102 | Extend planning model for Epic and Sprint close eligibility              | Verified |
| T-0103 | Add Epic acceptance-criteria loading and summary rendering               | Verified |
| T-0104 | Add Epic Acceptance Criteria tab to the planning panel                   | Verified |
| T-0105 | Add verification actions for Epic acceptance criteria                    | Verified |
| T-0106 | Add accessibility, selection, and evidence behavior for the criteria tab | Verified |
| T-0107 | Gate Sprint close on verified Tasks and Issues                           | Backlog  |
| T-0108 | Gate Epic close on verified acceptance criteria                          | Backlog  |
| T-0109 | Add close-action messaging and disabled-state behavior                   | Backlog  |
| T-0110 | Move closed Sprint records into `docs/Sprints/Closed/`                   | Backlog  |
| T-0111 | Move closed Epic records into `docs/Epics/Closed/`                       | Backlog  |
| T-0112 | Rewrite sprint and epic index files on close                             | Backlog  |
| T-0113 | Add tests for Epic acceptance-criteria verification                      | Backlog  |
| T-0114 | Add tests for Sprint and Epic archive updates                            | Backlog  |
| T-0115 | Add tests for offline local-only closeout behavior                       | Backlog  |

### Related Issues

| Issue  | Title                                                             | Status   |
| ------ | ----------------------------------------------------------------- | -------- |
| I-0005 | AgileCockpit header emphasizes app identity over project identity | Verified |
| I-0006 | AgileCockpit cannot run concurrent project instances              | Verified |

### Notes

- The Epic is paused in backlog while AirframeCore canonical workflow-state architecture is planned.
- The new Epic is intentionally split from EP-017 because it extends the planning surface rather than the workflow dashboard and mutation-authority foundation.
- Sprint/Epic closeout remains a human action; the app should only enable the action when the state is ready.

---

## EP-019: Airframe Offline-Only Operation

**Status:** Backlog
**Owner:** Human / Airframe Planning
**Start Date:** TBD
**Target Close Date:** TBD
**Close Date:** TBD

**Goal:**
Make Airframe fully functional without GitHub or any backend server so the workspace, CLI, and app can operate entirely offline against local files and local state.

**Rationale:**
The current product still has live GitHub and controlled-remote paths. Those paths are useful, but they are not acceptable as a requirement for basic operation. Airframe must be able to load, inspect, mutate, verify, and archive work completely offline using local data only.

**Scope:**
- Audit all runtime paths in AirframeCore, AICockpit, and AgileCockpit for hidden GitHub or network dependencies.
- Ensure the local filesystem backend is sufficient for day-to-day project operation.
- Make the CLI usable against a purely local workspace without requiring GitHub authentication or network access.
- Make AgileCockpit usable against a purely local workspace without requiring GitHub authentication or network access.
- Preserve existing GitHub-backed functionality as optional, not required.
- Add offline regression coverage for project load, dashboard display, task packets, verification, planning, and archive updates.

**Out of Scope:**
- Removing GitHub support entirely.
- Building a network server or sync service.
- Replacing the local filesystem backend with a new storage engine.
- Changing human-only closeout policy.

**Acceptance Criteria:**
1. Airframe can launch and operate with only the local filesystem backend configured.
2. AICockpit can read, create, update, and transition supported work items offline.
3. AgileCockpit can load the dashboard, review view, planning view, and verification flows offline.
4. Sprint and Epic workflows do not require GitHub access or any remote server for core local operation.
5. Offline regression tests pass without network access or GitHub credentials.
6. GitHub-backed paths remain optional and do not block local workflows when unavailable.

**Implementation Plan:**
1. Inventory all code paths that assume GitHub availability or a remote backend.
2. Separate local-first behavior from optional live-GitHub behavior in AirframeCore and the two client apps.
3. Add explicit offline-mode tests for AICockpit and AgileCockpit against local fixture data.
4. Harden configuration and failure messaging so missing GitHub credentials do not break local usage.
5. Verify that all essential workflows continue to work entirely from the local workspace, including archive and status updates.

**Related Areas:**
- `AirframeCore`
- `AICockpit`
- `AgileCockpit`
- `docs/Tasks/`
- `docs/Issues/`
- `docs/Sprints/`
- `docs/Epics/`

**Notes:**
- This Epic is about survivable product operation, not just “offline-friendly” fallback behavior.
- If a feature cannot operate without GitHub or a server, it should be explicitly marked optional rather than assumed.

---

*Last Updated: 2026-06-17 (EP-020 activated and removed from backlog)*
