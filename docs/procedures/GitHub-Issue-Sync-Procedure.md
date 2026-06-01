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
5. Add `**GitHub Issue:** #NNN` to the local Issue record.
6. Add the mapping to `docs/GitHub-Issue-Mapping.md`.
7. Update `docs/Issues/Issue-Documentation.md` and `docs/Issues/Issue-backlog.md`.

## Moving Work Between States

When a Task or Issue moves to or from backlog:

1. Move the local record to the correct Airframe state file.
2. Update the local index table.
3. Update the linked GitHub Issue labels:
   - Backlog: `status-backlog`
   - Active/In Progress: `status-active`
   - Implemented or Resolved - Not Verified: `status-unverified`
   - Verified: `status-verified`
   - Closed: close the GitHub Issue unless the user directs otherwise.
4. Add or update a short GitHub Issue comment if the transition includes evidence, test results, or user verification notes.

GitHub status changes made manually must be reconciled into the local docs before the affected work is considered current.

## Nightly GitHub Import

The workflow `.github/workflows/nightly-github-issue-sync.yml` runs nightly and can also be run manually.

It imports open GitHub Issues that do not already have:

- a `[T-XXXX]` or `[I-XXXX]` title prefix; or
- an `Airframe ID:` field in the body.

Imported GitHub Issues become backlogged Airframe Issues:

- next available `I-XXXX` ID assigned;
- GitHub Issue title changed to `[I-XXXX] ...`;
- GitHub Issue body updated with `Airframe Type: Issue` and `Airframe ID: I-XXXX`;
- labels `airframe-issue` and `status-backlog` added;
- `docs/Issues/Issue-backlog.md`, `docs/Issues/Issue-Documentation.md`, and `docs/GitHub-Issue-Mapping.md` updated;
- the workflow commits the documentation update back to `main`.

## Manual Verification

To run the import locally:

```sh
bash scripts/import-github-issues.sh
```

To inspect unmapped GitHub Issues:

```sh
gh issue list --repo justgus/Airframe --state open --limit 100 --json number,title,body \
  --jq '.[] | select((.title | test("^\\\\[(T|I)-[0-9]{4}\\\\]") | not) and ((.body // "") | contains("Airframe ID:") | not))'
```
