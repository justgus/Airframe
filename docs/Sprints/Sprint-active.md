# Active Sprint

---

## SP-001: Workspace Skeleton

**Status:** Active  
**Epic:** EP-001: Workspace and Toolchain Baseline  
**Goal:** Create the workspace and minimal buildable skeletons for all three CSCIs.  
**Start Date:** 2026-06-01  
**End Date:** TBD  
**Capacity:** TBD  

### Assigned Tasks

| Task | GitHub Issue | Title | Priority | Status |
| ---- | ------------ | ----- | -------- | ------ |
| T-0001 | #1 | Scaffold AirframeCore Swift package | High | Implemented - Not Verified |
| T-0002 | #2 | Scaffold AICockpit Swift package executable | High | Implemented - Not Verified |
| T-0003 | #3 | Scaffold AgileCockpit macOS SwiftUI app | High | Implemented - Not Verified |
| T-0004 | #4 | Assemble Airframe workspace and schemes | High | Implemented - Not Verified |
| T-0005 | #5 | Establish baseline build and test documentation | Medium | Implemented - Not Verified |
| T-0006 | #6 | Verify clean checkout workspace baseline | High | Implemented - Not Verified |

### Assigned Issues

| Issue | GitHub Issue | Title | Severity | Status |
| ----- | ------------ | ----- | -------- | ------ |

### Sprint Notes

SP-001 starts EP-001. The Sprint should produce an executable baseline: AirframeCore tests pass, AICockpit prints help, and AgileCockpit builds from the workspace.

### Verification Targets

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
swift run --package-path AICockpit aicockpit --help
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' build
```

### Retrospective

**Completed:**
- T-0001 through T-0006 are implemented and awaiting human verification.

**Returned to Backlog:**
- TBD.

**What went well:**
- TBD.

**What to improve:**
- TBD.

**Carry-forward notes:**
- TBD.

---

*Last Updated: 2026-06-01 (T-0001 through T-0006 implemented, awaiting human verification)*
