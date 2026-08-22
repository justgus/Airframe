# GitHub Issue Mapping

This document records the required one-to-one mapping between GitHub Issues and Airframe work records.

## Rules

- Every Airframe Task must have exactly one GitHub Issue number.
- Every Airframe Issue must have exactly one GitHub Issue number.
- Every GitHub Issue in this repository must be assigned to exactly one Airframe Task ID or one Airframe Issue ID.
- Task GitHub Issue titles must begin with `[T-XXXX]`.
- Issue GitHub Issue titles must begin with `[I-XXXX]`.
- GitHub Issue bodies must include `Airframe Type:` and `Airframe ID:` fields.
- Local status changes must be reflected in the linked GitHub Issue, and GitHub closure must be reflected in the local Airframe record.

## Current Task Mapping

| Airframe Task | GitHub Issue | Epic | Title |
| ------------- | ------------ | ---- | ----- |
| T-0001 | #1 | EP-001 | Scaffold AirframeCore Swift package |
| T-0002 | #2 | EP-001 | Scaffold AICockpit Swift package executable |
| T-0003 | #3 | EP-001 | Scaffold AgileCockpit macOS SwiftUI app |
| T-0004 | #4 | EP-001 | Assemble Airframe workspace and schemes |
| T-0005 | #5 | EP-001 | Establish baseline build and test documentation |
| T-0006 | #6 | EP-001 | Verify clean checkout workspace baseline |
| T-0007 | #7 | EP-002 | Define canonical domain model |
| T-0008 | #8 | EP-002 | Define configuration model and fixtures |
| T-0009 | #9 | EP-002 | Implement AirframeCore configuration loading |
| T-0010 | #10 | EP-002 | Implement AICockpit context display |
| T-0011 | #11 | EP-002 | Implement AgileCockpit project context UI |
| T-0012 | #12 | EP-003 | Implement actor and certified context model |
| T-0013 | #13 | EP-003 | Implement authority evaluator |
| T-0014 | #14 | EP-003 | Implement workflow transition evaluator |
| T-0015 | #15 | EP-003 | Implement audit event service |
| T-0016 | #16 | EP-003 | Implement AICockpit denied-operation output |
| T-0017 | #17 | EP-003 | Implement AgileCockpit authority and audit display |
| T-0018 | #18 | EP-004 | Define backend adapter protocol and capabilities |
| T-0019 | #19 | EP-004 | Implement local filesystem backend |
| T-0020 | #20 | EP-004 | Implement evidence attachment workflow |
| T-0021 | #21 | EP-004 | Implement task packet generation |
| T-0022 | #22 | EP-004 | Implement local dashboard summary APIs |
| T-0023 | #23 | EP-005 | Finalize AICockpit MVP command names and parser |
| T-0024 | #24 | EP-005 | Implement issue and task proposal commands |
| T-0025 | #25 | EP-005 | Implement next-task and task-packet commands |
| T-0026 | #26 | EP-005 | Implement evidence and ready-for-verification commands |
| T-0027 | #27 | EP-005 | Implement Markdown and JSON output contracts |
| T-0028 | #28 | EP-005 | Document AICockpit agent usage |
| T-0029 | #29 | EP-006 | Implement AgileCockpit application shell |
| T-0030 | #30 | EP-006 | Implement dashboard summary UI |
| T-0031 | #31 | EP-006 | Implement verification queue and review flow |
| T-0032 | #32 | EP-006 | Implement human verification actions |
| T-0033 | #33 | EP-006 | Implement sprint and epic read views |
| T-0034 | #34 | EP-006 | Implement metrics and audit views |
| T-0035 | #35 | EP-006 | Add primary accessibility and UI tests |
| T-0036 | #36 | EP-007 | Implement GitHub backend capability map and configuration |
| T-0037 | #37 | EP-007 | Implement GitHub issue/task mapping |
| T-0038 | #38 | EP-007 | Implement GitHub sprint/epic/evidence mapping |
| T-0039 | #39 | EP-007 | Integrate GitHub backend with AICockpit |
| T-0040 | #40 | EP-007 | Integrate GitHub backend status with AgileCockpit |
| T-0041 | #41 | EP-008 | Add full regression and integration test pass |
| T-0042 | #42 | EP-008 | Harden CLI output and error contracts |
| T-0043 | #43 | EP-008 | Harden AgileCockpit accessibility and UI flows |
| T-0044 | #44 | EP-008 | Add configuration diagnostics and failure handling |
| T-0045 | #45 | EP-008 | Write release candidate verification documentation |
| T-0046 | #46 | EP-009 | Define live demo workspace configuration contract |
| T-0047 | #47 | EP-009 | Implement AICockpit runtime configuration selection |
| T-0048 | #48 | EP-009 | Implement AgileCockpit runtime configuration selection |
| T-0049 | #49 | EP-009 | Add Airframe live demo project configuration and usage docs |
| T-0050 | #50 | EP-009 | Verify Slice 1 live project identity and fallback behavior |
| T-0051 | #51 | EP-010 | Define live GitHub issue transport and failure contract |
| T-0052 | #52 | EP-010 | Implement read-only GitHub issue listing backend |
| T-0053 | #53 | EP-010 | Implement GitHub issue-to-work-record parsing |
| T-0054 | #54 | EP-010 | Wire github-issues into AICockpit commands |
| T-0055 | #55 | EP-010 | Verify read-only GitHub adapter behavior and docs |
| T-0056 | #56 | EP-011 | Wire AgileCockpit live backend configuration |
| T-0057 | #59 | EP-011 | Load live GitHub dashboard counts in AgileCockpit |
| T-0058 | #57 | EP-011 | Show live sprint and epic planning state |
| T-0059 | #60 | EP-011 | Show live implemented-not-verified work |
| T-0060 | #58 | EP-011 | Verify AgileCockpit live project view behavior |
| T-0061 | #61 | EP-012 | Define project-local demo artifact layout |
| T-0062 | #65 | EP-012 | Install aicockpit into the project-local demo layout |
| T-0063 | #64 | EP-012 | Install AgileCockpit.app into the project-local demo layout |
| T-0064 | #63 | EP-012 | Document project-local demo installation and verification |
| T-0065 | #62 | EP-012 | Verify project-local installation without manual Cockpit launch |
| T-0066 | #66 | EP-013 | Define controlled GitHub mutation authority contract |
| T-0067 | #67 | EP-013 | Add GitHub issue comment mutation support |
| T-0068 | #68 | EP-013 | Add controlled GitHub status label transition support |
| T-0069 | #69 | EP-013 | Wire explicit mutation commands and UI affordances |
| T-0070 | #70 | EP-013 | Verify controlled mutation safety and documentation |
| T-0071 | #71 | EP-014 | Define Slice 6 end-to-end demo script and success criteria |
| T-0072 | #75 | EP-014 | Rehearse project-local AICockpit live GitHub workflow |
| T-0073 | #72 | EP-014 | Rehearse AgileCockpit live project review workflow |
| T-0074 | #74 | EP-014 | Verify controlled GitHub write demo with explicit approval |
| T-0075 | #73 | EP-014 | Document final live demo runbook and rollback notes |
| T-0076 | #77 | EP-015 | Define AgileCockpit planning operation contract |
| T-0077 | #79 | EP-015 | Add AirframeCore planning APIs for artifact operations |
| T-0078 | #80 | EP-015 | Implement AgileCockpit task and issue planning UI |
| T-0079 | #78 | EP-015 | Implement AgileCockpit sprint and epic management UI |
| T-0080 | #76 | EP-015 | Verify planning management workflow and documentation |
| T-0086 | #86 | EP-017 | Reconcile Agile artifact workflow documentation and process guardrails |
| T-0087 | #87 | EP-017 | Define artifact-specific status presentation model |
| T-0088 | #88 | EP-017 | Replace dashboard metrics with workflow status tiles |
| T-0089 | #89 | EP-017 | Add interactive dashboard status drill-down |
| T-0090 | #90 | EP-017 | Verify dashboard workflow and integrate draft patch |
| T-0091 | #91 | EP-017 | Define AICockpit work item mutation command contract |
| T-0092 | #92 | EP-017 | Implement AICockpit local work item mutation support |
| T-0093 | #93 | EP-017 | Implement controlled GitHub work item mutation support |
| T-0094 | #94 | EP-017 | Add AICockpit Sprint and Epic planning mutation support |
| T-0095 | #95 | EP-017 | Verify AICockpit mutation authority boundaries |
| T-0096 | #96 | EP-017 | Define AgileCockpit human mutation authority contract |
| T-0097 | #97 | EP-017 | Implement AgileCockpit local verification mutations |
| T-0098 | #98 | EP-017 | Implement AgileCockpit controlled GitHub verification mutations |
| T-0099 | #99 | EP-017 | Add human verification UI flows for Tasks and Issues |
| T-0100 | #100 | EP-017 | Verify AICockpit and AgileCockpit authority separation |
| T-0101 | #105 | EP-018 | Define Epic acceptance criteria verification model |
| T-0102 | #106 | EP-018 | Extend planning model for Epic and Sprint close eligibility |
| T-0103 | #107 | EP-018 | Add Epic acceptance-criteria loading and summary rendering |
| T-0104 | #108 | EP-018 | Add Epic Acceptance Criteria tab to the planning panel |
| T-0105 | #110 | EP-018 | Add verification actions for Epic acceptance criteria |
| T-0106 | #109 | EP-018 | Add accessibility, selection, and evidence behavior for the criteria tab |
| T-0107 | #113 | EP-018 | Gate Sprint close on verified Tasks and Issues |
| T-0108 | #114 | EP-018 | Gate Epic close on verified acceptance criteria |
| T-0109 | #115 | EP-018 | Add close-action messaging and disabled-state behavior |
| T-0115 | #152 | EP-018 | Add tests for offline local-only closeout behavior |
| T-0116 | #116 | EP-020 | Define canonical workflow record schemas |
| T-0117 | #117 | EP-020 | Implement repo-local JSON canonical store |
| T-0118 | #118 | EP-020 | Encode workflow policy definitions in AirframeCore |
| T-0119 | #119 | EP-020 | Add canonical state validation diagnostics |
| T-0120 | #120 | EP-020 | Build Markdown artifact importer for existing work products |
| T-0121 | #121 | EP-020 | Generate deterministic Markdown projections from canonical records |
| T-0122 | #122 | EP-020 | Add import and projection regression coverage |
| T-0123 | #123 | EP-020 | Document canonical migration and projection workflow |
| T-0124 | #124 | EP-020 | Move AICockpit project summary to canonical records |
| T-0125 | #125 | EP-020 | Move AICockpit task packet generation to canonical records |
| T-0126 | #126 | EP-020 | Add AICockpit canonical state diagnostics command |
| T-0127 | #127 | EP-020 | Verify AICockpit authority boundaries against canonical state |
| T-0128 | #128 | EP-020 | Move AgileCockpit dashboard and planning views to canonical records |
| T-0129 | #129 | EP-020 | Add AgileCockpit data health diagnostics surface |
| T-0130 | #130 | EP-020 | Add AgileCockpit repair preview flow for canonical diagnostics |
| T-0131 | #131 | EP-020 | Verify end-to-end canonical workflow state behavior |
| T-0135 | #134 | EP-021 | Implement traceability graph and bidirectional queries |
| T-0136 | #136 | EP-021 | Add traceability gap diagnostics |
| T-0137 | #135 | EP-021 | Add requirement revision and source metadata |
| T-0138 | #137 | EP-021 | Implement evidence summaries and CI artifact links |
| T-0139 | #138 | EP-021 | Add release scope and gate evaluation |
| T-0140 | #139 | EP-021 | Add AgileCockpit release gate and traceability views |
| T-0141 | #140 | EP-021 | Generate compliance and traceability documents |
| T-0142 | #141 | EP-021 | Add regression tests for import/export, traceability, and gates |
| T-0143 | #142 | EP-021 | Define AICockpit requirements import command contract |
| T-0144 | #143 | EP-021 | Implement canonical requirements import apply path |
| T-0145 | #144 | EP-021 | Add Markdown requirements seed import support |
| T-0146 | #145 | EP-021 | Regenerate requirements documentation from canonical state |
| T-0147 | #146 | EP-021 | Add requirements import regression coverage |
| T-0148 | #161 | EP-019 | Inventory offline runtime dependencies |
| T-0149 | #162 | EP-019 | Define local-only operating profile |
| T-0150 | #163 | EP-019 | Harden AICockpit offline work item flows |
| T-0151 | #164 | EP-019 | Harden AgileCockpit offline application flows |
| T-0152 | #165 | EP-019 | Prove Sprint and Epic workflows operate offline |
| T-0153 | #166 | EP-019 | Add offline regression verification suite |
| T-0154 | TBD | EP-023 | Define canonical plan review record and decision model |
| T-0155 | TBD | EP-023 | Add AirframeCore authority and audit support for plan decisions |
| T-0156 | TBD | EP-023 | Add AICockpit plan submission and read commands |
| T-0157 | TBD | EP-023 | Add AgileCockpit plan review UI |
| T-0158 | TBD | EP-023 | Wire AgileCockpit human plan decision actions |
| T-0159 | TBD | EP-023 | Add plan review regression coverage and workflow documentation |
| T-0160 | #170 | EP-024 | Define canonical test records and requirement trace model |
| T-0161 | #174 | EP-024 | Seed canonical test definitions for the Airframe dataset |
| T-0162 | #169 | EP-024 | Add AICockpit test definition and management commands |
| T-0163 | #171 | EP-024 | Add AgileCockpit Tests tab |
| T-0164 | #173 | EP-024 | Define EP-023 acceptance criteria for requirements without AC coverage |
| T-0165 | #172 | EP-024 | Verify test management workflow and documentation |

