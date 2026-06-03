# SP-005: AICockpit MVP Integration

**Status:** Closed
**Epic:** EP-005: AICockpit MVP Integration
**Goal:** Make AICockpit independently useful for agents working against a local Airframe workspace by exposing local backend and task packet workflows through stable MVP commands.
**Start Date:** 2026-06-03
**End Date:** 2026-06-03
**Capacity:** TBD

### Assigned Tasks

| Task | GitHub Issue | Title | Priority | Status |
| ---- | ------------ | ----- | -------- | ------ |
| T-0023 | #23 | Finalize AICockpit MVP command names and parser | High | Implemented - Verified |
| T-0024 | #24 | Implement issue and task proposal commands | High | Implemented - Verified |
| T-0025 | #25 | Implement next-task and task-packet commands | High | Implemented - Verified |
| T-0026 | #26 | Implement evidence and ready-for-verification commands | High | Implemented - Verified |
| T-0027 | #27 | Implement Markdown and JSON output contracts | High | Implemented - Verified |
| T-0028 | #28 | Document AICockpit agent usage | Medium | Implemented - Verified |

### Assigned Issues

| Issue | GitHub Issue | Title | Severity | Status |
| ----- | ------------ | ----- | -------- | ------ |

### Sprint Notes

SP-005 kept the executable target thin and implemented command behavior in `AICockpitKit` on top of the EP-004 local backend and task packet APIs.

### Verification Targets

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
swift run --package-path AICockpit aicockpit --help
swift run --package-path AICockpit aicockpit context
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

### Retrospective

**Completed:**
- SP-005 planned on 2026-06-03.
- SP-005 activated on 2026-06-03.
- T-0023 through T-0028 implemented and moved to Implemented - Not Verified on 2026-06-03.
- AirframeCore, AICockpit, AgileCockpit, and AICockpit CLI smoke verification passed on 2026-06-03.
- T-0023 through T-0028 human-verified on 2026-06-03.
- GitHub issues #23 through #28 closed on 2026-06-03.

**Returned to Backlog:**
- None.

**What went well:**
- AICockpit now exposes a local workflow agents can use without AgileCockpit.
- Markdown and JSON command outputs are covered by tests.

**What to improve:**
- Future backend work should preserve the same command contracts while replacing the local store.

**Carry-forward notes:**
- EP-006 can consume the same local backend concepts in the human-facing dashboard.

---

*Closed: 2026-06-03*
