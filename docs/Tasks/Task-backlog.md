# Task Backlog

Tasks listed here are proposed and not assigned to an active Sprint.

Currently: **12 backlog Tasks**

---

## T-0104: Add Epic Acceptance Criteria tab to the planning panel

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AgileCockpit
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-021
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
Reviewers need a dedicated place to inspect Epic acceptance criteria rather than inferring them from task lists.

**Acceptance Criteria:**
1. The Sprint & Epic panel exposes a tab for Epic acceptance criteria.
2. The tab is reachable from the existing planning navigation.
3. The tab is usable without leaving the planning section.

**Evidence:**
- TBD

## T-0105: Add verification actions for Epic acceptance criteria

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-021
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
The criteria tab must let the human reviewer mark each Epic acceptance criterion as verified with auditable state changes.

**Acceptance Criteria:**
1. Each acceptance criterion can be marked verified from the UI.
2. Verification updates the underlying planning state.
3. Verification writes an audit record or equivalent trace.

**Evidence:**
- TBD

## T-0106: Add accessibility, selection, and evidence behavior for the criteria tab

**Status:** Backlog
**GitHub Issue:** TBD
**Component:** AgileCockpit
**Priority:** Medium
**Epic:** EP-018
**Sprint Assigned:** SP-021
**Date Requested:** 2026-06-14
**Date Implemented:** TBD
**Date Verified:** TBD

**Rationale:**
The new tab needs to be readable and navigable in the same way the rest of AgileCockpit is.

**Acceptance Criteria:**
1. The criteria list has stable selection behavior.
2. The criteria list is accessible through keyboard and assistive technologies.
3. Verification context and evidence are visible before action.

**Evidence:**
- TBD

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

---

*Last Updated: 2026-06-15 (T-0101 through T-0103 activated for SP-020)*
