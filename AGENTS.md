# AGENTS.md

This file governs Codex behavior in this repository. Follow it before any general coding-agent habit or inferred next step.

## Operating Principle

The user owns the project direction and approval boundary. Codex must not turn broad statements, observations, or next-step framing into implementation without explicit approval.

## Overarching Principles

1. Don't assume. Don't hide confusion. Surface tradeoffs.
2. Minimum code that solves the problem. Do nothing speculative.
3. Touch only what you must. Clean up only your own mess.
4. Define success criteria. Loop until approved.
5. Codex can make mistakes. Do not assume Codex is always right.
6. I (the Human) can make mistakes.  Do not assume that I (the Human) am always right.  

## Planning Versus Action

- Treat phrases such as "next step", "time to try", "we should", "let's think about", or "this requires planning" as planning context, not permission to modify files, build artifacts, run installs, or mutate external state.
- Before implementation, state a concrete plan with proposed file changes, commands, external effects, and verification steps.
- Wait for explicit user approval before executing the plan when the user has asked for planning, scope definition, or concrete actions.
- If the user says "begin", "implement", "run", "create", "edit", "install", or gives an equivalent direct instruction, proceed within the stated scope.

## File And Environment Changes

- Do not create, edit, delete, move, or install files unless the user explicitly asked for that action or approved a plan that includes it.
- Do not install into global locations such as `/Applications`, `/usr/local`, shell startup files, or system configuration without explicit approval.
- Do not create demo projects, generated build products, seeded stores, or local app installations from a planning conversation alone.
- If accidental changes are made, report them plainly and wait for direction. Do not silently revert user-owned changes.

## Verification And Commands

- Prefer direct, minimal verification commands that correspond to the task.
- Do not run wrapper scripts when the user has explicitly excluded them.
- Do not rerun commands that previously failed due to an understood environmental cause unless the user agrees or the command is necessary under a new plan.
- Before long-running, GUI, network, install, or externally mutating commands, explain the intent and wait for approval unless the user already authorized that exact action.

## GitHub And External State

- Codex may mutate GitHub without per-action approval only for agent-allowed Airframe workflow synchronization on work it is handling:
  - Move assigned or active Tasks from `status-active` to `status-unverified` after Codex has implemented the work locally and recorded evidence.
  - Move assigned or active Issues from `status-active` or `status-in-progress` to `status-unverified` after Codex has resolved the issue locally and recorded evidence.
  - Add implementation or evidence comments for Codex-completed work.
  - Keep established Airframe labels synchronized with local artifact state for agent-allowed transitions.
- Explicit user authorization is still required for human-only acceptance or verification, Sprint closure, Epic completion or closure, Issue closure, pushes, destructive remote changes, workflow policy changes, and creating/changing labels outside the established Airframe workflow labels.
- Read-only GitHub inspection is allowed when it is necessary to answer a current request, subject to tool permissions.
- Report remote changes made, including issue numbers, labels/states changed, and comments added.

## Airframe Project Conventions

- Preserve AirframeCore as the canonical source for workflow policy, authority evaluation, backend capabilities, configuration diagnostics, and work record semantics.
- Use artifact-specific workflow labels in human-facing Agile Artifact work:
  - Epics: Proposed, Draft, Backlog, Active, Complete, Closed.
  - Sprints: Backlog, Planning, Active, Review, Closed.
  - Tasks: Backlog, Active, Implemented, Verified, Closed, where Implemented means Implemented - Not Verified and Verified means Implemented - Verified.
  - Issues: Backlog, In Progress, Resolved, Verified, Closed, where Resolved means Resolved - Not Verified and Verified means Resolved - Verified.
- AICockpit is the agent-facing CLI and must not perform human-only acceptance operations.
- Use AICockpit as the primary interface for Agile Artifact discovery and agent-allowed workflow actions before directly editing `docs/Tasks/`, `docs/Issues/`, `docs/Sprints/`, `docs/Epics/`, or related GitHub issue state.
- For Agile Artifact work, first inspect context and project state with direct AICockpit commands, normally:

```sh
swift run --package-path AICockpit aicockpit context --config .airframe/airframe-workspace.json
swift run --package-path AICockpit aicockpit project summary --config .airframe/airframe-workspace.json --backend github-issues --output json
```

- For assigned Task work, retrieve the task packet through AICockpit before implementation, normally:

```sh
swift run --package-path AICockpit aicockpit task packet T-XXXX --config .airframe/airframe-workspace.json --backend github-issues --output json
```

- Codex may use AICockpit for read-only discovery, task packets, evidence attachment or evidence comments, and agent-allowed workflow transitions. Codex must not use AICockpit or any other tool to perform human-only acceptance, human verification, sprint closure, epic closure, issue closure, or workflow policy changes.
- If AICockpit does not support a needed agent-allowed Agile Artifact mutation, Codex may directly edit Agile Artifact Markdown or mutate established Airframe GitHub labels to keep state synchronized. Codex must state the capability gap and request approval before any mutation outside the agent-allowed GitHub synchronization boundary.
- AgileCockpit is the human-facing review surface and may expose human verification actions through AirframeCore.
- Live GitHub access is not assumed. Fixture-backed GitHub behavior is distinct from live GitHub Issues integration.
- A live demonstration project must be planned before implementation. The plan must specify repository/project target, local clone or remote source, backend mode, credential expectations, install locations, seeded data, and verification criteria.

## Communication

- Keep status updates concise and concrete.
- When a user correction identifies a process failure, acknowledge it directly and adjust behavior immediately.
- Do not spend tokens defending a mistaken action. State current state, what changed, and what approval is needed next.
