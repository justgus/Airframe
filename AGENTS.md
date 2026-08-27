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

- Codex may mutate GitHub without per-action approval only for agent-allowed Airframe workflow synchronization on work it is handling:
  - Move assigned or active Tasks from `status-active` to `status-unverified` after Codex has implemented the work locally and recorded evidence.
  - Move assigned or active Issues from `status-active` or `status-in-progress` to `status-unverified` after Codex has resolved the issue locally and recorded evidence.
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

Not every file under `docs/` is a design authority. Tracking indexes, archives, release notes, migration documents, and `docs/CLAUDE.md` are records or historical guidance unless the user explicitly designates them otherwise. If the applicable sources disagree, surface the conflict before making a consequential change.

## AICockpit Artifact Management

For all Agile Artifact work, use AICockpit as the primary interface before directly editing `docs/Tasks`, `docs/Issues`, `docs/Sprints`, `docs/Epics`, or GitHub issue state. Helper scripts live in `.airframe/scripts/` and are the canonical interface for routine startup and Task-packet retrieval.

At the start of artifact-related work, inspect project state:

```sh
.airframe/scripts/ac-status.sh
```

For assigned work, retrieve the task packet before implementation:

```sh
.airframe/scripts/ac-packet.sh T-XXXX
```

AICockpit does not currently provide an Issue-packet command. For assigned Issue work, use `.airframe/scripts/ac-status.sh` and AICockpit read-only Issue discovery. If those do not provide enough implementation context, state the capability gap and ask the user before treating another source as the governing packet.

Codex may use AICockpit for discovery, Task packets, evidence attachment, evidence comments, and the agent-allowed workflow transitions enumerated below. Codex must not perform or claim human-only acceptance or verification, mark an Issue or Task Verified, or close a Sprint, Epic, or Audit. The user performs Verified and Closed transitions through AgileCockpit.

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

`Review` is AirframeCore's canonical Sprint state and means **Complete, pending human closure**. Do not invent a separate stored Sprint `Complete` value. Audit-cycle states are carried by the three Audit artifacts; Audits are not currently an `AirframeWorkItemKind`. If AgileCockpit does not expose an Audit-close action, report that capability gap and leave the Audit Complete - Not Closed; Codex must not substitute for the human action.

Agent authority to enter a state does not authorize Codex to create work from a planning conversation. Sprint and Epic creation or activation still requires an explicit user instruction or a user-approved plan containing that action.

### Issues (I) - bugs, defects, unintended behavior

- Active: `docs/Issues/Issue-active.md`
- Backlog: `docs/Issues/Issue-backlog.md`
- Index: `docs/Issues/Issue-Documentation.md`
- Archived (verified): `docs/Issues/Verified/Issue-verified-<ID-or-range>.md`
- Archived (closed): `docs/Issues/Closed/Issue-closed-<ID-or-range>.md`
- Guidelines: `docs/Issues/Issue-GUIDELINES.md`
- Codex may mark an Issue `Resolved - Not Verified`.
- Only the user may verify an Issue, through AgileCockpit.

### Tasks (T) - new features, improvements, planned changes

- Backlog: `docs/Tasks/Task-backlog.md`
- Active: `docs/Tasks/Task-active.md`
- Unverified: `docs/Tasks/Task-unverified.md`
- Index: `docs/Tasks/Task-Documentation.md`
- Archived (verified): `docs/Tasks/Verified/Task-verified-<ID-or-range>.md`
- Archived (closed): `docs/Tasks/Closed/Task-closed-<ID-or-range>.md`, when closed Tasks are archived separately
- Guidelines: `docs/Tasks/Task-Guidelines.md`
- Codex may mark a Task `Implemented - Not Verified`.
- Only the user may verify a Task, through AgileCockpit.

### Sprints (SP) - fixed-duration iterations

