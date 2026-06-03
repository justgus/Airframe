# SP-004: Local Backend and Task Packet MVP

**Status:** Closed
**Epic:** EP-004: Local Backend and Task Packet MVP
**Goal:** Create a local backend and task packet workflow sufficient for offline development and repeatable verification.
**Start Date:** 2026-06-03
**End Date:** 2026-06-03
**Capacity:** TBD

### Assigned Tasks

| Task | GitHub Issue | Title | Priority | Status |
| ---- | ------------ | ----- | -------- | ------ |
| T-0018 | #18 | Define backend adapter protocol and capabilities | High | Implemented - Verified |
| T-0019 | #19 | Implement local filesystem backend | High | Implemented - Verified |
| T-0020 | #20 | Implement evidence attachment workflow | High | Implemented - Verified |
| T-0021 | #21 | Implement task packet generation | High | Implemented - Verified |
| T-0022 | #22 | Implement local dashboard summary APIs | High | Implemented - Verified |

### Assigned Issues

| Issue | GitHub Issue | Title | Severity | Status |
| ----- | ------------ | ----- | -------- | ------ |

### Sprint Notes

SP-004 established the local backend adapter, filesystem-backed records, evidence workflow, task packet generation, and local dashboard summary APIs.

### Verification Targets

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

### Retrospective

**Completed:**
- SP-004 activated on 2026-06-03.
- T-0018 through T-0022 implemented and moved to Implemented - Not Verified on 2026-06-03.
- AirframeCore, AICockpit, and AgileCockpit verification targets passed on 2026-06-03.
- T-0018 through T-0022 human-verified on 2026-06-03.
- GitHub issues #18 through #22 closed on 2026-06-03.

**Returned to Backlog:**
- None.

**What went well:**
- Local backend behavior is now represented as a deterministic AirframeCore reference implementation.
- Task packet and dashboard summary behavior are covered by focused AirframeCore tests.

**What to improve:**
- Future CLI work should expose these local backend APIs through stable command names.

**Carry-forward notes:**
- EP-005 should build AICockpit commands on top of the local backend and task packet APIs.

---

*Closed: 2026-06-03*
