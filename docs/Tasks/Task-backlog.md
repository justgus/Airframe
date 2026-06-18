# Task Backlog

Tasks listed here are proposed and not assigned to an active Sprint.

Currently: **21 backlog Tasks**

---

## T-0107: Gate Sprint close on verified Tasks and Issues

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-022
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Sprint close must stay blocked until every Sprint task and issue is verified.

**Acceptance Criteria:**
1. The Sprint close action is disabled or rejected until all assigned Tasks and Issues are verified.
2. The UI explains why the Sprint cannot close yet.
3. A successful close transitions the Sprint out of the active state.

**Evidence:**
- TBD

## T-0108: Gate Epic close on verified acceptance criteria

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-022
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Epic close must stay blocked until every acceptance criterion has been verified by the human reviewer.

**Acceptance Criteria:**
1. The Epic complete/close action is disabled or rejected until all acceptance criteria are verified.
2. The UI explains why the Epic cannot close yet.
3. A successful close transitions the Epic to its closed state.

**Evidence:**
- TBD

## T-0109: Add close-action messaging and disabled-state behavior

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AgileCockpit
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-022
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Users need clear feedback when Sprint or Epic close is unavailable, denied, or completed.

**Acceptance Criteria:**
1. Close actions present clear disabled or denied feedback.
2. Success and failure states are distinguishable in the UI.
3. The current close eligibility is visible without digging through source data.

**Evidence:**
- TBD

## T-0110: Move closed Sprint records into `docs/Sprints/Closed/`

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** Documentation / AgileCockpit
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-023
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Sprint close must archive the Sprint record instead of leaving the Sprint in the active list.

**Acceptance Criteria:**
1. A closed Sprint is written into `docs/Sprints/Closed/`.
2. The active Sprint file no longer contains the closed Sprint.
3. The archived Sprint preserves its closeout details.

**Evidence:**
- TBD

## T-0111: Move closed Epic records into `docs/Epics/Closed/`

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** Documentation / AgileCockpit
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-023
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Epic close must archive the Epic record and preserve the milestone history.

**Acceptance Criteria:**
1. A closed Epic is written into `docs/Epics/Closed/`.
2. The active Epic file no longer contains the closed Epic.
3. The archived Epic preserves its closeout details.

**Evidence:**
- TBD

## T-0112: Rewrite sprint and epic index files on close

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** Documentation
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-023
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
The index pages must stay synchronized when a Sprint or Epic is archived.

**Acceptance Criteria:**
1. `Sprint-Documentation.md` reflects the closed Sprint.
2. `Epic-Documentation.md` reflects the closed Epic.
3. Related counts and next IDs remain correct after close.

**Evidence:**
- TBD

## T-0113: Add tests for Epic acceptance-criteria verification

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AgileCockpitTests / AirframeCoreTests
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-024
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
The acceptance-criteria path needs regression coverage before it can be trusted for closeout.

**Acceptance Criteria:**
1. Tests prove criteria can be marked verified.
2. Tests prove close eligibility changes after verification.
3. Tests prove the tab renders the expected criteria set.

**Evidence:**
- TBD

## T-0114: Add tests for Sprint and Epic archive updates

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AgileCockpitTests / Documentation
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-024
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Archiving is a visible workflow change and needs direct regression coverage.

**Acceptance Criteria:**
1. Tests prove Sprint archive files are updated on close.
2. Tests prove Epic archive files are updated on close.
3. Tests prove the index files remain synchronized after close.

**Evidence:**
- TBD

## T-0115: Add tests for offline local-only closeout behavior

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AgileCockpitTests / AICockpitTests
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-024
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Closeout must continue to work in the local workspace without relying on a server or GitHub.

**Acceptance Criteria:**
1. Tests prove closeout works locally without network access.
2. Tests prove GitHub-specific paths remain optional.
3. Tests prove human-only closeout boundaries are preserved.

**Evidence:**
- TBD

## T-0120: Build Markdown artifact importer for existing work products

**Status:** Backlog
**GitHub Issue:** #120
**Component:** AirframeCore / Documentation
**Priority:** High
**Epic:** EP-020
**Sprint Assigned:** SP-026
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Existing Airframe work history must be preserved when canonical records are introduced.

**Acceptance Criteria:**
1. Existing Epic, Sprint, Task, and Issue Markdown artifacts can be imported into canonical records.
2. Stable IDs, statuses, relationships, evidence notes, and unstructured narrative are preserved where practical.
3. Import produces diagnostics for ambiguous or inconsistent artifacts.

**Evidence:**
- TBD

## T-0121: Generate deterministic Markdown projections from canonical records

**Status:** Backlog
**GitHub Issue:** #121
**Component:** AirframeCore / Documentation
**Priority:** High
**Epic:** EP-020
**Sprint Assigned:** SP-026
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Markdown remains valuable for human review and repository documentation, but it should be generated from canonical state.

**Acceptance Criteria:**
1. AirframeCore can generate Epic, Sprint, Task, and Issue Markdown projections from canonical records.
2. Generated output is deterministic.
3. Index counts and tables are derived from canonical records.

**Evidence:**
- TBD

## T-0122: Add import and projection regression coverage

**Status:** Backlog
**GitHub Issue:** #122
**Component:** AirframeCoreTests
**Priority:** High
**Epic:** EP-020
**Sprint Assigned:** SP-026
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Migration and generated documentation must be trustworthy before Markdown stops being authoritative.

