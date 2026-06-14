# AICockpit Mutation Command Contract

AICockpit is the agent-facing command interface for Airframe. It may create and update work records only through AirframeCore policy and authority checks. It must not perform human-only acceptance, verification, sprint closure, epic closure, destructive operations, or policy configuration.

This contract defines the command surface for SP-018 implementation. Commands are implemented incrementally, but their behavior must remain compatible with this document.

## Common Options

Mutation commands use the same runtime options as existing AICockpit commands:

```sh
--config path
--backend local-fixture|github-fixture|github-issues
--store path
--output markdown|json
```

Commands that mutate the live GitHub Issues backend require explicit approval:

```sh
--approve --approved-by name
```

If approval is missing for a live GitHub mutation, the command must fail without changing remote state. Local fixture and GitHub fixture commands may mutate without `--approve` unless the specific operation is marked as requiring confirmation by AirframeCore.

## Create Commands

Create commands add new mapped Airframe work items. They must reject duplicate IDs and IDs with the wrong artifact prefix.

```sh
aicockpit task create --id T-XXXX --title title --epic EP-XXXX [--sprint SP-XXXX] [--priority low|medium|high] [common options]
aicockpit issue create --id I-XXXX --title title --epic EP-XXXX [--sprint SP-XXXX] [--severity low|medium|high] [common options]
aicockpit sprint create --id SP-XXXX --title title --epic EP-XXXX [--status backlog|planning] [common options]
aicockpit epic create --id EP-XXXX --title title [--status proposed|draft|backlog] [common options]
```

Initial statuses are constrained by artifact kind:

| Artifact | Default Status | Allowed Initial Statuses |
| -------- | -------------- | ------------------------ |
| Task | Backlog | Backlog, Active |
| Issue | Backlog | Backlog, Active |
| Sprint | Backlog | Backlog, Planning |
| Epic | Proposed | Proposed, Draft, Backlog |

The GitHub Issues backend creates GitHub issues for Tasks and Issues only. Sprint and Epic creation on GitHub is represented by labels and local artifact metadata until Airframe has a dedicated remote artifact store.

## Update Commands

Update commands modify fields that agents are allowed to maintain.

```sh
aicockpit task update T-XXXX [--title title] [--epic EP-XXXX] [--sprint SP-XXXX] [--priority low|medium|high] [common options]
aicockpit issue update I-XXXX [--title title] [--epic EP-XXXX] [--sprint SP-XXXX] [--severity low|medium|high] [common options]
aicockpit sprint update SP-XXXX [--title title] [--epic EP-XXXX] [--status backlog|planning|active|review] [common options]
aicockpit epic update EP-XXXX [--title title] [--status proposed|draft|backlog|active|complete] [common options]
```

Status updates must evaluate the AirframeCore workflow transition before applying changes. The command must report invalid transitions as failures without partial mutation.

## Status Commands

Status-specific commands provide a narrower interface for workflow movement:

```sh
aicockpit task status T-XXXX --to backlog|active|implemented [common options]
aicockpit issue status I-XXXX --to backlog|active|resolved [common options]
aicockpit sprint status SP-XXXX --to backlog|planning|active|review [common options]
aicockpit epic status EP-XXXX --to proposed|draft|backlog|active|complete [common options]
```

The user-facing words map to AirframeCore statuses as follows:

| Command Value | Core Status |
| ------------- | ----------- |
| implemented | Implemented - Not Verified |
| resolved | Resolved - Not Verified |

AICockpit must reject Task or Issue `verified` status. Task verification, Issue verification, Sprint closure, and Epic closure require human-facing AgileCockpit authority.

## Local Behavior

Local mutation support writes the canonical local artifact files and supporting indexes together:

- Task details: `docs/Tasks/Task-backlog.md`, `docs/Tasks/Task-active.md`, or `docs/Tasks/Task-unverified.md`.
- Issue details: `docs/Issues/Issue-backlog.md` or `docs/Issues/Issue-active.md`.
- Sprint details: `docs/Sprints/Sprint-backlog.md` or `docs/Sprints/Sprint-active.md`.
- Epic details: `docs/Epics/Epic-backlog.md` or `docs/Epics/Epic-active.md`.
- Indexes: `Task-Documentation.md`, `Issue-Documentation.md`, `Sprint-Documentation.md`, `Epic-Documentation.md`, and `GitHub-Issue-Mapping.md` when mapping changes.

Local mutations must be all-or-nothing at the command level. If any target file cannot be parsed or written, the command must leave the work item in its previous state and return an error.

## GitHub Behavior

Live GitHub mutation support maps Airframe fields to GitHub issue state:

- Task and Issue title updates update the GitHub issue title.
- Status updates replace the old `status-*` label with the new status label.
- Epic and Sprint assignments replace `epic-EP-*` and `sprint-SP-*` labels.
- Create commands for Tasks and Issues create mapped GitHub issues and add `airframe-task` or `airframe-issue`.

Live GitHub commands require `--approve --approved-by name` and must include the approver in the command result. AICockpit must not silently fall back from GitHub mutation to local-only mutation.

## Explicitly Rejected Operations

AICockpit must reject these operations even when `--approve` is present:

- `task status T-XXXX --to verified`
- `issue status I-XXXX --to verified`
- `sprint status SP-XXXX --to closed`
- `epic status EP-XXXX --to closed`
- Any direct operation that maps to `humanAcceptance`, `sprintControl` closure, `epicControl` closure, `policyConfiguration`, or `destructive`.

Rejections must return structured errors in JSON mode and must not mutate local files or GitHub state.
