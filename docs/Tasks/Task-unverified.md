# Unverified Tasks

Implemented Tasks awaiting human verification are listed here.

Currently: **8 unverified Tasks**

---

T-0086 through T-0100 were reconciled to verified historical EP-017 state on 2026-06-23 and moved to [Verified/Task-verified-0086-0100.md](Verified/Task-verified-0086-0100.md).

T-0135 through T-0137 were human verified on 2026-06-24 and moved to [Verified/Task-verified-0135-0137.md](Verified/Task-verified-0135-0137.md).

T-0138 through T-0140 were human verified on 2026-06-24 and moved to [Verified/Task-verified-0138-0140.md](Verified/Task-verified-0138-0140.md).

T-0141 and T-0142 were human verified on 2026-06-24 and moved to [Verified/Task-verified-0141-0142.md](Verified/Task-verified-0141-0142.md).

## T-0107: Gate Sprint close on verified Tasks and Issues

**Status:** Implemented - Not Verified
**GitHub Issue:** #113
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-022
**Date Requested:** 2026-06-14
**Date Implemented:** 2026-06-23
**Date Verified:** TBD

**Rationale:**
Sprint close must stay blocked until every Sprint task and issue is verified.

**Acceptance Criteria:**
1. The Sprint close action is disabled or rejected until all assigned Tasks and Issues are verified.
2. The UI explains why the Sprint cannot close yet.
3. A successful close transitions the Sprint out of the active state.

**Evidence:**
- `AirframeSprintCloseEligibility` blocks Sprint close until assigned Tasks and Issues are verified.
- AgileCockpit disables Sprint close when eligibility is blocked and reports blocking work item IDs.
- `agileCockpitRejectsSprintCloseUntilAssignedTasksAndIssuesAreVerified`
- `agileCockpitClosesSprintToReviewWhenAssignedTasksAndIssuesAreVerified`
- `agileCockpitClosesReviewedSprintAndClearsActiveSprint`

## T-0108: Gate Epic close on verified acceptance criteria

**Status:** Implemented - Not Verified
**GitHub Issue:** #114
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-022
**Date Requested:** 2026-06-14
**Date Implemented:** 2026-06-23
**Date Verified:** TBD

**Rationale:**
Epic close must stay blocked until every acceptance criterion has been verified by the human reviewer.

**Acceptance Criteria:**
1. The Epic complete/close action is disabled or rejected until all acceptance criteria are verified.
2. The UI explains why the Epic cannot close yet.
3. A successful close transitions the Epic to its closed state.

**Evidence:**
- `AirframeEpicCloseEligibility` blocks Epic close until all acceptance criteria are verified.
- AgileCockpit disables Epic close when eligibility is blocked and reports unverified criteria.
- `agileCockpitGatesEpicCloseOnVerifiedAcceptanceCriteria`

## T-0109: Add close-action messaging and disabled-state behavior

**Status:** Implemented - Not Verified
**GitHub Issue:** #115
**Component:** AgileCockpit
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-022
**Date Requested:** 2026-06-14
**Date Implemented:** 2026-06-23
**Date Verified:** TBD

**Rationale:**
Users need clear feedback when Sprint or Epic close is unavailable, denied, or completed.

**Acceptance Criteria:**
1. Close actions present clear disabled or denied feedback.
2. Success and failure states are distinguishable in the UI.
3. The current close eligibility is visible without digging through source data.

**Evidence:**
- AgileCockpit shows Sprint and Epic close eligibility rows with blocking reasons.
- Close buttons are disabled until the corresponding eligibility passes.
- Sprint and Epic close actions set distinct blocked, success, and failure status messages.
- `agileCockpitRejectsSprintCloseUntilAssignedTasksAndIssuesAreVerified`
- `agileCockpitGatesEpicCloseOnVerifiedAcceptanceCriteria`

## T-0143: Define AICockpit requirements import command contract

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
**Component:** AICockpit
**Priority:** High
**Epic:** EP-021
**Sprint Assigned:** SP-033
**Date Requested:** 2026-06-24
**Date Implemented:** 2026-06-24
**Date Verified:** TBD

**Rationale:**
Requirements import needs an agent-facing workflow before canonical requirements can drive Epic gates.

