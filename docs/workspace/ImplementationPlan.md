# Agile Airframe Workspace Implementation Plan

**System:** Agile Airframe  
**Workspace:** `Airframe.xcworkspace`  
**Target Toolchain:** Xcode 26 / Swift / SwiftUI  
**Target Platform:** macOS 26  
**Status:** Planning baseline  

## 1. Objective

Build Agile Airframe as three CSCIs in one coordinated workspace:

- **AirframeCore**: Swift package library used by both clients.
- **AICockpit**: Swift package executable for agents and automation.
- **AgileCockpit**: macOS SwiftUI app for human oversight.

The implementation strategy is milestone-driven. Each implementation milestone maps to an Epic in the Agile planning space and should produce something independently buildable, runnable, and verifiable.

## 2. Planning Model

```text
Epic = implementation milestone with an independently verifiable result
Task = broad work package under an Epic
Sprint = time-boxed selection of Tasks from the current Epic
Issue = defect/regression found during implementation or verification
```

Sprints will be defined along the way. Sprint planning should select a narrow set of Tasks from the current Epic and preserve the Epic's executable verification objective.

## 3. Aggregate Epic Roadmap

| Epic | Milestone | Primary Outcome | Executable Verification Target |
| ---- | --------- | --------------- | ------------------------------ |
| EP-001 | Workspace and Toolchain Baseline | Workspace, packages, and app skeleton exist. | Build/test all skeleton products and launch app/CLI help. |
| EP-002 | Core Domain and Configuration Foundation | Canonical models and local configuration exist. | Load sample workspace/project data through Core, CLI, and app. |
| EP-003 | Workflow, Authority, and Audit Foundation | Deny-by-default workflow and audit decisions exist. | Demonstrate allowed/denied operations with reason codes and audit records. |
| EP-004 | Local Backend and Task Packet MVP | Local backend supports issue/task lifecycle and packets. | Run local issue/task workflow end to end through Core and CLI. |
| EP-005 | AICockpit MVP Integration | Agent-facing CLI is independently useful. | Agent can propose work, retrieve task packet, attach evidence, and mark ready. |
| EP-006 | AgileCockpit Dashboard MVP Integration | Human-facing dashboard and verification UI work locally. | User can review and accept/reject local ready work in app. |
| EP-007 | GitHub Backend MVP | GitHub-backed projects work through canonical APIs. | CLI and app can read/write GitHub-backed work through Core. |
| EP-008 | Verification, Hardening, and Release Candidate | MVP is tested, documented, and stable enough for release candidate use. | Full local/GitHub smoke tests, app tests, CLI tests, and manual verification pass. |

## 4. Dependency Order

```text
EP-001
  -> EP-002
      -> EP-003
          -> EP-004
              -> EP-005
              -> EP-006
                  -> EP-007
                      -> EP-008
```

EP-005 and EP-006 can overlap after EP-004 provides enough stable AirframeCore APIs. EP-007 should wait until the local backend workflow is reliable enough to serve as the reference behavior.

## 5. Per-Epic Deliverables

### EP-001: Workspace and Toolchain Baseline

Deliverables:

- `Airframe.xcworkspace`.
- `AirframeCore` Swift package with smoke test.
- `AICockpit` Swift package executable with `--help`.
- `AgileCockpit` macOS SwiftUI app skeleton.
- Shared build/test instructions.

Verification:

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
swift run --package-path AICockpit aicockpit --help
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' build
```

Exit criteria:

- All three CSCIs exist in the workspace.
- AirframeCore is imported by both AICockpit and AgileCockpit.
- No CSCI contains meaningful duplicated domain logic.

### EP-002: Core Domain and Configuration Foundation

Deliverables:

- Canonical domain model.
- Workspace/project configuration model.
- Local fixture workspace.
- CLI context display.
- App project/context display.

Verification:

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Exit criteria:

- The same sample workspace is readable through AirframeCore, AICockpit, and AgileCockpit.
- Model and configuration tests cover valid, missing, and malformed configuration.

### EP-003: Workflow, Authority, and Audit Foundation

Deliverables:

- Actor/context model.
- Authority evaluator.
- Workflow transition evaluator.
- Audit record generation.
- CLI denied-operation output.
- App denied-operation display.

Verification:

```sh
swift test --package-path AirframeCore --filter Authority
swift test --package-path AirframeCore --filter Workflow
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Exit criteria:

