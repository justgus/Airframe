# EP-020: Canonical Airframe Workflow State

**Status:** Closed
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-17
**Target Close Date:** 2026-06-23
**Close Date:** 2026-06-23

**Goal:**
Move Airframe workflow state from Markdown-authored artifacts to AirframeCore-owned canonical structured records, with validation diagnostics, migration support, generated documentation projections, and repo-coupled history.

**Rationale:**
EP-018 exposed that Markdown artifacts currently act as both human-readable documentation and mutable canonical state. That made Airframe vulnerable to inconsistent states where an Epic, Sprint, Task, Issue, index, workspace configuration, and GitHub label disagreed. Airframe now owns a canonical repo-local state model in AirframeCore so workflow state evolves with the source code and remains valid across branches, forks, checkouts, reverts, and release tags.

**Scope Completed:**
- Canonical AirframeCore record models were defined for Workspace, Project, Epic, Sprint, Task, Issue, acceptance criteria, evidence summaries, audit events, backend mappings, workflow definitions, and workflow transitions.
- The repo-local structured store was implemented as one JSON file per canonical record kind.
- Epic, Sprint, Task, and Issue workflow policies were encoded in AirframeCore instead of relying on guideline Markdown as authority.
- Validation diagnostics were added for active/backlog/closed inconsistencies, relationship drift, invalid configured active work, and unsupported human-only mutations.
- Import support from the current Markdown artifacts into canonical records was added.
- Deterministic Markdown projection support for human-readable documentation was added.
- AICockpit now queries canonical records for discovery, summaries, and task packets.
- AgileCockpit now reads canonical records for dashboard and planning views.
- Human-only authority boundaries remain enforced for verification, Sprint closure, Epic closure, destructive repair, and policy mutation.

**Out of Scope:**
- Native DOORS or enterprise requirements-tool integration.
- Full release candidate closeout gating.
- Compliance document generation beyond schema stubs and projection groundwork.
- Removing existing Markdown artifacts before migration and projection behavior is verified.
- Making GitHub Issues the canonical source of Airframe workflow state.

**Acceptance Criteria:**
1. [x] AirframeCore defines canonical Codable records for core work products, workflow policy, evidence summaries, and audit events.
2. [x] AirframeCore can load and validate a repo-local canonical workflow store.
3. [x] AirframeCore diagnostics detect invalid active/backlog/closed states and relationship drift.
4. [x] Existing Markdown work artifacts can be imported into canonical records with stable IDs preserved.
5. [x] Markdown documentation can be generated deterministically from canonical records.
6. [x] AICockpit reads project summaries and task packets from canonical records without reparsing Markdown as the primary state source.
7. [x] AgileCockpit dashboard and planning views can render from canonical records.
8. [x] Human-only transitions remain blocked outside human-authorized AgileCockpit workflows.
9. [x] Tests cover canonical load, validation, import, projection, and authority-preserving mutation behavior.

### Related Planning Documents

- [Architecture Modification Plan](../Architecture-Modification-Plan.md)
- [Canonical Workflow State Requirements](../requirements/CanonicalWorkflowState_Requirements.md)
- [Canonical Workflow State Storage Trade Study](../architecture/CanonicalWorkflowState_Storage_Trade_Study.md)

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-025 | Define the canonical store schema, workflow policy records, and validation diagnostics. | Closed |
| SP-026 | Import current Markdown artifacts into canonical records and generate deterministic documentation projections. | Closed |
| SP-027 | Move AICockpit read paths and diagnostics onto canonical workflow state. | Closed |
| SP-028 | Move AgileCockpit dashboard, planning, and data-health views onto canonical workflow state. | Closed |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0116 | Define canonical workflow record schemas | Verified |
| T-0117 | Implement repo-local JSON canonical store | Verified |
| T-0118 | Encode workflow policy definitions in AirframeCore | Verified |
| T-0119 | Add canonical state validation diagnostics | Verified |
| T-0120 | Build Markdown artifact importer for existing work products | Verified |
| T-0121 | Generate deterministic Markdown projections from canonical records | Verified |
| T-0122 | Add import and projection regression coverage | Verified |
| T-0123 | Document canonical migration and projection workflow | Verified |
| T-0124 | Move AICockpit project summary to canonical records | Verified |
| T-0125 | Move AICockpit task packet generation to canonical records | Verified |
| T-0126 | Add AICockpit canonical state diagnostics command | Verified |
| T-0127 | Verify AICockpit authority boundaries against canonical state | Verified |
| T-0128 | Move AgileCockpit dashboard and planning views to canonical records | Verified |
| T-0129 | Add AgileCockpit data health diagnostics surface | Verified |
| T-0130 | Add AgileCockpit repair preview flow for canonical diagnostics | Verified |
| T-0131 | Verify end-to-end canonical workflow state behavior | Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |
| I-0007 | Verification tab can stall or fail silently while loading queue details | Verified |
| I-0008 | Canonical state cannot represent Review Sprints and backend label reconciliation | Verified |

### Notes

- This Epic was the architectural foundation for resuming EP-018 safely.
- EP-019 offline-only operation remains relevant and may be informed by the canonical local store design.
- GitHub is treated as an optional integration or projection target, not the canonical store for repo-coupled workflow state.
- SP-026 is Closed after Markdown import and deterministic projection verification.
- SP-027 is Closed after AICockpit canonical state integration verification.
- SP-028 is Closed after AgileCockpit canonical state integration verification.
- T-0128 through T-0131 are Implemented - Verified after SP-028 closeout.
- I-0007 is Resolved - Verified in SP-028 for Verification tab loading and failure-state behavior.
- I-0008 is Resolved - Verified in SP-028 for Review Sprint representation and backend label reconciliation repair behavior.

**Closeout**

The user closed EP-020 on 2026-06-23 after the canonical state migration, documentation projection, and reconciliation work completed.
