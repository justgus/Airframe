# AGENTS.md

This file governs coding-agent behavior in this repository. Follow it before any general coding-agent habit or inferred next step. It is written in terms of Codex; it applies in full to any coding agent working here, and where it says "Codex" a different agent should read its own name.

Claude Code reaches this file through `CLAUDE.md`, which points here for all policy and adds only harness-specific rules: plan mode as the approval vehicle, local git, subagents and background work, and reporting. Policy changes belong in this file. If the two ever conflict, surface the conflict instead of choosing.

## Operating Principle

The user owns the project direction and approval boundary. Codex must not turn broad statements, observations, or next-step framing into implementation without explicit approval.

## Overarching Principles

1. Don't assume. Don't hide confusion. Surface tradeoffs.
2. Minimum code that solves the problem. Do nothing speculative.
3. Touch only what you must. Clean up only your own mess.
4. Define success criteria. Loop until approved.
5. Codex can make mistakes. Do not assume Codex is always right.
6. The Human can make mistakes. Do not assume that the Human is always right.

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

- Codex may mutate GitHub without per-action approval only for agent-allowed Airframe workflow synchronization on work it is handling, after implementing or resolving that work locally and recording evidence:
  - Move assigned or active Tasks from `status-active` to `status-unverified`.
  - Move assigned or active Issues from `status-active` or `status-in-progress` to `status-unverified`.
  - Add implementation or evidence comments for Codex-completed work.
  - Keep established Airframe labels synchronized with local artifact state for agent-allowed transitions.
- Explicit user authorization is still required for human-only acceptance or verification; closing a Sprint, Epic, or Audit; pushes; destructive remote changes; workflow policy changes; and creating/changing labels outside the established Airframe workflow labels.
- Read-only GitHub inspection is allowed when it is necessary to answer a current request, subject to tool permissions.
- Report remote changes made, including issue numbers, labels/states changed, and comments added.

## Sources of Truth and Precedence

Use this precedence order for authorization and agent conduct:

1. Explicit current user direction.
2. This `AGENTS.md`.

Use this separate precedence order for the intended scope and behavior of approved work:

1. Explicit current user direction.
2. The approved AICockpit Task packet governing the work.
3. Approved design documents under `docs/` that govern the affected feature or subsystem.
4. AirframeCore policy and `.airframe/state/` for current workflow state and semantics.
5. Generated Markdown as a projection of canonical state.
6. Legacy tracking Markdown and the current implementation as evidence of existing or historical behavior.
7. Historical, archived, release-note, and migration documents.

A packet or design document cannot override the authorization and human-only boundaries in this `AGENTS.md` unless the user explicitly changes those boundaries.

Not every file under `docs/` is a design authority. Tracking indexes, archives, release notes, and migration documents are records or historical guidance unless the user explicitly designates them otherwise. If the applicable sources disagree, surface the conflict before making a consequential change.

## AICockpit Artifact Management

For all Agile Artifact work, use AICockpit before directly editing `docs/Tasks`, `docs/Issues`, `docs/Sprints`, `docs/Epics`, or GitHub issue state. Helper scripts in `.airframe/scripts/` are the canonical interface for routine startup and Task-packet retrieval.

At the start of artifact-related work, inspect project state:

```sh
.airframe/scripts/ac-status.sh
```

For assigned work, retrieve the task packet before implementation:

```sh
.airframe/scripts/ac-packet.sh T-XXXX
```

AICockpit has no Issue-packet command. For assigned Issue work use `ac-status.sh` and read-only Issue discovery; if that is not enough implementation context, state the gap and ask before treating another source as the governing packet.

Use AICockpit for discovery, Task packets, evidence attachment, evidence comments, and the agent-allowed transitions in the workflow table. Codex must never perform or claim human-only acceptance or verification, mark an Issue or Task Verified, close a Sprint, Epic, or Audit, or change workflow policy, through AICockpit or any other tool. The user performs Verified and Closed transitions through AgileCockpit.

If AICockpit does not support a needed artifact mutation, state the gap and ask before directly editing Agile Markdown or mutating GitHub.

For live GitHub-backed artifact updates, the following helper commands are available:

```sh
.airframe/scripts/ac-github-evidence-comment.sh T-XXXX EV-XXXX-001 \
  "Verification summary" "artifact path" "ApproverName"

.airframe/scripts/ac-github-status.sh T-XXXX unverified "ApproverName"
```