- LLM actor can perform allowed proposal/evidence operations.
- LLM actor cannot perform human-only operations.
- Human actor can request human operations when policy allows.
- Denials include deterministic reason codes.
- Audit records are generated for allowed and denied writes.

### EP-004: Local Backend and Task Packet MVP

Deliverables:

- Local backend adapter.
- Issue/task create, query, update, and transition support.
- Evidence attachment support.
- Task packet generation.
- Dashboard summary over local backend data.

Verification:

```sh
swift test --package-path AirframeCore
swift run --package-path AICockpit aicockpit project summary
swift run --package-path AICockpit aicockpit task next
```

Exit criteria:

- A local task can move from backlog/active to ready for human verification.
- A compact task packet can be generated from local data.
- Dashboard summary can be produced from local data.

### EP-005: AICockpit MVP Integration

Deliverables:

- Final MVP CLI command names.
- Markdown and JSON output contracts.
- Commands for project summary, issue/task proposal, next task, task packet, evidence attachment, ready-for-verification, and audit lookup.
- Agent usage documentation.

Verification:

```sh
swift test --package-path AICockpit
swift run --package-path AICockpit aicockpit --help
swift run --package-path AICockpit aicockpit task next --output json
```

Exit criteria:

- Codex and Claude Code can use AICockpit directly against a local Airframe workspace.
- CLI does not expose human-only operations as agent-executable actions.
- CLI output is compact by default and structured on request.

### EP-006: AgileCockpit Dashboard MVP Integration

Deliverables:

- Dashboard summary UI.
- Project detail UI.
- Verification queue and review UI.
- Sprint and epic read views.
- Metrics and audit views.
- Human accept/reject/request-evidence actions through AirframeCore.

Verification:

```sh
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Manual verification:

1. Launch AgileCockpit.
2. Open sample local workspace.
3. Review dashboard sections.
4. Open a ready-for-verification item.
5. Accept or reject through AirframeCore.
6. Confirm dashboard, audit, and work item state update.

Exit criteria:

- A human can use AgileCockpit to understand current project state and perform at least one verification workflow.
- The UI reports denied operations, stale data, and backend errors clearly.

### EP-007: GitHub Backend MVP

Deliverables:

- GitHub backend adapter.
- Capability map and configuration.
- Mapping for issues, tasks, sprints, epics, evidence, and audit references where practical.
- CLI and app support through the same AirframeCore APIs.

Verification:

```sh
swift test --package-path AirframeCore --filter GitHub
swift test --package-path AICockpit --filter GitHub
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Exit criteria:

- Local and GitHub-backed projects behave consistently at the canonical API layer.
- Backend errors are not reported as successful domain operations.
- GitHub-specific behavior remains behind AirframeCore backend adapters.

### EP-008: Verification, Hardening, and Release Candidate

Deliverables:

- Full unit and integration test pass.
- CLI output contract tests.
- App accessibility checks.
- Configuration diagnostics.
- Updated user/developer documentation.
- Release candidate verification checklist.

Verification:

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Exit criteria:

- MVP local workflow passes end to end.
- MVP GitHub workflow passes against mock or test backend.
- Manual AgileCockpit verification passes.
- AICockpit is usable by agents from a clean checkout.

## 6. Sprint Planning Guidance

Sprints should be created only when the next slice of work is ready to execute. Each Sprint should:

- Belong primarily to one Epic.
- Include a small number of Tasks that produce a runnable or testable result.
- Avoid carrying broad design work without an executable check.
- Return incomplete work to backlog at Sprint close.
- Capture verification commands and manual checks in the Sprint record.

Recommended first Sprint:

- **SP-001:** Workspace Skeleton
- **Epic:** EP-001
- **Goal:** Create the workspace and minimal buildable skeletons for all three CSCIs.
- **Candidate Tasks:** T-0001 through T-0006.

## 7. Global Definition of Done

An Epic is complete when:

- Its CSCI-specific deliverables are complete or explicitly deferred.
- All planned verification commands pass.
- Any manual verification steps are documented and executed by the user where required.
- Agile Epics and Tasks are updated with implementation evidence.
- The workspace remains buildable from a clean checkout.

## 8. Planning References

- [AirframeCore Implementation Plan](../../AirframeCore/docs/ImplementationPlan.md)
- [AICockpit Implementation Plan](../../AICockpit/docs/ImplementationPlan.md)
- [AgileCockpit Implementation Plan](../../AgileCockpit/docs/ImplementationPlan.md)
- [CSCI Project Form Trade Study](../architecture/CSCI_Project_Form_Trade_Study.md)