- Active: `docs/Sprints/Sprint-active.md`
- Backlog: `docs/Sprints/Sprint-backlog.md`
- Index: `docs/Sprints/Sprint-Documentation.md`
- Archived: `docs/Sprints/Closed/Sprint-SP-XXX.md`
- Guidelines: `docs/Sprints/Sprint-GUIDELINES.md`
- Codex may create and activate Sprints within explicitly requested or approved scope, and may mark them Review (Complete, pending human closure).
- Only the user may close a Sprint, through AgileCockpit.

### Epics (EP) - strategic milestones spanning multiple Sprints

- Active: `docs/Epics/Epic-active.md`
- Backlog: `docs/Epics/Epic-backlog.md`
- Index: `docs/Epics/Epic-Documentation.md`
- Archived: `docs/Epics/Closed/Epic-EP-XXX.md`
- Guidelines: `docs/Epics/Epic-GUIDELINES.md`
- Codex may create Epics within explicitly requested or approved scope and mark them Complete.
- Only the user may close an Epic, through AgileCockpit.

### Audits - documentation consistency

An **Audit** is Phase 1, the full read-only examination of canonical Agile state and its Generated, Legacy, and Backend surfaces. An **Audit cycle** is the complete three-phase Findings, Rulings, and Remediation process. An **Audit Check** is the lightweight canonical-first, read-only mechanical review performed before Epic closure. The complete process and artifact formats are defined in `docs/Audits/Audit-Guidelines.md`.

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

The Audit Check is a lightweight, read-only mechanical sweep performed before an Epic close. It is not a full Audit, does not create a formal Audit automatically, and its findings are handled during the Epic-close review.

When implementing fixes or features:

1. Document the work in the appropriate Issue or Task.
2. Assign it to the current Sprint if one is active. The current Sprint is the single Sprint AICockpit reports Active. If none or more than one is Active, surface the inconsistency before assigning work.
3. Include file-and-line references.
4. Mark it `Resolved - Not Verified` or `Implemented - Not Verified` when done.
5. Leave acceptance and verification to the user.

## Airframe Project Conventions

- Preserve AirframeCore as the canonical source for workflow policy, authority evaluation, backend capabilities, configuration diagnostics, and work record semantics.
- Use artifact-specific workflow labels in human-facing Agile Artifact work:
  - Epics: Proposed, Draft, Backlog, Active, Complete, Closed.
  - Sprints: Backlog, Planning, Active, Review, Closed, where Review means Complete - Not Closed.
  - Tasks: Backlog, Active, Implemented, Verified, Closed, where Implemented means Implemented - Not Verified and Verified means Implemented - Verified.
  - Issues: Backlog, In Progress, Resolved, Verified, Closed, where Resolved means Resolved - Not Verified and Verified means Resolved - Verified.
- AICockpit is the agent-facing CLI and must not perform human-only acceptance operations.
- Use the canonical helper-script procedure under **AICockpit Artifact Management** for routine Agile Artifact startup and Task packets. Direct `swift run` commands are diagnostic fallbacks, not an additional required startup sequence.
- Codex may use AICockpit for read-only discovery, Task packets, evidence attachment or evidence comments, and the agent-allowed transitions in the workflow table. Codex must not use AICockpit or any other tool to mark an Issue or Task Verified, close a Sprint, Epic, or Audit, or change workflow policy.
- If AICockpit does not support a needed agent-allowed Agile Artifact mutation, Codex may directly edit Agile Artifact Markdown or mutate established Airframe GitHub labels to keep state synchronized. Codex must state the capability gap and request approval before any mutation outside the agent-allowed GitHub synchronization boundary.
- AgileCockpit is the human-facing review surface and may expose human verification actions through AirframeCore.
- Live GitHub access is not assumed. Fixture-backed GitHub behavior is distinct from live GitHub Issues integration.
- A live demonstration project must be planned before implementation. The plan must specify repository/project target, local clone or remote source, backend mode, credential expectations, install locations, seeded data, and verification criteria.

## Communication

- Keep status updates concise and concrete.
- When a user correction identifies a process failure, acknowledge it directly and adjust behavior immediately.
- Do not spend tokens defending a mistaken action. State current state, what changed, and what approval is needed next.
