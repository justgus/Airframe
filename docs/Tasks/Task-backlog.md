# Task Backlog

Tasks listed here are proposed and not assigned to an active Sprint.

Currently: **45 backlog Tasks**

---

## T-0001: Scaffold AirframeCore Swift package

**Status:** Backlog  
**GitHub Issue:** #1  
**Component:** AirframeCore  
**Priority:** High  
**Epic:** EP-001  
**Sprint Assigned:** Not Assigned  
**Date Requested:** 2026-06-01  
**Date Implemented:** TBD  
**Date Verified:** TBD  

**Rationale:**
AirframeCore must exist as the shared Swift package library before either client can link against it.

**Desired Behavior:**
The package builds, exposes a minimal importable module, and has a passing smoke test.

**Requirements:**
1. Create `AirframeCore/Package.swift`.
2. Create `Sources/AirframeCore`.
3. Create `Tests/AirframeCoreTests`.
4. Add a minimal public API and test.

**Acceptance Criteria:**
1. `swift test --package-path AirframeCore` passes.
2. `swift package --package-path AirframeCore describe` succeeds.

**Design Approach:**
Start with one `AirframeCore` target. Split into additional targets only after real dependency pressure appears.

**Components Affected:**
- AirframeCore: New Swift package skeleton.

**Implementation Details:**
TBD.

**Evidence:**
- TBD.

**Test Steps:**
1. Run `swift test --package-path AirframeCore`.

**Notes:**
Supports EP-001.

---

## T-0002: Scaffold AICockpit Swift package executable

**Status:** Backlog  
**GitHub Issue:** #2  
**Component:** AICockpit  
**Priority:** High  
**Epic:** EP-001  
**Sprint Assigned:** Not Assigned  
**Date Requested:** 2026-06-01  
**Date Implemented:** TBD  
**Date Verified:** TBD  

**Rationale:**
AICockpit must be directly runnable by agents and automation.

**Desired Behavior:**
The package builds an `aicockpit` executable and contains a testable `AICockpitKit` target.

**Requirements:**
1. Create `AICockpit/Package.swift`.
2. Create executable target `AICockpit`.
3. Create library target `AICockpitKit`.
4. Add a minimal `--help` command.

**Acceptance Criteria:**
1. `swift test --package-path AICockpit` passes.
2. `swift run --package-path AICockpit aicockpit --help` succeeds.

**Design Approach:**
Keep `main.swift` thin and place command behavior in `AICockpitKit`.

**Components Affected:**
- AICockpit: New Swift executable package.

**Implementation Details:**
TBD.

**Evidence:**
- TBD.

**Test Steps:**
1. Run AICockpit package tests.
2. Run `aicockpit --help`.

**Notes:**
Supports EP-001.

---

## T-0003: Scaffold AgileCockpit macOS SwiftUI app

**Status:** Backlog  
**GitHub Issue:** #3  
**Component:** AgileCockpit  
**Priority:** High  
**Epic:** EP-001  
**Sprint Assigned:** Not Assigned  
**Date Requested:** 2026-06-01  
**Date Implemented:** TBD  
**Date Verified:** TBD  

**Rationale:**
AgileCockpit is the human-facing CSCI and must exist as a native macOS SwiftUI app project.

**Desired Behavior:**
The app builds and launches with a minimal shell.

**Requirements:**
1. Create `AgileCockpit.xcodeproj`.
2. Target macOS 26.
3. Create SwiftUI app entry point.
4. Add initial test targets.

**Acceptance Criteria:**
1. `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' build` succeeds after workspace assembly.
2. App launches and displays a minimal shell.

**Design Approach:**
Use an Xcode macOS app project because app lifecycle, signing, assets, previews, and UI tests belong in the app project.

**Components Affected:**
- AgileCockpit: New macOS SwiftUI app project.

**Implementation Details:**
TBD.

**Evidence:**
- TBD.

**Test Steps:**
1. Build the AgileCockpit scheme.
2. Launch the app.

**Notes:**
Supports EP-001.

---

## T-0004: Assemble Airframe workspace and schemes

**Status:** Backlog  
**GitHub Issue:** #4  
**Component:** Workspace  
**Priority:** High  
**Epic:** EP-001  
**Sprint Assigned:** Not Assigned  
**Date Requested:** 2026-06-01  
**Date Implemented:** TBD  
**Date Verified:** TBD  