**Acceptance Criteria:**
1. Tests prove current Markdown artifacts import into canonical records.
2. Tests prove generated Markdown projections are deterministic.
3. Tests prove invalid source artifacts produce diagnostics.

**Evidence:**
- TBD

## T-0123: Document canonical migration and projection workflow

**Status:** Backlog
**GitHub Issue:** #123
**Component:** Documentation
**Priority:** Medium
**Epic:** EP-020
**Sprint Assigned:** SP-026
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
The project needs a documented migration path so users understand canonical state, generated docs, and manual edit boundaries.

**Acceptance Criteria:**
1. Documentation explains canonical state ownership.
2. Documentation explains Markdown import and projection behavior.
3. Documentation identifies which files should and should not be manually edited after migration.

**Evidence:**
- TBD

## T-0124: Move AICockpit project summary to canonical records

**Status:** Backlog
**GitHub Issue:** #124
**Component:** AICockpit / AirframeCore
**Priority:** High
**Epic:** EP-020
**Sprint Assigned:** SP-027
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
AICockpit should report project state from canonical records instead of reparsing Markdown as the primary source.

**Acceptance Criteria:**
1. AICockpit project summary reads canonical workflow records.
2. Summary output remains compatible with existing JSON and Markdown expectations where practical.
3. Tests cover canonical summary counts and backend capability reporting.

**Evidence:**
- TBD

## T-0125: Move AICockpit task packet generation to canonical records

**Status:** Backlog
**GitHub Issue:** #125
**Component:** AICockpit / AirframeCore
**Priority:** High
**Epic:** EP-020
**Sprint Assigned:** SP-027
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Agent task packets need reliable structured state and relationships without Markdown parsing drift.

**Acceptance Criteria:**
1. Task packets are assembled from canonical Task, Sprint, Epic, Issue, and evidence records.
2. Missing or inconsistent relationships produce diagnostics in packet output.
3. Tests prove packet generation from canonical state.

**Evidence:**
- TBD

## T-0126: Add AICockpit canonical state diagnostics command

**Status:** Backlog
**GitHub Issue:** #126
**Component:** AICockpit / AirframeCore
**Priority:** High
**Epic:** EP-020
**Sprint Assigned:** SP-027
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Agents need a read-only way to inspect state health before acting.

**Acceptance Criteria:**
1. AICockpit exposes a state diagnostics command with JSON output.
2. Diagnostics include severity, affected IDs, reason codes, and recommended repairs.
3. The command is read-only and does not apply repairs.

**Evidence:**
- TBD

## T-0127: Verify AICockpit authority boundaries against canonical state

**Status:** Backlog
**GitHub Issue:** #127
**Component:** AICockpitTests / AirframeCoreTests
**Priority:** High
**Epic:** EP-020
**Sprint Assigned:** SP-027
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Moving state authority into AirframeCore must not accidentally expand agent authority.

**Acceptance Criteria:**
1. Tests prove AICockpit cannot perform human verification, Sprint closure, Epic closure, destructive repair, or policy mutation.
2. Tests prove allowed agent actions still work through canonical state.
3. Denied operations include deterministic reason codes.

**Evidence:**
- TBD

## T-0128: Move AgileCockpit dashboard and planning views to canonical records

**Status:** Backlog
**GitHub Issue:** #128
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-020
**Sprint Assigned:** SP-028
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
AgileCockpit should render human-facing planning and dashboard views from the same canonical state used by AICockpit and AirframeCore.

**Acceptance Criteria:**
1. AgileCockpit dashboard status tiles read canonical records.
2. Sprint and Epic planning views read canonical records.
3. Existing local and GitHub-backed views remain usable during migration.

**Evidence:**
- TBD

## T-0129: Add AgileCockpit data health diagnostics surface

**Status:** Backlog
**GitHub Issue:** #129
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-020
**Sprint Assigned:** SP-028
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
AgileCockpit should elevate inconsistent state as a data health problem instead of displaying it as normal workflow state.

**Acceptance Criteria:**
1. AgileCockpit shows AirframeCore diagnostics with severity, affected IDs, and explanations.
2. Blocking diagnostics are visible before normal planning actions continue.
3. Tests cover display of the EP-018 class of inconsistency.

**Evidence:**
- TBD

## T-0130: Add AgileCockpit repair preview flow for canonical diagnostics

**Status:** Backlog
**GitHub Issue:** #130
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-020
**Sprint Assigned:** SP-028
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Known state problems should be correctable through previewed, human-approved repair workflows rather than manual file edits.

**Acceptance Criteria:**
1. AgileCockpit can show repair options generated by AirframeCore diagnostics.
2. Repair previews show affected records and fields before mutation.
3. Human-only repair actions remain blocked without human approval.

**Evidence:**
- TBD

## T-0131: Verify end-to-end canonical workflow state behavior

**Status:** Backlog
**GitHub Issue:** #131
**Component:** AirframeCoreTests / AICockpitTests / AgileCockpitTests
**Priority:** High
**Epic:** EP-020
**Sprint Assigned:** SP-028
**Date Requested:** 2026-06-17
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
EP-020 must prove the canonical state path works across Core, CLI, app, generated docs, and authority rules.

**Acceptance Criteria:**
1. End-to-end tests cover canonical load, validation, AICockpit summary, AICockpit task packet, AgileCockpit dashboard, and generated Markdown.
2. Tests cover invalid state diagnostics and repair preview behavior.
3. Tests prove human-only operations remain protected.

**Evidence:**
- TBD

---

*Last Updated: 2026-06-17 (T-0116 through T-0119 activated for SP-025)*
