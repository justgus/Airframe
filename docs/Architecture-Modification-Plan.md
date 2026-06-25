# Airframe Architecture Modification Plan

**Status:** Planning  
**Date:** 2026-06-17  
**Planning Trigger:** EP-018 data-state inconsistency exposed that Markdown artifacts are carrying both human-readable documentation and canonical workflow state.  
**Current Work Posture:** EP-018 is active again with SP-022 active for Sprint and Epic close gating verification.

## Related Planning Documents

- [Canonical Workflow State Requirements](requirements/CanonicalWorkflowState_Requirements.md)
- [Requirements Traceability Requirements](requirements/RequirementsTraceability_Requirements.md)
- [Canonical Workflow State Storage Trade Study](architecture/CanonicalWorkflowState_Storage_Trade_Study.md)
- [Requirements Traceability Import Export Plan](architecture/RequirementsTraceability_ImportExport_Plan.md)

## 1. Objective

Move Airframe from Markdown-first workflow state to AirframeCore-owned canonical workflow state.

The target architecture keeps work records human readable through AgileCockpit views and generated documentation, while making AirframeCore the authority for:

- Work item identity.
- Work item relationships.
- Workflow status.
- Acceptance criteria.
- Verification state.
- Evidence.
- Actor authority.
- Transition rules.
- Validation diagnostics.
- Backend capabilities.

Markdown should become a generated or exported projection of canonical state, not the primary mutable database for workflow decisions.

Airframe work products should remain repo-coupled. Epics, Sprints, Tasks, Issues, Requirements, traceability links, and verification summaries should evolve with the source code so that a branch, fork, checkout, revert, or release tag carries the development state that existed with that code.

## 2. Problem Statement

The current architecture allows the same project fact to exist in multiple places:

- `.airframe/airframe-workspace.json`
- `docs/Epics/Epic-active.md`
- `docs/Epics/Epic-backlog.md`
- `docs/Epics/Epic-Documentation.md`
- `docs/Sprints/Sprint-backlog.md`
- `docs/Tasks/Task-backlog.md`
- GitHub issue labels and state

This creates opportunities for drift. EP-018 demonstrated a concrete failure mode: AgileCockpit showed an Epic as closed because the Epic record status said `Closed`, while the same Epic was still configured as active, still physically located in `Epic-active.md`, and still owned backlog Sprints and Tasks.

The root problem is not only Markdown parsing. The root problem is that Airframe lacks a single canonical workflow-state authority with enforced invariants.

The same issue applies to requirements and verification evidence. Test runs, CI results, and release decisions need traceability to requirements without committing every raw local test run into the repository.

## 3. Architectural Direction

AirframeCore becomes the canonical workflow engine and state authority.

### 3.1 AirframeCore

AirframeCore shall own:

- Typed schemas for Epics, Sprints, Tasks, Issues, acceptance criteria, evidence, audit events, and workflow definitions.
- Typed schemas for requirements, requirement revisions, trace links, deviations, waivers, release scopes, and release gate results.
- Relationship indexes between Epics, Sprints, Tasks, Issues, GitHub issues, evidence, and acceptance criteria.
- Workflow policy definitions currently described in guideline Markdown.
- State transition validation.
- Authority evaluation for human and agent actors.
- Consistency diagnostics and recommended repairs.
- Canonical persistence APIs.
- Projection APIs for AgileCockpit, AICockpit, Markdown export, and GitHub synchronization.
- Import/export adapter boundaries for CSV, JSON, and future external requirements tools.

### 3.2 AgileCockpit

AgileCockpit becomes the primary human-facing editor and repair surface for canonical Airframe state.

AgileCockpit shall:

- Render human-readable views from canonical records.
- Perform human-authorized mutations through AirframeCore.
- Show data-health diagnostics before normal planning workflows when state is inconsistent.
- Provide guided repair actions for known inconsistency classes.
- Preserve human approval requirements for verification, Sprint closure, Epic closure, and policy changes.
- Show release candidate close criteria, traceability gaps, deviations, waivers, and requirement verification status.

### 3.3 AICockpit

AICockpit becomes an agent-facing interface over canonical state instead of a Markdown parser.

AICockpit shall:

- Query structured records directly through AirframeCore.
- Create, update, and transition only agent-authorized work.
- Return compact structured task packets without reparsing Markdown.
- Attach evidence or evidence references where backend capability allows.
- Refuse human-only actions through policy, not command omission alone.
- Report requirement traceability and release gate diagnostics in structured output.

### 3.4 Markdown

Markdown remains useful, but not authoritative.

Markdown shall become:

- A generated documentation projection.
- A human-readable export format.
- A migration input during transition.
- An archive snapshot format where useful.
- A generated source for compliance and traceability documents when templates are available.

Markdown shall not be the only place where workflow status, relationships, or verification state are stored.

