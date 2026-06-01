# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

---

## EP-001: Workspace and Toolchain Baseline

**Status:** Complete  
**Owner:** HumanOwner  
**Start Date:** 2026-06-01  
**Target Close Date:** TBD  
**Close Date:** TBD  

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

SP-001 is closed and all related Tasks are verified. EP-001 is complete pending human epic closeout.

---

## EP-002: Core Domain and Configuration Foundation

**Status:** Active  
**Owner:** HumanOwner  
**Start Date:** 2026-06-01  
**Target Close Date:** TBD  
**Close Date:** TBD  

**Goal:**
Define the canonical Airframe domain model and load sample workspace/project configuration through AirframeCore, AICockpit, and AgileCockpit.

**Rationale:**
All clients need a common vocabulary and configuration source before workflow, backend, metrics, or UI behavior can be implemented safely.

**Scope:**
- Define canonical IDs and entity models.
- Define workspace/project configuration structures.
- Implement configuration loading and validation.
- Add local fixture workspace.
- Add CLI context display.
- Add AgileCockpit project context display.

**Out of Scope:**
- Full workflow enforcement.
- Backend persistence beyond fixtures.
- GitHub integration.

**Acceptance Criteria:**
1. AirframeCore loads valid sample configuration.
2. AirframeCore rejects malformed configuration with structured errors.
3. AICockpit displays current workspace/project context.
4. AgileCockpit displays current workspace/project context.
5. Core, CLI, and app tests cover the sample configuration path.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-002 | Core Domain and Configuration Foundation | Active |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0007 | Define canonical domain model | Active |
| T-0008 | Define configuration model and fixtures | Active |
| T-0009 | Implement AirframeCore configuration loading | Active |
| T-0010 | Implement AICockpit context display | Active |
| T-0011 | Implement AgileCockpit project context UI | Active |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

SP-002 is active. This Epic should preserve AirframeCore as UI-independent Swift code.

---

## EP-003: Workflow, Authority, and Audit Foundation

**Status:** Draft  
**Owner:** HumanOwner  
**Start Date:** TBD  
**Target Close Date:** TBD  
**Close Date:** TBD  

**Goal:**
Implement the deny-by-default workflow, authority, project-context, and audit foundation used by both clients.

**Rationale:**
Authority and workflow are the primary safety boundary of Agile Airframe and must be centralized in AirframeCore before meaningful write operations are exposed.

**Scope:**
- Actor and certified context model.
- Authority evaluator.
- Workflow transition evaluator.
- Audit event service.
- CLI denied-operation output.
- App action availability and audit display.

**Out of Scope:**
- GitHub authentication.
- Full backend persistence.
- Final UI polish.

**Acceptance Criteria:**
1. LLM actor can perform allowed proposal/evidence operations.
2. LLM actor cannot perform human-only operations.
3. Project mismatch is denied by default.
4. Denied operations return deterministic reason codes.
5. Audit records are created for allowed and denied write attempts.
6. CLI and app both display denial information without duplicating policy logic.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0012 | Implement actor and certified context model | Backlog |
| T-0013 | Implement authority evaluator | Backlog |
| T-0014 | Implement workflow transition evaluator | Backlog |
| T-0015 | Implement audit event service | Backlog |
| T-0016 | Implement AICockpit denied-operation output | Backlog |
| T-0017 | Implement AgileCockpit authority and audit display | Backlog |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

No client should implement independent authorization rules.

---

## EP-004: Local Backend and Task Packet MVP

**Status:** Draft  
**Owner:** HumanOwner  
**Start Date:** TBD  
**Target Close Date:** TBD  
**Close Date:** TBD  

**Goal:**
Create a local backend and task packet workflow sufficient for offline development and repeatable verification.

**Rationale:**
The local backend provides a deterministic reference implementation before GitHub-specific behavior is introduced.

**Scope:**
- Backend adapter protocol.
- Local filesystem backend.
- Issue/task create, query, update, and transition support.
- Evidence attachment.
- Task packet generation.
- Dashboard summary APIs.

**Out of Scope:**
- GitHub backend.
- Full AgileCockpit dashboard UI.
- Final CLI JSON schema.

**Acceptance Criteria:**
1. Local backend can create and query issues and tasks.
2. Local backend can attach evidence.
3. A task can be marked ready for human verification.
4. AirframeCore can generate a compact task packet.
5. AirframeCore can produce dashboard summary data from local backend records.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0018 | Define backend adapter protocol and capabilities | Backlog |
| T-0019 | Implement local filesystem backend | Backlog |
| T-0020 | Implement evidence attachment workflow | Backlog |
| T-0021 | Implement task packet generation | Backlog |
| T-0022 | Implement local dashboard summary APIs | Backlog |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

Local backend behavior should become the reference behavior for later GitHub mapping.

---

## EP-005: AICockpit MVP Integration

**Status:** Draft  
**Owner:** HumanOwner  
**Start Date:** TBD  
**Target Close Date:** TBD  
**Close Date:** TBD  

**Goal:**
Make AICockpit independently useful for agents working against a local Airframe workspace.

**Rationale:**
Agents need a compact and deterministic command interface before the human UI or GitHub integration can provide full value.

**Scope:**
- Final MVP command names.
- Command parser and routing.
- Project summary command.
- Issue/task proposal commands.
- Next-task and task-packet commands.
- Evidence attachment and ready-for-verification commands.
- Markdown and JSON output contracts.
- Agent usage documentation.

**Out of Scope:**
- Human-only operations.
- Direct backend manipulation outside AirframeCore.
- Full GitHub workflow.