**Rationale:**
The workspace is the top-level Xcode entry point for the three CSCIs.

**Desired Behavior:**
`Airframe.xcworkspace` contains AirframeCore, AICockpit, and AgileCockpit with usable shared schemes.

**Requirements:**
1. Create `Airframe.xcworkspace`.
2. Add both Swift packages.
3. Add AgileCockpit project.
4. Ensure schemes are visible for expected build/test commands.

**Acceptance Criteria:**
1. Workspace opens in Xcode.
2. All three CSCIs are visible from the workspace.
3. Expected build/test commands can be run from the command line.

**Design Approach:**
Use the workspace as the aggregate view while leaving package manifests and the app project as CSCI-specific sources of truth.

**Components Affected:**
- Workspace
- AirframeCore
- AICockpit
- AgileCockpit

**Implementation Details:**
TBD.

**Evidence:**
- TBD.

**Test Steps:**
1. Open or build through `Airframe.xcworkspace`.

**Notes:**
Supports EP-001.

---

## T-0005: Establish baseline build and test documentation

**Status:** Backlog  
**GitHub Issue:** #5  
**Component:** Workspace  
**Priority:** Medium  
**Epic:** EP-001  
**Sprint Assigned:** Not Assigned  
**Date Requested:** 2026-06-01  
**Date Implemented:** TBD  
**Date Verified:** TBD  

**Rationale:**
Every Epic and Sprint needs executable verification steps.

**Desired Behavior:**
The repo documents build and test commands for each CSCI and the aggregate workspace.

**Requirements:**
1. Document AirframeCore build/test commands.
2. Document AICockpit build/test/run commands.
3. Document AgileCockpit build/test commands.
4. Document aggregate verification sequence.

**Acceptance Criteria:**
1. A developer can verify all skeleton products from the docs.
2. Commands are aligned with actual package/project names.

**Design Approach:**
Keep commands in the workspace implementation plan and add CSCI-local notes where useful.

**Components Affected:**
- docs
- Workspace

**Implementation Details:**
TBD.

**Evidence:**
- TBD.

**Test Steps:**
1. Run the documented commands from a clean checkout.

**Notes:**
Supports EP-001.

---

## T-0006: Verify clean checkout workspace baseline

**Status:** Backlog  
**GitHub Issue:** #6  
**Component:** Workspace  
**Priority:** High  
**Epic:** EP-001  
**Sprint Assigned:** Not Assigned  
**Date Requested:** 2026-06-01  
**Date Implemented:** TBD  
**Date Verified:** TBD  

**Rationale:**
The baseline is not useful unless it can be reproduced outside the current working tree.

**Desired Behavior:**
A clean clone can build and test all skeleton products without hidden local state.

**Requirements:**
1. Clone or clean-checkout the repo.
2. Run AirframeCore tests.
3. Run AICockpit tests and help.
4. Build AgileCockpit.

**Acceptance Criteria:**
1. All baseline commands pass from a clean checkout.
2. Any required local setup is documented.

**Design Approach:**
Use command-line verification as the proof before closing EP-001.

**Components Affected:**
- Workspace
- docs

**Implementation Details:**
TBD.

**Evidence:**
- TBD.

**Test Steps:**
1. Run the EP-001 verification command set.

**Notes:**
Supports EP-001.

---

## EP-002 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0007 | #7 | Define canonical domain model | High | Core models for projects, work items, issues, tasks, sprints, epics, evidence, verification gates, audit, metrics, actors, and backend references compile and are unit tested. |
| T-0008 | #8 | Define configuration model and fixtures | High | Sample workspace/project fixtures exist and represent local backend configuration. |
| T-0009 | #9 | Implement AirframeCore configuration loading | High | Valid config loads and malformed config fails with structured errors. |
| T-0010 | #10 | Implement AICockpit context display | Medium | CLI displays current workspace/project context from AirframeCore. |
| T-0011 | #11 | Implement AgileCockpit project context UI | Medium | App displays current workspace/project context from AirframeCore. |