## 4. Canonical State Model

The first implementation target should be a local structured store. JSON is the preferred bootstrap format because it is local, diffable, easy to inspect, and compatible with existing repository workflows.

The storage format is an implementation detail. The architectural requirement is a canonical AirframeCore record model.

### 4.1 Candidate Record Types

- `WorkspaceRecord`
- `ProjectRecord`
- `EpicRecord`
- `SprintRecord`
- `TaskRecord`
- `IssueRecord`
- `AcceptanceCriterionRecord`
- `RequirementRecord`
- `RequirementRevisionRecord`
- `EvidenceRecord`
- `TestCaseRecord`
- `TestResultSummaryRecord`
- `TraceLinkRecord`
- `DeviationRecord`
- `WaiverRecord`
- `ReleaseScopeRecord`
- `ReleaseGateRecord`
- `WorkflowDefinition`
- `WorkflowTransition`
- `AuthorityRule`
- `AuditEvent`
- `BackendMapping`

### 4.2 Core Relationships

Canonical records must represent relationships by stable IDs:

- Project owns Epics, Sprints, Tasks, and Issues.
- Epic owns or references Sprints, Tasks, Issues, and acceptance criteria.
- Sprint owns or references Tasks and Issues.
- Task and Issue records may reference GitHub issue numbers.
- Acceptance criteria may reference Tasks, Issues, evidence, tests, or manual verification records.
- Requirements may reference Tasks, Issues, tests, design records, source references, evidence, deviations, waivers, and release scopes.
- Evidence records reference work items and artifacts.
- Test result summaries reference requirements and optional CI artifacts.
- Audit events reference actor, operation, before-state, after-state, and decision.

### 4.3 Required Invariants

AirframeCore should validate at least these invariants:

- A configured active Epic must exist and must have status `Active`.
- A configured active Sprint must exist and must have status `Active`.
- A closed Epic cannot be the configured active Epic.
- A closed Sprint cannot be the configured active Sprint.
- A closed Epic must not own Backlog, Active, Planning, Review, or Implemented work unless that work was explicitly carried forward or descoped.
- A closed Sprint must not contain unresolved active work.
- An Epic in backlog cannot be configured as active.
- An Epic in active state must not be located only in an archive projection.
- Each Task and Issue must have one canonical status.
- Status indexes and dashboard counts must be derived from canonical records.
- Human-only transitions must require human authority.
- Agent-facing tools must not perform human verification, Sprint closure, Epic closure, destructive repair, or policy mutation.
- In-scope release requirements must have explicit implemented, deferred, waived, or out-of-scope disposition before release candidate closeout.
- Requirement verification status must be traceable to test, analysis, inspection, demonstration, review, CI evidence, or approved manual evidence.
- Requirement validation status must be traceable to human or stakeholder approval where validation is required.

## 5. Workflow Policy Model

Guideline Markdown currently describes workflow policy. That policy should move into AirframeCore as data and executable rules.

### 5.1 Workflow Definition

A workflow should define:

- Work item kind.
- Allowed statuses.
- Allowed transitions.
- Required actor authority.
- Required preconditions.
- Side effects.
- Audit requirements.
- Repair behavior when state is inconsistent.

### 5.2 Initial Workflows

Initial workflows should cover:

- Epic lifecycle: `Proposed -> Draft -> Backlog -> Active -> Complete -> Closed`
- Sprint lifecycle: `Backlog -> Planning -> Active -> Review -> Closed`
- Task lifecycle: `Backlog -> Active -> Implemented - Not Verified -> Implemented - Verified -> Closed`
- Issue lifecycle: `Backlog -> In Progress -> Resolved - Not Verified -> Resolved - Verified -> Closed`
- Requirement lifecycle: `Proposed -> Draft -> Active -> Implemented -> Verified -> Validated`, with side paths for `Deferred`, `Waived`, `Superseded`, and `Removed`
- Release candidate lifecycle with explicit close criteria

### 5.3 Function Workflows

Airframe should also support named operational workflows that are composed of ordered steps.

Example:

```text
Plan -> Document -> Implement -> Test -> Verify
```

Each step should define:

- Entry criteria.
- Exit criteria.
- Required artifacts.
- Allowed actor types.
- Commands or UI actions that may satisfy the step.
- Evidence requirements.
- Failure and rollback behavior.

This gives Airframe a way to describe not just status transitions, but the required process for executing a function safely.

## 6. Requirements And Release Traceability

Requirements are expected to be fluid during development. Airframe should support requirement changes, imports, exports, traceability, and release gate visibility without becoming a replacement for DOORS or other enterprise requirements tools.

### 6.1 Requirement Scope

Airframe should track requirements that are relevant to the repository state. A requirement may be authored in Airframe, imported from CSV, imported from JSON, generated from another artifact, or imported later from an external requirements tool.

