# EP-001: Workspace and Toolchain Baseline

**Status:** Closed  
**Owner:** HumanOwner  
**Start Date:** 2026-06-01  
**Target Close Date:** TBD  
**Close Date:** 2026-06-02  

**Goal:**
Create a buildable multi-project workspace with the three CSCI skeletons in their selected product forms.

**Rationale:**
All later work depends on a stable workspace, package, app, and test baseline that can be verified from a clean checkout.

**Scope:**
- Create `Airframe.xcworkspace`.
- Create `AirframeCore` Swift package library skeleton.
- Create `AICockpit` Swift package executable skeleton.
- Create `AgileCockpit` macOS SwiftUI app skeleton.
- Link AirframeCore into both clients.
- Establish baseline build and test commands.

**Out of Scope:**
- Production domain model.
- Backend integrations.
- Full app UI.
- Final CLI command contract.

**Acceptance Criteria:**
1. `swift test --package-path AirframeCore` passes.
2. `swift test --package-path AICockpit` passes.
3. `swift run --package-path AICockpit aicockpit --help` prints deterministic help.
4. `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' build` succeeds.
5. AgileCockpit and AICockpit both import AirframeCore.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-001 | Workspace Skeleton | Closed |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0001 | Scaffold AirframeCore Swift package | Implemented - Verified |
| T-0002 | Scaffold AICockpit Swift package executable | Implemented - Verified |
| T-0003 | Scaffold AgileCockpit macOS SwiftUI app | Implemented - Verified |
| T-0004 | Assemble Airframe workspace and schemes | Implemented - Verified |
| T-0005 | Establish baseline build and test documentation | Implemented - Verified |
| T-0006 | Verify clean checkout workspace baseline | Implemented - Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

SP-001 is closed and all related Tasks are verified. EP-001 was human-approved for closure on 2026-06-02.

---

*Closed: 2026-06-02*