## EP-003 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0012 | #12 | Implement actor and certified context model | High | Actor identity/type/project context data is represented without trusting caller assertions. |
| T-0013 | #13 | Implement authority evaluator | High | Allowed, denied, and requires-confirmation results are returned with reason codes. |
| T-0014 | #14 | Implement workflow transition evaluator | High | Task, issue, sprint, epic, and verification state transitions are validated. |
| T-0015 | #15 | Implement audit event service | High | Allowed and denied write attempts generate audit records. |
| T-0016 | #16 | Implement AICockpit denied-operation output | Medium | CLI prints compact human-readable and JSON denial output. |
| T-0017 | #17 | Implement AgileCockpit authority and audit display | Medium | UI shows disabled/denied actions and audit records from AirframeCore. |

## EP-004 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0018 | #18 | Define backend adapter protocol and capabilities | High | Backend protocol and capability model are unit tested. |
| T-0019 | #19 | Implement local filesystem backend | High | Local issue/task records can be created, queried, and updated. |
| T-0020 | #20 | Implement evidence attachment workflow | High | Evidence can be attached to authorized work items. |
| T-0021 | #21 | Implement task packet generation | High | Task packets include objective, scope, acceptance criteria, constraints, evidence requirements, protected paths, and report format. |
| T-0022 | #22 | Implement local dashboard summary APIs | High | Dashboard summary data can be produced from local backend fixtures. |

## EP-005 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0023 | #23 | Finalize AICockpit MVP command names and parser | High | MVP command names are documented and parser tests pass. |
| T-0024 | #24 | Implement issue and task proposal commands | High | CLI can propose issues and tasks through AirframeCore. |
| T-0025 | #25 | Implement next-task and task-packet commands | High | CLI can retrieve next work and generate task packets. |
| T-0026 | #26 | Implement evidence and ready-for-verification commands | High | CLI can attach evidence and mark work ready through AirframeCore. |
| T-0027 | #27 | Implement Markdown and JSON output contracts | High | Output contract tests pass for MVP commands. |
| T-0028 | #28 | Document AICockpit agent usage | Medium | Agent usage docs cover local setup and command examples. |

## EP-006 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0029 | #29 | Implement AgileCockpit application shell | High | App shell supports navigation, project context, and global status. |
| T-0030 | #30 | Implement dashboard summary UI | High | Dashboard shows recently done, active, ready, blocked, next, upcoming, sprint health, and epic progress sections. |
| T-0031 | #31 | Implement verification queue and review flow | High | User can open ready work and inspect evidence/acceptance criteria. |
| T-0032 | #32 | Implement human verification actions | High | User can accept, reject, or request evidence through AirframeCore. |
| T-0033 | #33 | Implement sprint and epic read views | Medium | App shows sprint and epic detail data from AirframeCore. |
| T-0034 | #34 | Implement metrics and audit views | Medium | App displays metric summaries and audit event records. |
| T-0035 | #35 | Add primary accessibility and UI tests | High | Primary workflow controls have accessibility labels and tests. |

## EP-007 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0036 | #36 | Implement GitHub backend capability map and configuration | High | GitHub capability/configuration model is represented and tested. |
| T-0037 | #37 | Implement GitHub issue/task mapping | High | Canonical issues/tasks map to GitHub records. |
| T-0038 | #38 | Implement GitHub sprint/epic/evidence mapping | Medium | Sprint, epic, evidence, and audit references map where supported. |
| T-0039 | #39 | Integrate GitHub backend with AICockpit | Medium | CLI commands work against GitHub-backed projects through AirframeCore. |
| T-0040 | #40 | Integrate GitHub backend status with AgileCockpit | Medium | App displays GitHub-backed data and backend status through canonical APIs. |

## EP-008 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0041 | #41 | Add full regression and integration test pass | High | AirframeCore, AICockpit, and AgileCockpit test suites pass together. |
| T-0042 | #42 | Harden CLI output and error contracts | High | CLI output and error snapshots/contracts are stable. |
| T-0043 | #43 | Harden AgileCockpit accessibility and UI flows | High | Primary app workflows pass accessibility and UI verification. |
| T-0044 | #44 | Add configuration diagnostics and failure handling | Medium | Configuration, stale data, and backend failure states are clear and tested. |
| T-0045 | #45 | Write release candidate verification documentation | Medium | Release candidate checklist and manual verification docs exist. |

---

*Last Updated: 2026-06-01 (Implementation planning baseline)*
