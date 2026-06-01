# Unverified Tasks

Tasks listed here are implemented but not yet human-verified.

Currently: **6 unverified Tasks**

---

## T-0001: Scaffold AirframeCore Swift package

**Status:** Implemented - Not Verified  
**GitHub Issue:** #1  
**Component:** AirframeCore  
**Priority:** High  
**Epic:** EP-001  
**Sprint Assigned:** SP-001  
**Date Requested:** 2026-06-01  
**Date Implemented:** 2026-06-01  
**Date Verified:** TBD  

**Implementation Details:**
Created `AirframeCore` as a Swift package library targeting macOS 26 with a minimal public `AirframeCoreInfo` API and Swift Testing smoke test.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-01.

**Test Steps:**
1. Run `swift test --package-path AirframeCore`.
2. Run `swift package --package-path AirframeCore describe`.

---

## T-0002: Scaffold AICockpit Swift package executable

**Status:** Implemented - Not Verified  
**GitHub Issue:** #2  
**Component:** AICockpit  
**Priority:** High  
**Epic:** EP-001  
**Sprint Assigned:** SP-001  
**Date Requested:** 2026-06-01  
**Date Implemented:** 2026-06-01  
**Date Verified:** TBD  

**Implementation Details:**
Created `AICockpit` as a Swift package with executable product `aicockpit`, library target `AICockpitKit`, and path dependency on `AirframeCore`.

**Evidence:**
- `swift test --package-path AICockpit` passed on 2026-06-01.
- `swift run --package-path AICockpit aicockpit --help` passed on 2026-06-01.

**Test Steps:**
1. Run `swift test --package-path AICockpit`.
2. Run `swift run --package-path AICockpit aicockpit --help`.

---

## T-0003: Scaffold AgileCockpit macOS SwiftUI app

**Status:** Implemented - Not Verified  
**GitHub Issue:** #3  
**Component:** AgileCockpit  
**Priority:** High  
**Epic:** EP-001  
**Sprint Assigned:** SP-001  
**Date Requested:** 2026-06-01  
**Date Implemented:** 2026-06-01  
**Date Verified:** TBD  

**Implementation Details:**
Created `AgileCockpit.xcodeproj` as a macOS SwiftUI app targeting macOS 26 with app, unit test, and UI test targets. The app imports `AirframeCore` and displays the baseline workspace shell.

**Evidence:**
- `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' build` passed on 2026-06-01.

**Test Steps:**
1. Run `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' build`.
2. Launch AgileCockpit and confirm the minimal shell appears.

---

## T-0004: Assemble Airframe workspace and schemes

**Status:** Implemented - Not Verified  
**GitHub Issue:** #4  
**Component:** Workspace  
**Priority:** High  
**Epic:** EP-001  
**Sprint Assigned:** SP-001  
**Date Requested:** 2026-06-01  
**Date Implemented:** 2026-06-01  
**Date Verified:** TBD  

**Implementation Details:**
Created `Airframe.xcworkspace` containing `AirframeCore`, `AICockpit`, and `AgileCockpit`. Confirmed the workspace can build the AgileCockpit scheme with the local `AirframeCore` package dependency resolved.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-01.
- `swift test --package-path AICockpit` passed on 2026-06-01.
- `swift run --package-path AICockpit aicockpit --help` passed on 2026-06-01.
- `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' build` passed on 2026-06-01.

**Test Steps:**
1. Run the SP-001 verification target commands from [Sprint-active.md](../Sprints/Sprint-active.md).

---

## T-0005: Establish baseline build and test documentation

**Status:** Implemented - Not Verified  
**GitHub Issue:** #5  
**Component:** Workspace  
**Priority:** Medium  
**Epic:** EP-001  
**Sprint Assigned:** SP-001  
**Date Requested:** 2026-06-01  
**Date Implemented:** 2026-06-01  
**Date Verified:** TBD  

**Implementation Details:**
Baseline verification commands are documented in the workspace implementation plan, CSCI implementation plans, and SP-001 sprint verification targets.

**Evidence:**
- `docs/workspace/ImplementationPlan.md` documents the aggregate EP-001 command sequence.
- `AirframeCore/docs/ImplementationPlan.md`, `AICockpit/docs/ImplementationPlan.md`, and `AgileCockpit/docs/ImplementationPlan.md` document CSCI-local verification commands.
- `docs/Sprints/Sprint-active.md` documents the SP-001 verification target command sequence.

**Test Steps:**
1. Run the documented SP-001 verification target commands from [Sprint-active.md](../Sprints/Sprint-active.md).

---

## T-0006: Verify clean checkout workspace baseline

**Status:** Implemented - Not Verified  
**GitHub Issue:** #6  
**Component:** Workspace  
**Priority:** High  
**Epic:** EP-001  
**Sprint Assigned:** SP-001  
**Date Requested:** 2026-06-01  
**Date Implemented:** 2026-06-01  
**Date Verified:** TBD  

**Implementation Details:**
Cloned the committed SP-001 baseline to `/private/tmp/airframe-clean.aFJSyP/Airframe` and ran the SP-001 verification command sequence from that clean checkout.

**Evidence:**
- `swift test --package-path AirframeCore` passed from the clean checkout on 2026-06-01.
- `swift test --package-path AICockpit` passed from the clean checkout on 2026-06-01.
- `swift run --package-path AICockpit aicockpit --help` passed from the clean checkout on 2026-06-01.
- `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' build` passed from the clean checkout on 2026-06-01.

**Test Steps:**
1. Clone the repository to a clean directory.
2. Run the SP-001 verification target commands from [Sprint-active.md](../Sprints/Sprint-active.md).

---

*Last Updated: 2026-06-01 (T-0001 through T-0006 implemented, awaiting human verification)*
