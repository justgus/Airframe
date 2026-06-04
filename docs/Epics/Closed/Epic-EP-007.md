# EP-007: GitHub Backend MVP

**Status:** Closed
**Owner:** HumanOwner
**Start Date:** 2026-06-04
**Target Close Date:** TBD
**Close Date:** 2026-06-04

**Goal:**
Add GitHub-backed project support behind AirframeCore backend adapters without changing client domain vocabulary.

**Rationale:**
GitHub is the expected first real backend and must be integrated without coupling AICockpit or AgileCockpit directly to provider-specific behavior.

**Scope:**
- GitHub backend adapter capability map.
- GitHub configuration model.
- Mapping for issues, tasks, sprints, epics, evidence, and audit references where practical.
- CLI backend status/error behavior.
- App backend status behavior.
- Mocked fixture verification.

**Out of Scope:**
- Support for Linear, Jira, Plane, or SQLite.
- Full GitHub Projects feature coverage beyond MVP.
- Live GitHub authentication and network API access.

**Acceptance Criteria:**
1. AirframeCore can read and write MVP work item data through GitHub adapter APIs.
2. AICockpit commands work against GitHub-backed projects without command vocabulary changes.
3. AgileCockpit displays GitHub-backed data through canonical models.
4. Backend failures are surfaced as failures, not successful domain operations.
5. Tests or mocks cover GitHub mapping behavior.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-007 | GitHub Backend MVP | Closed |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0036 | Implement GitHub backend capability map and configuration | Implemented - Verified |
| T-0037 | Implement GitHub issue/task mapping | Implemented - Verified |
| T-0038 | Implement GitHub sprint/epic/evidence mapping | Implemented - Verified |
| T-0039 | Integrate GitHub backend with AICockpit | Implemented - Verified |
| T-0040 | Integrate GitHub backend status with AgileCockpit | Implemented - Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Closeout Notes

- EP-007 activated on 2026-06-04.
- SP-007 planned and implemented on 2026-06-04.
- T-0036 through T-0040 were implemented and moved to Implemented - Not Verified on 2026-06-04.
- T-0036 through T-0040 were human-verified on 2026-06-04.
- SP-007 was closed on 2026-06-04.
- EP-007 was closed on 2026-06-04.
- Live GitHub authentication and API access remain future work; SP-007 established the canonical fixture-backed mapping and integration contract.

*Closed: 2026-06-04*
