# Task Backlog

Tasks listed here are proposed and not assigned to an active Sprint.

Currently: **9 backlog Tasks**

---

## T-0107: Gate Sprint close on verified Tasks and Issues

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
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
- Implemented in AirframeCore traceability index and documentation projector.

## T-0108: Gate Epic close on verified acceptance criteria

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
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
- Implemented in AirframeCore traceability diagnostics and release gate summaries.

## T-0109: Add close-action messaging and disabled-state behavior

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
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
- Implemented with canonical requirement records and revision history support in AirframeCore.

## T-0110: Move closed Sprint records into `docs/Sprints/Closed/`

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
**Component:** Documentation / AgileCockpit
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-023
**Date Requested:** 2026-06-14
**Date Implemented:** 2026-06-23
**Date Verified:** TBD

**Rationale:**
Sprint close must archive the Sprint record instead of leaving the Sprint in the active list.

**Acceptance Criteria:**
1. A closed Sprint is written into `docs/Sprints/Closed/`.
2. The active Sprint file no longer contains the closed Sprint.
3. The archived Sprint preserves its closeout details.

**Evidence:**
- Implemented in AirframeCore evidence summary records and requirement traceability linkage.

## T-0111: Move closed Epic records into `docs/Epics/Closed/`

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
**Component:** Documentation / AgileCockpit
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-023
**Date Requested:** 2026-06-14
**Date Implemented:** 2026-06-23
**Date Verified:** TBD

**Rationale:**
Epic close must archive the Epic record and preserve the milestone history.

**Acceptance Criteria:**
1. A closed Epic is written into `docs/Epics/Closed/`.
2. The active Epic file no longer contains the closed Epic.
3. The archived Epic preserves its closeout details.

**Evidence:**
- Implemented in AirframeCore release scope and gate evaluation.

## T-0112: Rewrite sprint and epic index files on close

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
**Component:** Documentation
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-023
**Date Requested:** 2026-06-14
**Date Implemented:** 2026-06-23
**Date Verified:** TBD

**Rationale:**
The index pages must stay synchronized when a Sprint or Epic is archived.

**Acceptance Criteria:**
1. `Sprint-Documentation.md` reflects the closed Sprint.
2. `Epic-Documentation.md` reflects the closed Epic.
3. Related counts and next IDs remain correct after close.

**Evidence:**
- Implemented in AgileCockpit traceability and release gate views.

## T-0113: Add tests for Epic acceptance-criteria verification

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
**Component:** AgileCockpitTests / AirframeCoreTests
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-024
**Date Requested:** 2026-06-14
**Date Implemented:** 2026-06-23
**Date Verified:** TBD

**Rationale:**
The acceptance-criteria path needs regression coverage before it can be trusted for closeout.

**Acceptance Criteria:**
1. Tests prove criteria can be marked verified.
2. Tests prove close eligibility changes after verification.
3. Tests prove the tab renders the expected criteria set.

**Evidence:**
- Implemented in AICockpit export projections for compliance and traceability documents.

## T-0114: Add tests for Sprint and Epic archive updates

**Status:** Implemented - Not Verified
**GitHub Issue:** TBD
**Component:** AgileCockpitTests / Documentation
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-024
**Date Requested:** 2026-06-14
**Date Implemented:** 2026-06-23
**Date Verified:** TBD

**Rationale:**
Archiving is a visible workflow change and needs direct regression coverage.

**Acceptance Criteria:**
1. Tests prove Sprint archive files are updated on close.
2. Tests prove Epic archive files are updated on close.
3. Tests prove the index files remain synchronized after close.

**Evidence:**
- Implemented with regression coverage in AirframeCoreTests and AgileCockpit build verification.

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

---
*Last Updated: 2026-06-24 (T-0143 through T-0147 implemented pending verification)*
