# SP-007: GitHub Backend MVP

**Status:** Closed
**Epic:** EP-007: GitHub Backend MVP
**Goal:** Implement GitHub-backed project workflow support while preserving AirframeCore's canonical backend semantics.
**Start Date:** 2026-06-04
**End Date:** 2026-06-04
**Capacity:** TBD

### Assigned Tasks

| Task | GitHub Issue | Title | Priority | Status |
| ---- | ------------ | ----- | -------- | ------ |
| T-0036 | #36 | Implement GitHub backend capability map and configuration | High | Implemented - Verified |
| T-0037 | #37 | Implement GitHub issue/task mapping | High | Implemented - Verified |
| T-0038 | #38 | Implement GitHub sprint/epic/evidence mapping | Medium | Implemented - Verified |
| T-0039 | #39 | Integrate GitHub backend with AICockpit | Medium | Implemented - Verified |
| T-0040 | #40 | Integrate GitHub backend status with AgileCockpit | Medium | Implemented - Verified |

### Assigned Issues

| Issue | GitHub Issue | Title | Severity | Status |
| ----- | ------------ | ----- | -------- | ------ |

### Sprint Notes

SP-007 kept provider-specific GitHub behavior behind AirframeCore backend APIs. AICockpit and AgileCockpit continue to consume canonical work item, evidence, task packet, dashboard, and verification concepts.

### Verification Targets

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

### Retrospective

**Completed:**
- SP-007 planning opened on 2026-06-04 after EP-006 closeout.
- GitHub backend capability/configuration, issue/task mapping, sprint/epic/evidence mapping, AICockpit integration, and AgileCockpit backend status were implemented on 2026-06-04.
- Verification commands passed on 2026-06-04.
- T-0036 through T-0040 human-verified on 2026-06-04.
- SP-007 closed on 2026-06-04.

**Returned to Backlog:**
- None.

**What went well:**
- The GitHub MVP is testable without live network access.
- Client integrations route through canonical AirframeCore backend APIs.

**What to improve:**
- Future work should make project/backend selection explicitly multi-project aware.
- Live GitHub authentication and remote API operations remain intentionally out of scope.

**Carry-forward notes:**
- EP-008 should harden the fixture-backed contracts, diagnostics, and verification documentation before release-candidate closeout.

---

*Closed: 2026-06-04*
