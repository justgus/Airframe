# AICockpit Implementation Plan

**CSCI:** AICockpit  
**Product Form:** Swift package executable plus reusable command library target  
**Target Toolchain:** Xcode 26 / Swift  
**Target Platform:** macOS 26 command-line environments  
**Status:** Planning baseline  

## 1. Objective

AICockpit is the agent-facing command interface for Agile Airframe. It must be directly usable by Codex, Claude Code, shell scripts, and CI while delegating all domain, workflow, authority, backend, and audit decisions to AirframeCore.

## 2. Package Shape

Initial package layout:

```text
AICockpit/
├── Package.swift
├── Sources/
│   ├── AICockpit/
│   │   └── main.swift
│   └── AICockpitKit/
│       ├── Commands/
│       ├── Context/
│       ├── Formatting/
│       └── Runtime/
└── Tests/
    └── AICockpitKitTests/
```

The executable target should stay thin. Command parsing, command execution, formatting, and error handling belong in `AICockpitKit` so they can be unit tested without launching a subprocess for every case.

## 3. Epic Roadmap

| Epic | Milestone | Executable Result |
| ---- | --------- | ----------------- |
| EP-001 | Workspace and Toolchain Baseline | AICockpit package builds, tests, and prints help. |
| EP-002 | Core Domain and Configuration Foundation | AICockpit can resolve workspace/project context from local fixtures. |
| EP-003 | Workflow, Authority, and Audit Foundation | AICockpit receives allowed/denied decisions and prints structured errors. |
| EP-004 | Local Backend and Task Packet MVP | AICockpit can execute local issue/task operations through AirframeCore. |
| EP-005 | AICockpit MVP Integration | CLI workflow is independently useful for agents. |
| EP-007 | GitHub Backend MVP | CLI can target GitHub-backed projects through AirframeCore. |
| EP-008 | Verification, Hardening, and Release Candidate | CLI output, errors, and command contracts are stable. |

## 4. Command Surface

MVP command families:

```text
aicockpit --help
aicockpit context
aicockpit project summary
aicockpit task propose
aicockpit issue propose
aicockpit task next
aicockpit task packet <id>
aicockpit evidence attach <id>
aicockpit work ready <id>
aicockpit audit show <id>
```

EP-005 freezes the implemented local MVP command names above except `audit show`, which remains future scope. Commands support compact default Markdown output and optional JSON output.

## 5. Milestone Tasks

### EP-001: Workspace and Toolchain Baseline

- Create `Package.swift` with executable product `aicockpit`.
- Add `AICockpitKit` library target and tests.
- Add local package dependency on `AirframeCore`.
- Implement `--help` and version output.
- Add package to `Airframe.xcworkspace`.

Verification:

```sh
swift test --package-path AICockpit
swift run --package-path AICockpit aicockpit --help
```

Independent executable result:

- Agents can run `aicockpit --help` and receive deterministic command help.

### EP-002: Core Domain and Configuration Foundation

- Implement context discovery command using AirframeCore configuration APIs.
- Resolve execution project and target project from config or flags.
- Print compact workspace/project context.
- Add tests for missing, invalid, and valid configuration.

Verification:

```sh
swift test --package-path AICockpit --filter Context
swift run --package-path AICockpit aicockpit context show
```

Independent executable result:

- CLI can identify the current Airframe project context from local fixtures.

### EP-003: Workflow, Authority, and Audit Foundation

- Route command requests through AirframeCore operation evaluation APIs.
- Implement structured denial output with reason code, explanation, and target entity.
- Add audit identifier display for write operations.
- Add tests proving actor type and project scope cannot be spoofed by command-line flags.

Verification:

```sh
swift test --package-path AICockpit --filter Authority
swift test --package-path AICockpit --filter Output
```

Independent executable result:

- CLI can demonstrate a denied human-only operation and return a compact, machine-readable error.

### EP-004: Local Backend and Task Packet MVP

- Implement `task propose`, `issue propose`, `task next`, `task packet`, `evidence attach`, and `work ready` commands over the local backend.
- Support Markdown output for human readability.
- Support JSON output for agents and automation.
- Add fixture-driven integration tests.

Verification:

```sh
swift test --package-path AICockpit --filter Command
swift run --package-path AICockpit aicockpit project summary
```

Independent executable result:

- An agent can create a task, retrieve it, request a task packet, attach evidence, and mark it ready for human verification in a local Airframe workspace.

### EP-005: AICockpit MVP Integration

- Freeze MVP command names and output contracts.
- Add concise default output for all MVP commands.
- Add deterministic JSON schema for command responses.
- Add documentation for agent usage in [AgentUsage.md](AgentUsage.md).
- Add end-to-end scripted smoke test.

Verification:

```sh
swift test --package-path AICockpit
swift run --package-path AICockpit aicockpit task next --output json
```

Independent executable result:

- Codex and Claude Code can use AICockpit for scoped local project-management workflows without relying on AgileCockpit.

### EP-007: GitHub Backend MVP

- Add backend selection/context display for GitHub projects.
- Verify CLI commands remain backend-agnostic.
- Add GitHub backend error rendering.
- Add mocked GitHub command tests.

Verification:

```sh
swift test --package-path AICockpit --filter GitHub
```

Independent executable result:

- CLI commands operate against a GitHub-backed project through AirframeCore without command vocabulary changes.

### EP-008: Verification, Hardening, and Release Candidate

- Add parser edge case tests.
- Add snapshot-style tests for Markdown and JSON output.
- Add invalid input and malformed config tests.
- Add install/run documentation for local agents.
- Validate command behavior from a clean checkout.

Verification:

```sh
swift test --package-path AICockpit
swift run --package-path AICockpit aicockpit --help
```

Independent executable result:

- AICockpit is ready for repeated agent use with stable command contracts and documented failure behavior.

## 6. Definition of Done

AICockpit work is complete for a milestone when:

- Commands are routed through AirframeCore rather than duplicating workflow logic.
- Default output is compact and deterministic.
- JSON output is valid and tested where provided.
- Errors include actionable reason codes.
- `swift test` passes for AICockpit and AirframeCore.