Version 1.0 should prioritize:

- Canonical requirement records.
- CSV import/export.
- JSON import/export.
- Requirement revision metadata.
- Requirement-to-work trace links.
- Requirement-to-test trace links.
- Requirement-to-evidence trace links.
- Deviation and waiver records.
- Release candidate gate summaries.

Native DOORS integration is out of scope for Version 1.0, but the adapter boundary should reserve room for it.

### 6.2 Test Evidence

Airframe should not commit every raw local test run. It should commit summarized verification evidence when that evidence is used to support work item completion, requirement verification, or release candidate closeout.

Evidence summaries should include:

- Command or source.
- Pass/fail result.
- Relevant failing tests.
- Timestamp.
- Environment summary.
- Requirement IDs verified.
- Optional CI run or artifact link.

CI is an evidence provider. AirframeCore remains responsible for deciding whether evidence satisfies requirement verification and release gate policy.

### 6.3 Compliance Outputs

Airframe should be able to generate required engineering documentation from canonical state when templates are available.

Candidate outputs include:

- Compliance Verification Matrix.
- Requirements Traceability Matrix.
- Bidirectional Requirements Traceability Matrix.
- Deviation or waiver report.
- Design document.
- Test plan.
- Verification report.
- Release candidate closeout package.

## 7. Storage Trade Study

The canonical store must be selected with repo-coupled history as a first-class requirement. The current preliminary recommendation is one JSON file per canonical record, plus deterministic generated Markdown projections.

See [Canonical Workflow State Storage Trade Study](architecture/CanonicalWorkflowState_Storage_Trade_Study.md).

## 8. Data Health And Repair

Data inconsistency is inevitable. AgileCockpit should expose correction workflows rather than forcing manual file edits.

### 8.1 Diagnostics

AirframeCore should produce structured diagnostics:

- Severity: info, warning, error, blocking.
- Affected IDs.
- Human-readable explanation.
- Machine-readable reason code.
- Recommended repair options.
- Whether the repair is agent-allowed or human-only.
- Exact records and fields affected by each repair.

### 8.2 AgileCockpit Repair Surface

AgileCockpit should include a Data Health or Reconcile view.

For each diagnostic, AgileCockpit should show:

- What is inconsistent.
- Why it matters.
- The canonical state AirframeCore recommends.
- Available repairs.
- A preview of exact changes.
- Required authority.
- Result after repair validation.

Example repairs:

- Restore an active Epic whose record was incorrectly marked closed.
- Move an active Epic to backlog.
- Clear a configured active Epic that is no longer active.
- Move remaining work to a different Epic.
- Mark remaining work as descoped with human approval.
- Regenerate Markdown projections from canonical records.
- Reconcile local task status with GitHub labels.
- Reconcile requirement import changes.
- Resolve traceability gaps.
- Assign or approve deviations and waivers.

### 8.3 Repair Safety

Repairs should be transactions:

1. Diagnose.
2. Propose.
3. Preview.
4. Approve.
5. Apply.
6. Revalidate.
7. Audit.

Human-only repairs must not be available through AICockpit unless explicitly approved and policy allows the agent to request, not perform, the action.

## 9. Migration Strategy

Migration should be incremental and reversible.

### Phase 1: Schema And Validator

- Define canonical JSON schemas or Codable record models in AirframeCore.
- Include requirement, traceability, test evidence summary, deviation, waiver, and release gate stubs.
- Add validators for current invariant failures.
- Keep Markdown as the source of imported state during this phase.
- Add read-only diagnostics to AICockpit and AgileCockpit.

### Phase 2: Import And Canonical Store

- Build a one-way importer from existing Markdown artifacts into canonical records.
- Add CSV and JSON requirement import/export dry runs.
- Preserve existing IDs.
- Preserve historical notes, evidence, and verification text as structured fields where possible.
- Store unparsed narrative as notes when no structured field exists.
- Add tests proving current docs can be imported.

### Phase 3: Core Mutations

- Route new workflow mutations through AirframeCore canonical APIs.
- Update AICockpit to query and mutate canonical state.
- Update AgileCockpit to query and mutate canonical state.
- Keep Markdown projections generated after canonical writes.

### Phase 4: Markdown Projection

- Generate `docs/Epics`, `docs/Sprints`, `docs/Tasks`, and `docs/Issues` from canonical records.
- Mark generated sections clearly.
- Stop relying on Markdown index files as authority.
- Add projection tests to keep generated documentation stable.
- Add generated requirements and traceability documents.

### Phase 5: GitHub Reconciliation And CI Evidence

- Treat GitHub Issues as an external backend projection or integration target, not the sole canonical store.
- Add explicit local-to-GitHub and GitHub-to-local reconciliation diagnostics.
- Require human approval for remote mutations that change GitHub labels, comments, closure, or issue state.
- Add optional CI evidence links for test, coverage, build, and release candidate evidence.

