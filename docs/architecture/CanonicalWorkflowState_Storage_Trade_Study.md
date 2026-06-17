# Canonical Workflow State Storage Trade Study

**Status:** Planning  
**Date:** 2026-06-17  
**Decision Needed:** Canonical local storage format for Airframe workflow state.

## 1. Decision Context

Airframe workflow state must become canonical, structured, and repo-coupled. The store must evolve with the source code so that branches, forks, checkouts, reverts, and release tags preserve the exact development state that existed at that revision.

The storage choice must support:

- Git history.
- Human inspection.
- Stable IDs.
- Relationship links.
- Requirement traceability.
- Test evidence summaries.
- Generated documentation.
- AgileCockpit editing.
- AICockpit structured queries.
- Future external import/export.

## 2. Evaluation Criteria

| Criterion | Description |
| --- | --- |
| Repo-coupled history | State travels with source revisions. |
| Diffability | Changes are reviewable in Git. |
| Human inspectability | Humans can inspect records without specialized tools. |
| Tool simplicity | AirframeCore can read/write reliably with modest complexity. |
| Merge behavior | Branch merges are understandable and recoverable. |
| Query performance | State can be queried without expensive parsing. |
| Relationship integrity | Links between records can be validated. |
| Generated docs support | Markdown and reports can be generated deterministically. |
| External import/export | CSV, JSON, and future adapter workflows are supported. |
| CI compatibility | CI can read state and attach evidence links. |

## 3. Candidate Options

### Option A: Single Canonical JSON File

Store all canonical workflow state in one JSON file.

Example:

```text
.airframe/state/airframe-state.json
```

Strengths:

- Simple to load atomically.
- Easy schema versioning.
- Straightforward validation.
- Easy to export.

Weaknesses:

- Large diffs as the project grows.
- Merge conflicts likely when multiple branches change work state.
- Harder to review small work item changes.

Fit:

- Good bootstrap option for small projects.
- Risky as the primary long-term store for growing work products.

### Option B: One JSON File Per Work Item

Store each work item as a separate JSON file.

Example:

```text
.airframe/state/epics/EP-020.json
.airframe/state/sprints/SP-025.json
.airframe/state/tasks/T-0116.json
.airframe/state/issues/I-0007.json
.airframe/state/requirements/REQ-0001.json
```

Strengths:

- Good Git diffs.
- Better merge behavior than a single file.
- Human inspectable.
- Scales with project size.
- Natural fit for stable IDs.
- Works well with generated indexes.

Weaknesses:

- Requires index generation or directory scanning.
- Multi-record transactions need care.
- Relationship validation must be explicit.

Fit:

- Strong candidate for Version 1.0.

### Option C: Folder Per Work Item With Record And Artifacts

Store each work item in a folder containing structured state and related local artifacts.

Example:

```text
.airframe/state/tasks/T-0116/record.json
.airframe/state/tasks/T-0116/evidence/EV-0001.json
```

Strengths:

- Organizes evidence and attachments near records.
- Scales well for large work items.
- Friendly to generated reports.

Weaknesses:

- More filesystem complexity.
- More paths to manage.
- May be heavier than needed for Version 1.0.

Fit:

- Good future option for evidence-heavy projects.
- May be more structure than required initially.

### Option D: YAML Files

Use YAML instead of JSON for canonical records.

Strengths:

- More human-friendly than JSON.
- Supports comments in common tooling.

Weaknesses:

- Parser behavior can vary.
- More ambiguous data model.
- Swift standard tooling is weaker than JSON Codable.
- Comments complicate round-trip editing.

Fit:

- Attractive for human editing, weaker for canonical machine state.

### Option E: SQLite Database Checked Into Repo

Store canonical workflow state in a SQLite file committed to the repo.

Strengths:

- Strong query capability.
- Transaction support.
- Relationship constraints possible.
- Efficient for large projects.

Weaknesses:

- Poor Git diffability.
- Merge conflicts are difficult.
- Harder for humans to inspect.
- Binary database history is less reviewable.

Fit:

- Useful as a cache or derived index.
- Weak fit for canonical repo-coupled state.

### Option F: GitHub Issues Or Projects As Canonical

Use GitHub as canonical project state.

Strengths:

- Existing issue tracking.
- Remote collaboration.
- Labels and comments provide visible workflow.

Weaknesses:

- State does not naturally travel with forks, local branches, or offline work.
- Reverts and checkouts do not restore project state.
- Requires network and credentials.
- External mutation can drift from code.

Fit:

- Good integration target.
- Poor canonical store for Airframe's repo-coupled requirement.

### Option G: Hybrid Canonical JSON Plus Generated Markdown

Use structured JSON records as canonical state and generate Markdown docs from them.

Strengths:

- Preserves human-readable documentation.
- Keeps machine state structured.
- Supports deterministic reports.
- Allows existing docs migration.

Weaknesses:

- Requires projection tooling.
- Generated files can drift if manually edited unless protected.
- Need clear authority rules.

Fit:

- Strong architecture direction.

## 4. Preliminary Recommendation

Use **Option B: one JSON file per work item**, combined with **Option G: generated Markdown projections**.

Recommended structure:

```text
.airframe/state/
  workspace.json
  projects/
    PRJ-AIRFRAME.json
  epics/
    EP-020.json
  sprints/
    SP-025.json
  tasks/
    T-0116.json
  issues/
    I-0007.json
  requirements/
    REQ-0001.json
  evidence/
    EV-0001.json
  workflows/
    epic.json
    sprint.json
    task.json
    issue.json
    release-candidate.json
  indexes/
    generated/
```

Generated Markdown can remain under `docs/` or move to a generated documentation subtree, pending decision.

## 5. Open Decisions

1. Should canonical records live under `.airframe/state/` or a visible `airframe/` directory?
2. Should generated Markdown overwrite current `docs/Tasks`, `docs/Issues`, `docs/Sprints`, and `docs/Epics`, or be generated into `docs/generated/` first?
3. Should evidence summaries be separate records or embedded in work items?
4. Should a SQLite cache be generated for query acceleration later?
5. How should merge conflict repair be represented in AgileCockpit?

## 6. Version 1.0 Recommendation

For Version 1.0:

- Use JSON Codable records.
- Store one file per canonical record.
- Generate Markdown projections.
- Generate indexes from records.
- Keep GitHub as optional integration state.
- Keep CI as optional evidence provider.
- Do not use SQLite as canonical storage.
- Do not use GitHub Issues as canonical storage.