## Agile Tracking

This project uses four complementary tracking layers:

```text
Epics -> Sprints -> Tasks / Issues
```

An **Agile Artifact** is an Issue, Task, Sprint, or Epic. A **tracking document** is a Markdown record that stores or summarizes Agile Artifacts. Audits inspect tracking documents but are not a fifth tracking layer.

### Workflow and authority

Every supported state and the authority to enter it is enumerated here. `Agent` means Codex acting through AICockpit or an approved fallback. `Human` means the user acting through AgileCockpit.

| Artifact | State | Meaning | Authorized actor |
| --- | --- | --- | --- |
| Issue | Backlog | Defined but not being worked | Agent, within explicitly requested or approved scope |
| Issue | In Progress | Assigned work is underway | Agent |
| Issue | Resolved - Not Verified | Fix is complete with evidence, pending acceptance | Agent |
| Issue | Resolved - Verified | User accepted the fix | Human only |
| Issue | Closed | User ended the Issue without verification, or completed final archival where policy requires it | Human only |
| Task | Backlog | Defined but not being worked | Agent, within explicitly requested or approved scope |
| Task | Active | Assigned implementation is underway | Agent |
| Task | Implemented - Not Verified | Implementation and self-test are complete, pending acceptance | Agent |
| Task | Implemented - Verified | User accepted the implementation | Human only |
| Task | Closed | User ended or finally archived the Task where policy requires it | Human only |
| Sprint | Backlog | Identified but not ready to start | Agent, within explicitly requested or approved scope |
| Sprint | Planning | Defined and ready for activation | Agent, within explicitly requested or approved scope |
| Sprint | Active | Iteration is underway | Agent, within explicitly requested or approved scope |
| Sprint | Review | Sprint is Complete from the agent's perspective and awaits human closeout | Agent |
| Sprint | Closed | User approved closure and retrospective | Human only |
| Epic | Proposed | Rough strategic scope exists | Agent, within explicitly requested or approved scope |
| Epic | Draft | Scope and acceptance criteria are being developed | Agent, within explicitly requested or approved scope |
| Epic | Backlog | Defined but not executing | Agent, within explicitly requested or approved scope |
| Epic | Active | One or more Sprints are executing against it | Agent, within explicitly requested or approved scope |
| Epic | Complete | Work appears complete and awaits human closeout | Agent |
| Epic | Closed | User approved closeout | Human only |
| Audit cycle | Findings in progress | Phase 1 examination is underway | Agent, after explicit user request for an Audit |
| Audit cycle | Findings complete | Findings artifact is ready for review | Agent |
| Audit cycle | Findings verified | User authorizes the Rulings session | Human only |
| Audit cycle | Rulings in progress | User decisions are being recorded | Human decides; Agent records |
| Audit cycle | Rulings complete | Every finding, recommendation, and question has a ruling | Agent records completion |
| Audit cycle | Rulings verified | User authorizes Remediation | Human only |
| Audit cycle | Remediation in progress | Approved rulings are being applied | Agent |
| Audit cycle | Complete - Not Closed | Remediation is applied and mechanically checked | Agent |
| Audit cycle | Closed | User reviewed the remediation log and closed the cycle | Human only, through AgileCockpit |

`Review` is AirframeCore's canonical Sprint state and means **Complete, pending human closure**. Do not invent a separate stored Sprint `Complete` value. Audit-cycle states are carried by the three Audit artifacts; Audits are not currently an `AirframeWorkItemKind`. If AgileCockpit exposes no Audit-close action, report the gap and leave the Audit Complete - Not Closed. Codex must not substitute for the human action.

Agent authority to enter a state does not authorize Codex to create work from a planning conversation. Sprint and Epic creation or activation still requires an explicit user instruction or a user-approved plan containing that action.

### Artifact documents

Paths are relative to `docs/`. Authority for every state is in the table above; these sections locate the records only.