**Acceptance Criteria:**
1. `aicockpit --help` documents MVP commands.
2. AICockpit can propose issues and tasks.
3. AICockpit can retrieve next task and task packet.
4. AICockpit can attach evidence and mark work ready for human verification.
5. JSON output is deterministic and tested for MVP commands.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0023 | Finalize AICockpit MVP command names and parser | Backlog |
| T-0024 | Implement issue and task proposal commands | Backlog |
| T-0025 | Implement next-task and task-packet commands | Backlog |
| T-0026 | Implement evidence and ready-for-verification commands | Backlog |
| T-0027 | Implement Markdown and JSON output contracts | Backlog |
| T-0028 | Document AICockpit agent usage | Backlog |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

The executable target should stay thin; command behavior belongs in `AICockpitKit`.

---

## EP-006: AgileCockpit Dashboard MVP Integration

**Status:** Draft  
**Owner:** HumanOwner  
**Start Date:** TBD  
**Target Close Date:** TBD  
**Close Date:** TBD  

**Goal:**
Provide a native macOS dashboard and verification workflow over local AirframeCore data.

**Rationale:**
The human-facing app must demonstrate the core product value: status awareness, review, human verification, metrics, and audit visibility.

**Scope:**
- Application shell.
- Dashboard summary sections.
- Project detail view.
- Verification queue and review flow.
- Human accept/reject/request-evidence actions.
- Sprint and epic read views.
- Metrics view.
- Audit view.
- Primary accessibility checks.

**Out of Scope:**
- GitHub-specific UI.
- Advanced customization.
- Release polish.

**Acceptance Criteria:**
1. AgileCockpit launches and displays local workspace dashboard data.
2. User can open a ready-for-verification item.
3. User can accept, reject, or request evidence through AirframeCore.
4. Dashboard and audit views update after the operation.
5. Primary flows have accessibility labels and keyboard-accessible controls.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0029 | Implement AgileCockpit application shell | Backlog |
| T-0030 | Implement dashboard summary UI | Backlog |
| T-0031 | Implement verification queue and review flow | Backlog |
| T-0032 | Implement human verification actions | Backlog |
| T-0033 | Implement sprint and epic read views | Backlog |
| T-0034 | Implement metrics and audit views | Backlog |
| T-0035 | Add primary accessibility and UI tests | Backlog |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

UI view models may adapt AirframeCore entities but must not own canonical state.

---

## EP-007: GitHub Backend MVP

**Status:** Draft  
**Owner:** HumanOwner  
**Start Date:** TBD  
**Target Close Date:** TBD  
**Close Date:** TBD  

**Goal:**
Add GitHub-backed project support behind AirframeCore backend adapters without changing client domain vocabulary.

**Rationale:**
GitHub is the expected first real backend and must be integrated without coupling AICockpit or AgileCockpit directly to provider-specific behavior.

**Scope:**
- GitHub backend adapter capability map.
- GitHub configuration and credential handling.
- Mapping for issues, tasks, sprints, epics, evidence, and audit references where practical.
- CLI backend status/error behavior.
- App backend status/error behavior.
- Mocked or test-repository verification.

**Out of Scope:**
- Support for Linear, Jira, Plane, or SQLite.
- Full GitHub Projects feature coverage beyond MVP.

**Acceptance Criteria:**
1. AirframeCore can read and write MVP work item data through GitHub adapter APIs.
2. AICockpit commands work against GitHub-backed projects without command vocabulary changes.
3. AgileCockpit displays GitHub-backed data through canonical models.
4. Backend failures are surfaced as failures, not successful domain operations.
5. Tests or mocks cover GitHub mapping behavior.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0036 | Implement GitHub backend capability map and configuration | Backlog |
| T-0037 | Implement GitHub issue/task mapping | Backlog |
| T-0038 | Implement GitHub sprint/epic/evidence mapping | Backlog |
| T-0039 | Integrate GitHub backend with AICockpit | Backlog |
| T-0040 | Integrate GitHub backend status with AgileCockpit | Backlog |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

Local backend behavior should remain the reference for canonical semantics.

---

## EP-008: Verification, Hardening, and Release Candidate

**Status:** Draft  
**Owner:** HumanOwner  
**Start Date:** TBD  
**Target Close Date:** TBD  
**Close Date:** TBD  

**Goal:**
Harden the MVP into a release-candidate-quality system with stable verification evidence and documentation.

**Rationale:**
The MVP must be repeatable, testable, and understandable enough for ongoing Agile Airframe use.

**Scope:**
- Full test pass across all CSCIs.
- CLI output contract tests.
- App accessibility and UI verification.
- Configuration diagnostics.
- Backend failure and stale data tests.
- Developer and user documentation.
- Release candidate checklist.

**Out of Scope:**
- New major features after feature freeze.
- Additional backend providers.

**Acceptance Criteria:**
1. AirframeCore tests pass.
2. AICockpit tests pass.
3. AgileCockpit build and tests pass.
4. Manual local workflow verification passes.
5. Mocked or test GitHub workflow verification passes.
6. Documentation explains setup, use, and verification.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0041 | Add full regression and integration test pass | Backlog |
| T-0042 | Harden CLI output and error contracts | Backlog |
| T-0043 | Harden AgileCockpit accessibility and UI flows | Backlog |
| T-0044 | Add configuration diagnostics and failure handling | Backlog |
| T-0045 | Write release candidate verification documentation | Backlog |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

This Epic should avoid scope expansion and focus on confidence, repeatability, and documentation.

---

*Last Updated: 2026-06-01 (SP-001 closed and SP-002 activated)*