## 10. CSCI Impact

### 10.1 AirframeCore

Major changes:

- Add canonical record model.
- Add structured local store.
- Add workflow policy model.
- Add validation and repair proposal engine.
- Add import/export projection services.
- Strengthen backend capability model.
- Add requirement traceability, release gate, deviation, waiver, and test evidence summary models.

### 10.2 AICockpit

Major changes:

- Replace Markdown parsing with AirframeCore canonical queries.
- Add diagnostics commands.
- Add structured import/export commands where agent-authorized.
- Preserve existing authority restrictions.
- Keep JSON output stable and compact.

Candidate commands:

```sh
aicockpit state diagnose
aicockpit state export --format markdown
aicockpit state import --from docs --dry-run
aicockpit work get ID --output json
aicockpit workflow describe KIND --output json
aicockpit requirements import --format csv --dry-run
aicockpit requirements export --format csv
aicockpit release gate RC-ID --output json
```

### 10.3 AgileCockpit

Major changes:

- Load dashboard and planning views from canonical records.
- Add Data Health or Reconcile surface.
- Add repair previews.
- Add policy-aware workflow controls.
- Keep human-readable presentation inside the app instead of depending on hand-maintained Markdown.
- Add release candidate close criteria views.
- Add traceability and compliance report generation views.

## 11. Backward Compatibility

During migration:

- Existing Markdown files remain readable.
- Existing IDs remain stable.
- Existing GitHub issue mappings remain valid.
- Existing requirements documents remain importable or linkable where practical.
- Existing AICockpit read commands should continue to work or provide clear migration messages.
- Existing AgileCockpit views should continue to display current project state.
- No historical verification evidence should be discarded.

## 12. Risks And Tradeoffs

### Risks

- Migration may lose nuance from free-form Markdown.
- JSON records may become hard to read if schemas are too broad.
- Generated Markdown may create noisy diffs.
- GitHub/local reconciliation can become complex if both sides are edited independently.
- Over-generalized workflow modeling could slow implementation.
- Requirement traceability could become too heavy and turn Airframe into an unwanted DOORS replacement.
- Generated compliance documentation may depend on templates that vary by project or contract.

### Mitigations

- Start with the smallest canonical schema that supports current Epics, Sprints, Tasks, Issues, ACs, and evidence.
- Preserve unstructured notes during import.
- Keep generated Markdown deterministic.
- Require explicit reconciliation when GitHub and local state diverge.
- Encode only current workflows first; avoid speculative workflow engines beyond known Airframe needs.
- Keep requirements traceability lightweight and repo-focused.
- Treat external requirements tools as import/export sources, not mandatory dependencies.

## 13. Proposed New Epic

Create a new Epic for this architecture pivot.

Suggested title:

```text
EP-020: Canonical Airframe Workflow State
```

Suggested goal:

```text
Move Airframe workflow state from Markdown-authored artifacts to AirframeCore-owned canonical structured records, with diagnostics, migration, generated documentation projections, and AgileCockpit repair workflows.
```

Suggested first Sprint:

```text
SP-025: Canonical State Schema and Diagnostics
```

Candidate Sprint goals:

- Define canonical record schemas.
- Encode current workflow policies in AirframeCore.
- Add validators for active/backlog/closed inconsistencies.
- Add read-only diagnostics to AICockpit.
- Surface diagnostics in AgileCockpit without repair actions yet.
- Add requirement and test evidence schema stubs.

## 14. Open Decisions

1. Should the first canonical store be one JSON file, one file per record, or one folder per work item kind?
2. Should generated Markdown remain in `docs/Tasks`, `docs/Issues`, `docs/Sprints`, and `docs/Epics`, or move to a generated documentation subtree?
3. Should GitHub Issues remain optional projection state, or can GitHub still be canonical for Tasks and Issues in live mode?
4. How should human verification records be represented so they are auditable but not easy for agents to forge?
5. Should workflow definitions be compiled Swift policy, data-driven JSON, or a hybrid?
6. What is the minimum repair set needed before the Markdown source of truth can be retired?
7. What requirement import/export fields are mandatory for Version 1.0?
8. How much test result summary should be committed to the repo versus linked from CI artifacts?
9. What release candidate gate policy should be the default?
10. Where should generated compliance documents be written?

## 15. Immediate Next Steps

1. Review and approve the architectural direction.
2. Decide canonical local store shape.
3. Draft EP-020 and SP-025 artifacts.
4. Define the first AirframeCore record models and validators.
5. Build a dry-run importer from current Markdown artifacts.
6. Add diagnostics for the class of inconsistency found in EP-018.
7. Define Version 1.0 requirement import/export fields.
8. Define release candidate gate summary fields.
9. Define test evidence summary fields and CI link semantics.