| Artifact | Active | Backlog | Index | Archived | Guidelines |
| --- | --- | --- | --- | --- | --- |
| Issue (I) - bugs, defects, unintended behavior | `Issues/Issue-active.md` | `Issues/Issue-backlog.md` | `Issues/Issue-Documentation.md` | `Issues/Verified/Issue-verified-<ID-or-range>.md`, `Issues/Closed/Issue-closed-<ID-or-range>.md` | `Issues/Issue-GUIDELINES.md` |
| Task (T) - features, improvements, planned changes | `Tasks/Task-active.md` | `Tasks/Task-backlog.md` | `Tasks/Task-Documentation.md` | `Tasks/Verified/Task-verified-<ID-or-range>.md`, `Tasks/Closed/Task-closed-<ID-or-range>.md` when closed Tasks are archived separately | `Tasks/Task-Guidelines.md` |
| Sprint (SP) - fixed-duration iterations | `Sprints/Sprint-active.md` | `Sprints/Sprint-backlog.md` | `Sprints/Sprint-Documentation.md` | `Sprints/Closed/Sprint-SP-XXX.md` | `Sprints/Sprint-GUIDELINES.md` |
| Epic (EP) - strategic milestones spanning Sprints | `Epics/Epic-active.md` | `Epics/Epic-backlog.md` | `Epics/Epic-Documentation.md` | `Epics/Closed/Epic-EP-XXX.md` | `Epics/Epic-GUIDELINES.md` |

Tasks also carry `Tasks/Task-unverified.md` for Implemented - Not Verified work.

### Audits - documentation consistency

An **Audit** is Phase 1, the full read-only examination of canonical Agile state and its Generated, Legacy, and Backend surfaces. An **Audit cycle** is the complete three-phase Findings, Rulings, and Remediation process. An **Audit Check** is the lightweight canonical-first, read-only mechanical review before Epic closure: not a full Audit, it creates no formal Audit, and its findings are handled during the Epic-close review. Process and artifact formats are defined in `docs/Audits/Audit-Guidelines.md`.

- Phase 1: `docs/Audits/Audit-Findings-YYYYMMDD.md`
- Phase 2: `docs/Audits/Audit-Rulings-YYYYMMDD.md`
- Phase 3: `docs/Audits/Audit-Remediation-YYYYMMDD.md`

The following rules are always in force:

1. A full Audit begins only when the user explicitly requests one. If Codex notices drift, it may recommend an Audit but must wait for authorization.
2. Phase 1 is read-only with respect to tracking documents. It records findings and does not repair them.
3. Phase 2 records user rulings and changes no tracking documents.
4. Only Phase 3 edits tracking documents, working from an approved rulings file and citing ruling numbers.
5. Each phase must complete and receive the required user authorization before the next begins.
6. Codex may mark an Audit cycle Complete - Not Closed. Only the user may close it, through AgileCockpit.
7. Audit findings distinguish Canonical defects, Generated projection drift, Legacy-document drift, and Backend synchronization drift. Generated Markdown is never repaired by hand.


When implementing fixes or features:

1. Document the work in the appropriate Issue or Task.
2. Assign it to the current Sprint if one is active. The current Sprint is the single Sprint AICockpit reports Active. If none or more than one is Active, surface the inconsistency before assigning work.
3. Include file-and-line references.
4. Mark it `Resolved - Not Verified` or `Implemented - Not Verified` when done.
5. Leave acceptance and verification to the user.

## Airframe Project Conventions

- AirframeCore is canonical for workflow policy, authority evaluation, backend capabilities, configuration diagnostics, and work record semantics.
- AICockpit is the agent-facing CLI; AgileCockpit is the human-facing review surface and may expose human verification actions through AirframeCore.
- Human-facing artifact labels use the state names in the workflow table. The short labels `Implemented`, `Resolved`, and `Review` mean Implemented - Not Verified, Resolved - Not Verified, and Complete - Not Closed.
- Use the helper scripts under **AICockpit Artifact Management** for routine startup and Task packets. Direct `swift run` commands are diagnostic fallbacks, not a second required startup sequence.
- If AICockpit cannot perform a needed agent-allowed mutation, Codex may edit Agile Artifact Markdown directly or update established Airframe GitHub labels to keep state synchronized. Anything outside the agent-allowed GitHub synchronization boundary needs the capability gap stated and approval requested first.
- Live GitHub access is not assumed. Fixture-backed GitHub behavior is distinct from live GitHub Issues integration.
- A live demonstration project must be planned before implementation. The plan must specify repository/project target, local clone or remote source, backend mode, credential expectations, install locations, seeded data, and verification criteria.

## Communication

- Keep status updates concise and concrete.
- When a user correction identifies a process failure, acknowledge it directly and adjust behavior immediately.
- Do not spend tokens defending a mistaken action. State current state, what changed, and what approval is needed next.
