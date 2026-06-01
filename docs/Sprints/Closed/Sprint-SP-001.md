# SP-001: Workspace Skeleton

**Status:** Closed  
**Epic:** EP-001: Workspace and Toolchain Baseline  
**Goal:** Create the workspace and minimal buildable skeletons for all three CSCIs.  
**Start Date:** 2026-06-01  
**End Date:** 2026-06-01  
**Capacity:** TBD  

### Assigned Tasks

| Task | GitHub Issue | Title | Priority | Status |
| ---- | ------------ | ----- | -------- | ------ |
| T-0001 | #1 | Scaffold AirframeCore Swift package | High | Implemented - Verified |
| T-0002 | #2 | Scaffold AICockpit Swift package executable | High | Implemented - Verified |
| T-0003 | #3 | Scaffold AgileCockpit macOS SwiftUI app | High | Implemented - Verified |
| T-0004 | #4 | Assemble Airframe workspace and schemes | High | Implemented - Verified |
| T-0005 | #5 | Establish baseline build and test documentation | Medium | Implemented - Verified |
| T-0006 | #6 | Verify clean checkout workspace baseline | High | Implemented - Verified |

### Assigned Issues

| Issue | GitHub Issue | Title | Severity | Status |
| ----- | ------------ | ----- | -------- | ------ |

### Sprint Notes

SP-001 produced the initial workspace skeleton for AirframeCore, AICockpit, and AgileCockpit.

### Verification Targets

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
swift run --package-path AICockpit aicockpit --help
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' build
```

### Retrospective

**Completed:**
- T-0001 through T-0006 were implemented and human-verified.

**Returned to Backlog:**
- None.

**What went well:**
- All three CSCIs now build from the committed workspace baseline.
- Clean checkout verification passed before closure.

**What to improve:**
- Future app/project scaffolding should avoid inherited Xcode scheme warnings where possible.

**Carry-forward notes:**
- EP-002 should preserve AirframeCore as the single source of model and configuration truth.

---

*Closed: 2026-06-01*
