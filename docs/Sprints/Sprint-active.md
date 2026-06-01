# Active Sprint

---

## SP-002: Core Domain and Configuration Foundation

**Status:** Review
**Epic:** EP-002: Core Domain and Configuration Foundation
**Goal:** Define the canonical model and configuration path used by AirframeCore, AICockpit, and AgileCockpit.
**Start Date:** 2026-06-01
**End Date:** TBD
**Capacity:** TBD

### Assigned Tasks

| Task | GitHub Issue | Title | Priority | Status |
| ---- | ------------ | ----- | -------- | ------ |
| T-0007 | #7 | Define canonical domain model | High | Implemented - Verified |
| T-0008 | #8 | Define configuration model and fixtures | High | Implemented - Verified |
| T-0009 | #9 | Implement AirframeCore configuration loading | High | Implemented - Verified |
| T-0010 | #10 | Implement AICockpit context display | Medium | Implemented - Verified |
| T-0011 | #11 | Implement AgileCockpit project context UI | Medium | Implemented - Verified |

### Assigned Issues

| Issue | GitHub Issue | Title | Severity | Status |
| ----- | ------------ | ----- | -------- | ------ |

### Sprint Notes

SP-002 starts EP-002. The Sprint should produce a shared sample workspace/project configuration that can be loaded through AirframeCore and displayed through both AICockpit and AgileCockpit.

### Verification Targets

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
swift run --package-path AICockpit aicockpit context
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

### Retrospective

**Completed:**
- T-0007 through T-0011 implemented and moved to Implemented - Not Verified on 2026-06-01.
- Core and CLI verification targets passed.
- AgileCockpit app build and full scheme test passed.
- T-0007 through T-0011 human-verified on 2026-06-01.

**Returned to Backlog:**
- TBD.

**What went well:**
- TBD.

**What to improve:**
- TBD.

**Carry-forward notes:**
- Human verification is complete for T-0007 through T-0011.
- Full automated verification targets passed on 2026-06-01.

---

*Last Updated: 2026-06-01 (SP-002 tasks verified)*
