# Epic Active

Epics listed here are drafted, active, or complete-pending-close and are the current focus of planning or execution.

---

## EP-021: Requirements Traceability and Release Evidence

**Status:** Active
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-23
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

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-029 | Define the canonical requirement record model and interchange formats. | Backlog |
| SP-030 | Add traceability graph queries, revision metadata, and gap diagnostics. | Backlog |
| SP-031 | Add summarized evidence records, release gates, and Cockpit views. | Backlog |
| SP-032 | Generate compliance documents and regression coverage for the migration. | Backlog |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0132 | Define canonical requirement records | Backlog |
| T-0133 | Implement requirement CSV and JSON interchange | Backlog |
| T-0134 | Add import preview and conflict reporting | Backlog |
| T-0135 | Implement traceability graph and bidirectional queries | Backlog |
| T-0136 | Add traceability gap diagnostics | Backlog |
| T-0137 | Add requirement revision and source metadata | Backlog |
| T-0138 | Implement evidence summaries and CI artifact links | Backlog |
| T-0139 | Add release scope and gate evaluation | Backlog |
| T-0140 | Add AgileCockpit release gate and traceability views | Backlog |
| T-0141 | Generate compliance and traceability documents | Backlog |
| T-0142 | Add regression tests for import/export, traceability, and gates | Backlog |

### Related Issues

TBD.

### Notes

- This Epic is the next planning step after EP-020 canonical workflow state migration.
- The internal state model remains authoritative; Markdown is the export surface for human-readable work products.
- The planned sprints intentionally separate record modeling, traceability diagnostics, release evidence, and generated documents so each increment can be verified independently.