## Current Issue Mapping

| Airframe Issue | GitHub Issue | Epic | Title |
| -------------- | ------------ | ---- | ----- |
| I-0001 | #101 | EP-017 | Dashboard status drill-down shows stray blue selection rectangle |
| I-0002 | #102 | EP-017 | Status drill-down detail pane omits full work product text |
| I-0003 | #103 | EP-017 | Status drill-down detail pane uses incomplete fallback text for Tasks and Issues |
| I-0004 | #104 | EP-017 | Status drill-down detail scroll position is retained across item selection |
| I-0005 | #111 | EP-018 | AgileCockpit header emphasizes app identity over project identity |
| I-0006 | #112 | EP-018 | AgileCockpit cannot run concurrent project instances |
| I-0007 | #132 | EP-020 | Verification tab can stall or fail silently while loading queue details |
| I-0008 | #133 | EP-020 | Canonical state cannot represent Review Sprints and backend label reconciliation |
| I-0009 | #147 | None | Epic close leaves stale active pointers and sprint closeout state |
| I-0010 | #148 | EP-018 | Sprint close does not archive Markdown Sprint record |
| I-0011 | #149 | EP-018 | Epic close does not archive Markdown Epic record |
| I-0012 | #150 | EP-018 | Close actions do not refresh Sprint and Epic indexes |
| I-0013 | #151 | EP-018 | Epic close eligibility ignores open Sprints |
| I-0023 | #167 | EP-023 | Requirements tab freezes while loading traceability data |
| I-0024 | #168 | EP-023 | Requirements traceability matrix includes excessive derived work links |
| I-0025 | #175 | EP-024 | Active Sprint cannot be returned directly to Backlog |
| I-0026 | #176 | EP-024 | AgileCockpit cannot view or modify non-current Review Sprint |
| I-0027 | #177 | Agile Cockpit: support branch-based workspace mutations |

Next local Issue ID: `I-0027`.

*Last Updated: 2026-08-22 (GitHub issue sync)*
