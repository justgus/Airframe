# AirframeCore Implementation Plan

**CSCI:** AirframeCore  
**Product Form:** Swift package library  
**Target Toolchain:** Xcode 26 / Swift  
**Target Platform:** macOS 26 clients, platform-neutral core where practical  
**Status:** Planning baseline  

## 1. Objective

AirframeCore is the shared policy, workflow, domain, metrics, audit, configuration, and backend adapter layer for Agile Airframe. It must provide stable APIs consumed by both AICockpit and AgileCockpit while preventing either client from bypassing workflow, authority, or project-scope rules.

## 2. Package Shape

Initial package layout:

```text
AirframeCore/
├── Package.swift
├── Sources/
│   └── AirframeCore/
│       ├── Domain/
│       ├── Configuration/
│       ├── Identity/
│       ├── Authority/
│       ├── Workflow/
│       ├── Operations/
│       ├── BackendAdapters/
│       ├── Metrics/
│       ├── Audit/
│       └── TaskPackets/
└── Tests/
    └── AirframeCoreTests/
```

The first implementation should start as one library target named `AirframeCore`. Split into additional targets only when module boundaries are proven by real dependency pressure.

## 3. Epic Roadmap

| Epic | Milestone | Executable Result |
| ---- | --------- | ----------------- |
| EP-001 | Workspace and Toolchain Baseline | AirframeCore package builds and tests in the workspace. |
| EP-002 | Core Domain and Configuration Foundation | Core models load from local configuration and can be queried in tests. |
| EP-003 | Workflow, Authority, and Audit Foundation | Allowed/denied operations are evaluated with audit records. |
| EP-004 | Local Backend and Task Packet MVP | Local Markdown/JSON backend supports issue/task lifecycle and task packet generation. |
| EP-005 | AICockpit MVP Integration | AICockpit can execute useful commands through AirframeCore. |
| EP-006 | AgileCockpit Dashboard MVP Integration | AgileCockpit can display AirframeCore summaries and verification queues. |
| EP-007 | GitHub Backend MVP | AirframeCore can map canonical issues/tasks/sprints/epics to GitHub-backed records. |
| EP-008 | Verification, Hardening, and Release Candidate | Core behavior is covered by tests and ready for end-to-end verification. |

## 4. Milestone Tasks

### EP-001: Workspace and Toolchain Baseline

- Create `Package.swift` for `AirframeCore`.
- Add a minimal public API surface and smoke test.
- Add package to `Airframe.xcworkspace`.
- Confirm `swift test --package-path AirframeCore` succeeds.
- Confirm the package can be imported by AICockpit and AgileCockpit skeletons.

Verification:

```sh
swift test --package-path AirframeCore
swift package --package-path AirframeCore describe
```

### EP-002: Core Domain and Configuration Foundation

- Define canonical identifiers and model types for projects, actors, work items, issues, tasks, sprints, epics, evidence, verification gates, audit events, backend references, and metrics.
- Define status enums and state transition vocabulary.
- Define workspace/project configuration structures.
- Implement configuration loading from local JSON or YAML-like Swift Codable JSON files.
- Add fixtures for a sample workspace and project.

Verification:

```sh
swift test --package-path AirframeCore --filter Domain
swift test --package-path AirframeCore --filter Configuration
```

Independent executable result:

- A test or small fixture-driven API call can load a workspace and print/query canonical projects and work items.

### EP-003: Workflow, Authority, and Audit Foundation

- Implement actor identity context and certified actor type model.
- Implement deny-by-default authority evaluator.
- Implement project context binding and project mismatch denial.
- Implement workflow transition evaluator for tasks, issues, sprints, epics, and verification states.
- Implement audit event creation for allowed and denied operations.
- Add reason codes for denied operations suitable for CLI and UI presentation.

Verification:

```sh
swift test --package-path AirframeCore --filter Authority
swift test --package-path AirframeCore --filter Workflow
swift test --package-path AirframeCore --filter Audit
```

Independent executable result:

- Tests demonstrate allowed LLM operations and denied human-only operations with reason codes and audit records.

### EP-004: Local Backend and Task Packet MVP

- Define backend adapter protocol and capability model.
- Implement local filesystem backend for development and tests.
- Support create/query/update operations for issues and tasks.
- Support basic sprint and epic records.
- Implement evidence attachment.
- Implement task packet generation with constraints, acceptance criteria, verification steps, protected paths, and reporting format.
- Implement dashboard summary APIs over local backend data.

Verification:

```sh
swift test --package-path AirframeCore --filter Backend
swift test --package-path AirframeCore --filter TaskPacket
swift test --package-path AirframeCore --filter Dashboard
```

Independent executable result:

- A local fixture backend can create a task, attach evidence, transition it to ready for verification, and generate a compact task packet.

### EP-005: AICockpit MVP Integration

- Stabilize AirframeCore APIs required by AICockpit commands.
- Provide concise structured errors for CLI output.
- Provide project summary and next-task query APIs.
- Provide command-safe write operation wrappers.

Verification:

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
swift run --package-path AICockpit aicockpit --help
```

Independent executable result:

- AICockpit can propose a task, retrieve next task, attach evidence, mark ready for verification, and print project summary using AirframeCore.

### EP-006: AgileCockpit Dashboard MVP Integration

- Stabilize AirframeCore APIs required by AgileCockpit dashboard and review views.
- Provide dashboard summaries, verification queue queries, metrics series, and audit queries.
- Provide operation evaluation APIs so UI can show enabled/disabled human actions.

Verification:

```sh
swift test --package-path AirframeCore
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Independent executable result:

- AgileCockpit can display local backend data and perform a human verification operation through AirframeCore.

### EP-007: GitHub Backend MVP

- Implement GitHub backend adapter capability map.
- Map issues and tasks to GitHub Issues with labels or project fields.
- Map sprints to milestones or project iteration fields where available.
- Map epics to issues, labels, milestones, or project fields based on capability.
- Attach evidence and audit references as comments or local audit records.
- Handle authentication, rate limits, and backend failures with clear errors.

Verification:

```sh
swift test --package-path AirframeCore --filter GitHub
```

Independent executable result:

- Against a test repository or mocked GitHub adapter, AirframeCore can round-trip canonical work items through backend mappings.

### EP-008: Verification, Hardening, and Release Candidate

- Expand policy, workflow, adapter, metrics, and audit test coverage.
- Add malformed configuration tests.
- Add stale data and backend failure tests.
- Document public API usage for client CSCIs.
- Freeze MVP data model and command-facing APIs.

Verification:

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Independent executable result:

- Core can support end-to-end local and GitHub-backed workflows with documented verification evidence.

## 5. Cross-CSCI Interfaces

AirframeCore must expose:

- Read APIs for workspace, project, dashboard, metrics, work item, sprint, epic, evidence, verification queue, and audit data.
- Write APIs for issue/task creation, evidence attachment, workflow transition requests, sprint operations, epic operations, and human verification.
- Evaluation APIs returning allowed, denied, or requires-confirmation results.
- Backend adapter protocols and capability descriptions.
- Structured errors with reason codes.

## 6. Definition of Done

AirframeCore work is complete for a milestone when:

- Public APIs required by dependent CSCIs are implemented or explicitly stubbed with tracked follow-up tasks.
- Relevant unit tests pass.
- Local backend fixtures exist for independent verification.
- Denied operations return deterministic reason codes.
- Documentation is updated for any API or workflow behavior added in the milestone.

