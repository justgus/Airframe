# Active Tasks

Tasks listed here are assigned to a Sprint and actively being implemented.

Currently: **3 active Tasks**

---

## T-0163: Add AgileCockpit Tests tab

**Status:** Active
**GitHub Issue:** #171
**Component:** AgileCockpit
**Priority:** High
**Epic:** EP-024
**Sprint Assigned:** SP-037

**Acceptance Criteria:**
1. AgileCockpit includes a Tests tab.
2. The Tests tab shows canonical test definitions, linked ACs, and requirement trace coverage.
3. The Tests tab identifies missing or invalid test links.
4. The Tests tab does not perform human-only verification without explicit human action.

## T-0164: Define EP-023 acceptance criteria for requirements without AC coverage

**Status:** Active
**GitHub Issue:** #173
**Component:** EP-023 Acceptance Criteria / Requirement Coverage
**Priority:** High
**Epic:** EP-024
**Sprint Assigned:** SP-037

**Rationale:**
The current RTM shows 93 requirements without Epic acceptance-criterion coverage. These need final-review ACs under EP-023 before tests can verify them.

**Acceptance Criteria:**
1. Requirements without Epic AC coverage are identified from the current RTM.
2. Missing acceptance criteria are defined under EP-023.
3. Each new EP-023 acceptance criterion links to at least one requirement.
4. Each new EP-023 acceptance criterion has at least one corresponding test definition.

## T-0165: Verify test management workflow and documentation

**Status:** Active
**GitHub Issue:** #172
**Component:** Regression Coverage / Documentation
**Priority:** High
**Epic:** EP-024
**Sprint Assigned:** SP-037

**Acceptance Criteria:**
1. AirframeCore tests cover canonical test records and trace validation.
2. AICockpit tests cover test management commands.
3. AgileCockpit tests cover the Tests tab.
4. Documentation explains test definition, management, and requirement trace semantics.

*Last Updated: 2026-07-06*
