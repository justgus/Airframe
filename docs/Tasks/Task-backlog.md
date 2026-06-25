# Task Backlog

Tasks listed here are proposed and not assigned to an active Sprint.

Currently: **6 backlog Tasks**

---

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

**Status:** Implemented - Not Verified
**GitHub Issue:** #152
**Component:** AgileCockpitTests / AICockpitTests
**Priority:** High
**Epic:** EP-018
**Sprint Assigned:** SP-024
**Date Requested:** 2026-06-14
**Date Implemented:** 2026-06-25
**Date Verified:** TBD

**Rationale:**
Closeout must continue to work in the local workspace without relying on a server or GitHub.

**Acceptance Criteria:**
1. Tests prove closeout works locally without network access.
2. Tests prove GitHub-specific paths remain optional.
3. Tests prove human-only closeout boundaries are preserved.

**Evidence:**
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests/AgileCockpitTests/agileCockpitClosesReviewedSprintUsingLocalCanonicalStateOnly -only-testing:AgileCockpitTests/AgileCockpitTests/agileCockpitRecordsEpicCloseWithHumanReviewerAuthority`

---
*Last Updated: 2026-06-25 (T-0107 through T-0109 moved to Implemented - Not Verified)*
