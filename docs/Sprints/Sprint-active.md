# Active Sprint

---

## SP-002: Core Domain and Configuration Foundation

**Status:** Active  
**Epic:** EP-002: Core Domain and Configuration Foundation  
**Goal:** Define the canonical model and configuration path used by AirframeCore, AICockpit, and AgileCockpit.  
**Start Date:** 2026-06-01  
**End Date:** TBD  
**Capacity:** TBD  

### Assigned Tasks

| Task | GitHub Issue | Title | Priority | Status |
| ---- | ------------ | ----- | -------- | ------ |
| T-0007 | #7 | Define canonical domain model | High | Active |
| T-0008 | #8 | Define configuration model and fixtures | High | Active |
| T-0009 | #9 | Implement AirframeCore configuration loading | High | Active |
| T-0010 | #10 | Implement AICockpit context display | Medium | Active |
| T-0011 | #11 | Implement AgileCockpit project context UI | Medium | Active |

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
- TBD.

**Returned to Backlog:**
- TBD.

**What went well:**
- TBD.

**What to improve:**
- TBD.

**Carry-forward notes:**
- TBD.

---

*Last Updated: 2026-06-01 (SP-002 activated)*
