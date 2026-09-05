# .airframe/

Airframe workspace for this project. This folder is the portable template: it
carries its own `.gitignore`, `.gitattributes`, and conventions, so copying it
into a new project brings the working agreements with it. Nothing here depends
on a root `AGENTS.md` or `CLAUDE.md`.

## Layout

| Path | What it is | Authored or derived |
| --- | --- | --- |
| `scripts/` | Agent-facing helper scripts; the canonical interface | authored |
| `airframe-workspace.json` | Workspace/project/backend configuration | authored |
| `state/` | Canonical records (requirements, tasks, epics, sprints, tests) | authored via AICockpit |
| `*-cache.json` | AgileCockpit UI caches | **derived, gitignored** |

## Read discipline

These rules exist for token economy. The derived surfaces restate canonical
state at many times the cost of a targeted query, and the expensive path is
often the more obvious one.

1. **Query through `scripts/`.** Do not read `state/**` directly. A single
   `ac-*.sh` call costs a few hundred tokens; the state tree is far larger and
   most of each record is schema scaffolding rather than meaning.
2. **Never read or diff `*-cache.json`.** They are derived from `state/`,
   rebuilt on launch, and written as single-line JSON — so an ordinary
   `git diff` of one emits both full copies of a multi-megabyte file. They are
   gitignored and marked `-diff` here to make that difficult by accident.
3. **Do not read generated documentation** (for example `docs/generated/**`) as
   a source of truth. It is a projection of canonical state and is never
   repaired by hand.
4. **Fetch one record, not the corpus.** To answer a question about a single
   requirement or work item, query that ID. Do not read an entire
   specification, index, or traceability matrix to find one entry.

`scripts/_ac_common.sh` prints an abbreviated form of these rules once per
shell session. Set `AC_QUIET=1` to silence it.

## Scripts

Run `ac-status.sh` at the start of artifact work. Every script sources
`_ac_common.sh`, which locates the `aicockpit` binary and passes `--config`.

| Script | Purpose |
| --- | --- |
| `ac-status.sh` | Workspace context and dashboard summary |
| `ac-next.sh` | Next active task, or reports none |
| `ac-packet.sh T-XXXX` | Task packet for assigned work |
| `ac-ready.sh` | Mark a Task Implemented - Not Verified |
| `ac-evidence.sh` | Attach evidence to a Task |
| `ac-propose-task.sh` / `ac-propose-issue.sh` | Propose a new Task or Issue record |
| `ac-github-*.sh` | GitHub label, status, and comment synchronization |
| `ac-launch-cockpit.sh` | Launch AgileCockpit (`--clear-cache` to rebuild UI caches) |

## Porting to a new project

Copy `.airframe/scripts/`, `.gitignore`, `.gitattributes`, and this README.
Do not copy `state/` or `*-cache.json` — those are project-specific. Create a
new `airframe-workspace.json` for the target project. Check that `AICOCKPIT`
in `_ac_common.sh` resolves to the binary from the new location.
