# GitHub Issue Sync Procedure

This procedure defines how GitHub Issues stay synchronized with Airframe Tasks and Airframe Issues.

## Invariants

1. Every Airframe Task has exactly one GitHub Issue.
2. Every Airframe Issue has exactly one GitHub Issue.
3. Every GitHub Issue in `justgus/Airframe` must be assigned to exactly one Airframe Task ID or one Airframe Issue ID.
4. Airframe Task GitHub Issue titles begin with `[T-XXXX]`.
5. Airframe Issue GitHub Issue titles begin with `[I-XXXX]`.
6. GitHub Issue bodies include `Airframe Type:` and `Airframe ID:`.
7. Local status and GitHub status labels must be updated together.

## Creating A Task

When a Task is created locally:

1. Assign the next `T-XXXX` ID from `docs/Tasks/Task-Documentation.md`.
2. Create a GitHub Issue with title `[T-XXXX] [Task title]`.
3. Include these fields in the GitHub Issue body:

```text
Airframe Type: Task
Airframe ID: T-XXXX
Epic: EP-XXX
Priority: High|Medium|Low|Critical
Status: Backlog
```

4. Add labels:
   - `airframe-task`
   - one `epic-EP-XXX` label
   - one status label, initially `status-backlog`
5. Add `**GitHub Issue:** #NNN` to the local Task record.
6. Add the mapping to `docs/GitHub-Issue-Mapping.md`.
7. Update `docs/Tasks/Task-Documentation.md` and the relevant Task state file.

## Creating An Issue

When an Issue is created locally:

1. Assign the next `I-XXXX` ID from `docs/Issues/Issue-Documentation.md`.
2. Create a GitHub Issue with title `[I-XXXX] [Issue title]`.
3. Include these fields in the GitHub Issue body:

```text
Airframe Type: Issue
Airframe ID: I-XXXX
Severity: Critical|High|Medium|Low
Status: Open
```

4. Add labels:
   - `airframe-issue`
   - `status-backlog`
5. Record the mapping on the canonical Issue record.
6. Regenerate the supported projections under `docs/generated/`.

## Moving Work Between States

When a Task or Issue moves to or from backlog:

1. Update the canonical record status.
2. Regenerate the supported projections under `docs/generated/`.
3. Update the linked GitHub Issue labels:
   - Backlog: `status-backlog`
   - Active/In Progress: `status-active`
   - Implemented or Resolved - Not Verified: `status-unverified`
   - Verified: `status-verified`
   - Closed: close the GitHub Issue unless the user directs otherwise.
4. Add or update a short GitHub Issue comment if the transition includes evidence, test results, or user verification notes.

GitHub status changes made manually must be reconciled into canonical state before the affected work is considered current.

## Canonical GitHub Import

GitHub Issue import is a deliberate, initiated canonical operation. There is no scheduled GitHub Issue import workflow.

Before importing, inspect open GitHub Issues that do not already have:

- a `[T-XXXX]` or `[I-XXXX]` title prefix; or
- an `Airframe ID:` field in the body.

Import each qualifying GitHub Issue through AICockpit's canonical Issue workflow. The imported GitHub Issue becomes a backlogged Airframe Issue:

- next available `I-XXXX` ID assigned;
- GitHub Issue title changed to `[I-XXXX] ...`;
- GitHub Issue body updated with `Airframe Type: Issue` and `Airframe ID: I-XXXX`;
- labels `airframe-issue` and `status-backlog` added;
- the canonical Issue record and mapping updated;
- projections under `docs/generated/` are regenerated from canonical state.

The former `scripts/import-github-issues.sh` mutator is retired; it exits without changing files. Use AICockpit's canonical Issue workflow for imports and regenerate projections afterward.

To inspect unmapped GitHub Issues:

```sh
gh issue list --repo justgus/Airframe --state open --limit 100 --json number,title,body \
  --jq '.[] | select((.title | test("^\\\\[(T|I)-[0-9]{4}\\\\]") | not) and ((.body // "") | contains("Airframe ID:") | not))'
```