**Acceptance Criteria:**
1. AICockpit command vocabulary for requirements import/export is documented and tested.
2. The command supports dry-run preview and explicit apply modes.
3. CSV and JSON inputs are routed through AirframeCore requirement interchange APIs.

**Evidence:**
- Added `aicockpit requirements import --format csv|json --file path --dry-run` preview routing through `AirframeRequirementInterchange`.
- Added `aicockpit requirements export --format csv|json` routing through `AirframeRequirementInterchange`.
- Updated `docs/CLI-Output-Contracts.md` with the requirements command contract.
- `swift test --package-path AICockpit`

## T-0144: Implement canonical requirements import apply path

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
**Component:** AirframeCore / AICockpit
**Priority:** High
**Epic:** EP-021
**Sprint Assigned:** SP-033
**Date Requested:** 2026-06-24
**Date Implemented:** 2026-06-24
**Date Verified:** TBD

**Rationale:**
Canonical requirement records must be mutated through a reviewed import path rather than hand-written JSON.

**Acceptance Criteria:**
1. Requirement import apply writes canonical requirement records.
2. Requirement import apply writes requirement revision records.
3. Import preview reports created, updated, unchanged, removed, and conflicted records before mutation.

**Evidence:**
- Implemented `aicockpit requirements import --format csv|json --file path --apply` canonical mutation.
- Apply writes imported requirement and requirement revision records, deletes records absent from the applied payload, and rejects conflicted imports.
- Apply returns the same created, updated, unchanged, removed, and conflicted counts as dry run.
- Updated `docs/CLI-Output-Contracts.md` with the apply behavior.
- `swift test --package-path AICockpit`

## T-0145: Add Markdown requirements seed import support

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
**Component:** AirframeCore / AICockpit
**Priority:** High
**Epic:** EP-021
**Sprint Assigned:** SP-033
**Date Requested:** 2026-06-24
**Date Implemented:** 2026-06-24
**Date Verified:** TBD

**Rationale:**
Airframe already has requirements documentation that should be represented in canonical state.

**Acceptance Criteria:**
1. Existing Markdown requirements documents can be parsed into candidate canonical requirement records.
2. Requirement IDs are deterministic and stable across repeated imports.
3. The import preserves source document paths in requirement metadata.

**Evidence:**
- Added requirement-section parsing to `AirframeMarkdownArtifactImporter`.
- `aicockpit state import-markdown` now seeds canonical requirements from `docs/requirements`.
- `swift test --package-path AirframeCore`
- `swift test --package-path AICockpit`

## T-0146: Regenerate requirements documentation from canonical state

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
**Component:** AICockpit / Documentation
**Priority:** High
**Epic:** EP-021
**Sprint Assigned:** SP-033
**Date Requested:** 2026-06-24
**Date Implemented:** 2026-06-24
**Date Verified:** TBD

**Rationale:**
Canonical requirements must drive human-readable reports and the release gate.

**Acceptance Criteria:**
1. Generated Requirements index lists imported canonical requirements.
2. Traceability matrix includes imported requirements and linked work.
3. Release gate report uses canonical requirements as the in-scope requirement list.

**Evidence:**
- `aicockpit state export-markdown` renders the requirements projections from canonical state.
- Requirement index, traceability matrix, bidirectional matrix, release gate, and compliance matrix projections all consume canonical requirements.
- `swift test --package-path AirframeCore`

## T-0147: Add requirements import regression coverage

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
**Component:** AirframeCoreTests / AICockpitTests / AgileCockpitTests
**Priority:** High
**Epic:** EP-021
**Sprint Assigned:** SP-033
**Date Requested:** 2026-06-24
**Date Implemented:** 2026-06-24
**Date Verified:** TBD

**Rationale:**
The import workflow affects Epic release gates and needs regression coverage.

**Acceptance Criteria:**
1. Tests cover requirements import preview and apply.
2. Tests cover generated requirement documentation after import.
3. AgileCockpit Requirements tab shows imported canonical requirements.

**Evidence:**
- Added core importer tests for requirement-document parsing.
- Added AICockpit end-to-end `state import-markdown` coverage for canonical requirements.
- `swift test --package-path AirframeCore`
- `swift test --package-path AICockpit`

*Last Updated: 2026-06-25 (T-0107 through T-0109 added for SP-022 verification)*
