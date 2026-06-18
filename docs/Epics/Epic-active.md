# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

## EP-020: Canonical Airframe Workflow State

**Status:** Active
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-17
**Target Close Date:** TBD
**Close Date:** TBD

**Goal:**
Move Airframe workflow state from Markdown-authored artifacts to AirframeCore-owned canonical structured records, with validation diagnostics, migration support, generated documentation projections, and repo-coupled history.

**Rationale:**
EP-018 exposed that Markdown artifacts currently act as both human-readable documentation and mutable canonical state. That makes Airframe vulnerable to inconsistent states where an Epic, Sprint, Task, Issue, index, workspace configuration, and GitHub label disagree. Airframe needs a canonical repo-local state model owned by AirframeCore so workflow state evolves with the source code and remains valid across branches, forks, checkouts, reverts, and release tags.

**Scope:**
- Define canonical AirframeCore record models for Workspace, Project, Epic, Sprint, Task, Issue, acceptance criteria, evidence summaries, audit events, backend mappings, workflow definitions, and workflow transitions.
- Select and implement the initial repo-local structured store shape, expected to start as one JSON file per canonical record unless the storage trade study changes direction.
- Encode current Epic, Sprint, Task, and Issue workflow policies in AirframeCore instead of relying on guideline Markdown as authority.
- Add validation diagnostics for active/backlog/closed inconsistencies, relationship drift, invalid configured active work, and unsupported human-only mutations.
- Add import support from the current Markdown artifacts into canonical records.
- Add deterministic Markdown projection support for human-readable documentation.
- Update AICockpit to query canonical records for discovery, summaries, and task packets.
- Update AgileCockpit to read canonical records for dashboard and planning views.
- Preserve human-only authority boundaries for verification, Sprint closure, Epic closure, destructive repair, and policy mutation.

**Out of Scope:**
- Native DOORS or enterprise requirements-tool integration.
- Full release candidate closeout gating.
- Compliance document generation beyond schema stubs and projection groundwork.
- Removing existing Markdown artifacts before migration and projection behavior is verified.
- Making GitHub Issues the canonical source of Airframe workflow state.

**Acceptance Criteria:**
1. AirframeCore defines canonical Codable records for core work products, workflow policy, evidence summaries, and audit events.
2. AirframeCore can load and validate a repo-local canonical workflow store.
3. AirframeCore diagnostics detect invalid active/backlog/closed states and relationship drift.
4. Existing Markdown work artifacts can be imported into canonical records with stable IDs preserved.
5. Markdown documentation can be generated deterministically from canonical records.
6. AICockpit reads project summaries and task packets from canonical records without reparsing Markdown as the primary state source.
7. AgileCockpit dashboard and planning views can render from canonical records.
8. Human-only transitions remain blocked outside human-authorized AgileCockpit workflows.
9. Tests cover canonical load, validation, import, projection, and authority-preserving mutation behavior.

### Related Planning Documents

- [Architecture Modification Plan](../Architecture-Modification-Plan.md)
- [Canonical Workflow State Requirements](../requirements/CanonicalWorkflowState_Requirements.md)
- [Canonical Workflow State Storage Trade Study](../architecture/CanonicalWorkflowState_Storage_Trade_Study.md)

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-025 | Define the canonical store schema, workflow policy records, and validation diagnostics. | Closed |
| SP-026 | Import current Markdown artifacts into canonical records and generate deterministic documentation projections. | Active |
| SP-027 | Move AICockpit read paths and diagnostics onto canonical workflow state. | Backlog |
| SP-028 | Move AgileCockpit dashboard, planning, and data-health views onto canonical workflow state. | Backlog |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0116 | Define canonical workflow record schemas | Verified |
| T-0117 | Implement repo-local JSON canonical store | Verified |
| T-0118 | Encode workflow policy definitions in AirframeCore | Verified |
| T-0119 | Add canonical state validation diagnostics | Verified |
| T-0120 | Build Markdown artifact importer for existing work products | Implemented |
| T-0121 | Generate deterministic Markdown projections from canonical records | Active |
| T-0122 | Add import and projection regression coverage | Active |
| T-0123 | Document canonical migration and projection workflow | Active |
| T-0124 | Move AICockpit project summary to canonical records | Backlog |
| T-0125 | Move AICockpit task packet generation to canonical records | Backlog |
| T-0126 | Add AICockpit canonical state diagnostics command | Backlog |
| T-0127 | Verify AICockpit authority boundaries against canonical state | Backlog |
| T-0128 | Move AgileCockpit dashboard and planning views to canonical records | Backlog |
| T-0129 | Add AgileCockpit data health diagnostics surface | Backlog |
| T-0130 | Add AgileCockpit repair preview flow for canonical diagnostics | Backlog |
| T-0131 | Verify end-to-end canonical workflow state behavior | Backlog |

### Related Issues

TBD.

### Notes

- This Epic is the architectural foundation for resuming EP-018 safely.
- EP-019 offline-only operation remains relevant and may be informed by the canonical local store design.
- GitHub should be treated as an optional integration or projection target, not the canonical store for repo-coupled workflow state.
- SP-026 is Active for Markdown import and deterministic projection implementation.

*Last Updated: 2026-06-18 (T-0120 implemented pending human verification)*
