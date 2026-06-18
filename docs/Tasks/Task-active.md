# Active Tasks

Tasks listed here are assigned to a Sprint and actively being implemented.

Currently: **3 active Tasks**

---

## T-0121: Generate deterministic Markdown projections from canonical records

**Status:** Active
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

**Status:** Active
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

**Status:** Active
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

---

*Last Updated: 2026-06-18 (T-0120 implemented pending human verification)*
