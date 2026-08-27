# Audit Guidelines

## Definitions and purpose

An **Audit** is Phase 1 of the Audit cycle: a complete, read-only examination of Airframe's canonical Agile state and its documentation and backend projections. It identifies stale, missing, misplaced, contradictory, unclear, or non-deterministic records without repairing them.

An **Audit cycle** has three phases:

1. Audit Findings
2. User Rulings
3. Remediation

An **Audit Check** is a lightweight, read-only mechanical review performed before Epic closure. It is not a full Audit and does not automatically create an Audit cycle.

Audits operate on the four Agile Artifact layers. They are not a fifth tracking layer. The formal scope includes:

- AirframeCore workflow policy and canonical schema behavior.
- Workspace and project records needed to interpret Agile state.
- Canonical Epic, Sprint, Task, and Issue records under `.airframe/state/`.
- Acceptance criteria, evidence, workflow, transition, and backend-mapping records referenced by those Agile Artifacts.
- Deterministic Markdown projections under `docs/generated/`.
- Compatibility, historical, and human-readable tracking documents under `docs/Issues/`, `docs/Tasks/`, `docs/Sprints/`, and `docs/Epics/`.
- Live GitHub Issues, labels, and relationships when live access is available.

Tests, test runs, plans, plan decisions, requirements, and other canonical record types enter scope when they are referenced by audited acceptance criteria or evidence. They are not otherwise audited exhaustively.

## Canonical authority and audited surfaces

For Audit fact-finding, use this authority order:

1. AirframeCore workflow policy, schema, authority evaluation, and diagnostics define valid structure and transitions.
2. `.airframe/state/` is the authoritative repository-coupled Agile state.
3. `docs/generated/` is a deterministic projection of canonical state.
4. Legacy and human-facing tracking documents are compatibility, historical, or summary surfaces.
5. GitHub is an external synchronization surface unless the applicable approved workspace design explicitly makes it authoritative for a fact.

A disagreement must identify which surface drifted. Do not describe canonical state, generated output, legacy Markdown, and GitHub as equally authoritative records of truth.

Use these surface names consistently:

- **Canonical**: structured records under `.airframe/state/` interpreted through AirframeCore.
- **Generated**: deterministic Markdown under `docs/generated/`.
- **Legacy**: working, index, and archive Markdown under the four `docs/` tracking directories.
- **Backend**: GitHub Issues, labels, relationships, and mappings.

## Prime rule: an Audit changes nothing

Phase 1 produces exactly one artifact: `Audit-Findings-YYYYMMDD.md`. It does not fix what it finds.

An auditor may:

- Read every file in scope.
- Run read-only searches, diffs, counts, history inspection, and other diagnostics.
- Create and incrementally write the findings file in `docs/Audits/`.
- Recommend changes, including changes to Guidelines files.

An auditor must not:

- Edit, create, move, or delete canonical state, generated output, a tracking document, or backend state outside the findings file.
- Change a status, count, date, assignment, or archive.
- Mark anything Verified or Closed.
- Apply an apparently obvious fix.

Phase 2 also changes no tracking documents. Only Phase 3 may apply fixes, and it may do so only from an approved Rulings artifact.

## Authorization and phase gates

A full Audit begins only when the user explicitly requests it. If Codex notices drift during other work, Codex may recommend an Audit but must not begin one without authorization.

Each phase must complete before the next begins:

| Phase | Artifact | Decision authority | Changes tracking documents? |
| --- | --- | --- | --- |
| 1. Audit | `Audit-Findings-YYYYMMDD.md` | Codex observes | No |
| 2. Rulings | `Audit-Rulings-YYYYMMDD.md` | User rules; Codex records | No |
| 3. Remediation | `Audit-Remediation-YYYYMMDD.md` and approved fixes | Codex applies rulings | Yes |

The phase gates carry verification:

- The user's authorization to begin Rulings verifies the Findings artifact.
- The user's authorization to begin Remediation verifies the Rulings artifact.
- Codex marks Remediation `Complete - Not Closed` after all rulings are applied or explicitly deferred and the log is mechanically checked.
- The user reviews the remediation log and closes the Audit cycle through AgileCockpit.

Codex must not close an Audit cycle. If AgileCockpit does not expose an Audit-close action, Codex reports the capability gap and leaves the cycle `Complete - Not Closed`.

## Phase 1: Audit

### Audit order

Audit from authority to projection. A later surface is checked against the earlier authoritative source; it does not redefine that source.

#### 1. Policy, schema, and Guidelines

1. This `docs/Audits/Audit-Guidelines.md`.
2. The applicable AirframeCore workflow policy, canonical record definitions, authority rules, validators, and projector behavior.
3. `docs/Issues/Issue-GUIDELINES.md`.
4. `docs/Tasks/Task-Guidelines.md`.
5. `docs/Sprints/Sprint-GUIDELINES.md`.
6. `docs/Epics/Epic-GUIDELINES.md`.

#### 2. Canonical diagnostics and inventory

1. Run configuration and canonical-state diagnostics through AICockpit in read-only mode.
2. Inventory `.airframe/state/workspaces/` and `.airframe/state/projects/`.
3. Inventory canonical Epics, Sprints, Tasks, and Issues.
4. Inventory the acceptance criteria, evidence, workflow, transition, and backend-mapping records referenced by those artifacts.
5. Inventory referenced requirements, tests, test runs, plans, or decisions only as needed to validate acceptance evidence.

Normal read-only commands include:

```sh
swift run --package-path AICockpit aicockpit context \
  --config .airframe/airframe-workspace.json

swift run --package-path AICockpit aicockpit config diagnose \
  --config .airframe/airframe-workspace.json --output json

swift run --package-path AICockpit aicockpit state diagnostics \
  --config .airframe/airframe-workspace.json --backend canonical --output json

swift run --package-path AICockpit aicockpit project summary \
  --config .airframe/airframe-workspace.json --backend canonical --output json
```

If a command's supported arguments differ in the current AICockpit version, inspect its help and use the equivalent read-only form. Do not run `state repair`, export, regeneration, or any mutation during Phase 1.

#### 3. Canonical relationship and lifecycle checks

Validate IDs, statuses, project pointers, parent-child links, acceptance criteria, evidence, and workflow transitions against canonical policy and records before reading their projections.

#### 4. Generated projections

1. Inventory `docs/generated/Epics/`, `docs/generated/Sprints/`, `docs/generated/Tasks/`, and `docs/generated/Issues/`.
2. Inspect generated requirements and traceability documents referenced by audited acceptance evidence.
3. Compare every expected projection with its canonical owner.
4. Identify projections without canonical owners and canonical records without required projections.

Do not regenerate projections during Phase 1 unless a supported comparison command is demonstrably read-only and writes only to a disposable location outside the repository. Otherwise record the suspected drift for Phase 3.

#### 5. Legacy and human-facing Markdown

Read every file under `docs/Issues/`, `docs/Tasks/`, `docs/Sprints/`, and `docs/Epics/`, including Guidelines, indexes, working files, archives, and orphans. Compare their factual claims with canonical state. Archives are historical surfaces, not an automatic record of truth.

For every loose Sprint or other orphan file, establish whether it is a duplicate, draft, historical record, or sole surviving noncanonical content. Do not assume.

#### 6. Backend synchronization

When live GitHub access is available, compare established status labels, relationships, evidence comments, and backend mappings with canonical state. Fixture-backed behavior is not evidence of live GitHub state.

If live access is unavailable, complete the canonical and local-projection portions of the Audit, record Backend verification as a scope limitation, and do not classify inaccessible remote data as missing or contradictory.

#### 7. Prior Audits

Read prior Findings, Rulings, and Remediation artifacts, especially deferred work, deviations, and recurring findings.

### Finding classifications

Every finding has exactly one primary kind:

| Kind | Definition | Typical example |
| --- | --- | --- |
| Canonical | Canonical data violates schema, policy, authority, or an invariant | Active Sprint pointer targets a non-Active record |
| Projection | Generated output differs from its canonical owner or is not deterministic | Generated Task status is stale |
| Legacy | Compatibility or human-facing Markdown differs from canonical state | Legacy index says a closed Sprint is Active |
| Backend | GitHub or a backend mapping differs from canonical state | GitHub status label is stale |
| Missing | A required canonical record, projection, relationship, or evidence record does not exist | Acceptance evidence ID does not resolve |
| Misplaced | A record exists in the wrong canonical directory or documentation surface | An Issue record is stored under Tasks |
| Contradiction | Sources within the same authority surface assert incompatible facts | Project pointer and canonical Sprint relationship disagree |
| Guidelines | A governing rule is wrong, unclear, incomplete, or unfollowed | A checklist treats generated Markdown as authoritative |

### Required checks

At minimum, perform these checks:

1. Run canonical diagnostics and record every reported invariant or reconciliation problem.
2. Confirm exactly one canonical record exists for each Agile Artifact ID and that filename, embedded ID, and kind agree.
3. Confirm every status is valid for its artifact kind and every recorded transition is permitted by AirframeCore policy.
4. Confirm active Epic and Sprint pointers resolve to canonical Active records and that at most one of each is active for the project.
5. Validate reciprocal Epic-Sprint-Task-Issue relationships and identify unresolved owners or children.
6. Confirm closed parents do not own impermissibly open work.
7. Resolve every acceptance-criterion and evidence reference required by the audited Agile Artifacts.
8. Re-derive counts from canonical records and compare them with AICockpit summaries, generated projections, legacy statistics, and available backend summaries.
9. Enumerate every issued I/T/SP/EP ID from 1 through the highest issued ID. Classify absence as a finding only when no canonical record, explicit skip, supersession, or other approved accounting exists.
10. Confirm every required canonical record has the expected generated projection and every projection has a canonical owner.
11. Compare generated content with canonical values and check that projection rules are deterministic.
12. Compare every repeated legacy or backend claim with canonical state, preserving the distinction between historical narrative and current status.
13. Identify orphan files and records not named or permitted by the applicable schema or Guidelines.
14. Check prior Audit artifacts for deferred or recurring findings.
15. Record relevant working-tree state when it affects whether canonical records or projections are partially edited.

### Severity

- **Critical**: Acting on the record would produce a materially wrong decision, or a record appears lost.
- **Moderate**: A contradiction or stale statement is materially misleading but not destructive.
- **Minor**: Cosmetic drift, count drift, or formatting that does not alter a decision.

### Findings artifact

Name the artifact `docs/Audits/Audit-Findings-YYYYMMDD.md`.

Required structure:

```markdown
# Documentation Audit — YYYY-MM-DD

**Scope:** [what was examined]
**Method:** [read-only method and how counts were derived]
**Result:** N findings — X Critical, Y Moderate, Z Minor

## Summary table
| # | Layer | File | Kind | Severity | One-line finding |

## Findings
### F-NN — [title]
**Layer / File / Kind / Severity**
**What is there:** [current text]
**What is true:** [verified fact and method]
**Authoritative source:** [canonical record, policy, or approved design]
**Affected surfaces:** [Canonical / Generated / Legacy / Backend]
**Diagnostic method:** [AICockpit command, record comparison, count, or history]
**Repair layer:** [where Phase 3 should act]
**Why it matters:** [consequence]
**Options:** [defensible fixes, not a decision]

## Guidelines recommendations
## Systemic observations
## Open questions for the user
```

Each finding must be independently checkable. Cite `file:line` for Markdown or source and the canonical record path and field for structured state. State how the fact was established. Number findings `F-01`, `F-02`, and so on within that Audit. Findings do not receive Issue or Task IDs unless the user rules that tracked work should be created.

Write the Findings artifact as the Audit proceeds so an interrupted Audit can be resumed. Do not claim the phase is complete until every required file and check has been covered.

## Phase 2: Rulings

Name the artifact `docs/Audits/Audit-Rulings-YYYYMMDD.md`, using the same date as the Findings artifact.

Rulings correspond one-to-one with findings: `R-07` rules on `F-07`. A finding requiring no action still receives a ruling. Guidelines recommendations and open questions follow the findings and are numbered `R-G1`, `R-G2`, and `R-Q1`, `R-Q2`.

### Rulings session procedure

1. Present findings one at a time, in order.
2. State what exists, what is true, why it matters, and the defensible options.
3. Give Codex's recommendation and reasoning. A recommendation is not a ruling.
4. The user rules.
5. Record the ruling immediately before presenting the next finding.
6. Flag any conflict with an earlier ruling before recording an incompatible instruction.

On resume, read the Rulings artifact, locate the highest completed ruling, and continue with the next item. Do not re-litigate completed rulings unless the user asks.

Required entry format:

```markdown
### R-NN — [finding title]
**Rules on:** F-NN · **Severity:** [carried from finding]
**Ruling:** [user's decision]
**Rationale:** [user's reasoning, when supplied]
**Action:** [what Remediation must do; none is valid]
**Status:** Ruled - Not Applied
**Date:** YYYY-MM-DD
```

A ruling may defer work or create an Issue or Task. Record any new ID so the finding and tracked work remain connected. Do not apply fixes during the Rulings session.

## Phase 3: Remediation

Remediation works only from the user-verified Rulings artifact. Every change must cite its ruling number.

Name the log `docs/Audits/Audit-Remediation-YYYYMMDD.md`, using the same date as the Findings and Rulings artifacts. Write it incrementally as work proceeds.

Required structure:

```markdown
# Audit Remediation — YYYY-MM-DD

**Applies:** Audit-Rulings-YYYYMMDD.md (N rulings)
**Status:** In Progress | Complete - Not Closed | Closed

## Progress
| Rulings applied | n of N |
| Session status | [where work stopped and what is safe next] |

## Ordering constraints observed
[constraints from the Rulings artifact]

## Applied
### R-NN — [title]
**Files changed:** [paths]
**What was done:** [actual change]
**Deviations:** [none, or exact deviation and reason]
**Verification:** [grep, count, diff, test, or other evidence]
**Status:** Applied - Not Verified

## Not applied / deferred
[ruling, reason, and outstanding action]
```

Rules for Remediation:

- Apply rulings in an order that preserves recorded dependencies and consistency.
- Repair the earliest authoritative layer responsible for the defect; do not patch a downstream projection to hide an upstream error.
- Repair invalid canonical state through AirframeCore, AICockpit, or AgileCockpit operations permitted by the authority rules. Do not hand-edit canonical JSON unless a ruling explicitly authorizes that exceptional recovery path.
- For projector defects, repair projector behavior and then regenerate affected output.
- For stale generated output, regenerate it from canonical state. Never hand-edit generated Markdown.
- For Legacy drift, update or retire the Legacy surface exactly as ruled.
- For Backend drift, use established synchronization operations and record the resulting labels, relationships, mappings, or comments.
- Workflow-policy changes require explicit user authorization and may not be inferred from a remediation ruling that merely reports bad data.
- Write each log entry before moving to the next ruling.
- Record deviations and failures honestly.
- Verify each ruling mechanically where possible.
- Do not expand a ruling's scope without new user authorization.
- Preserve all three Audit artifacts after completion.
- Treat a finding recurring across Audit cycles as a systemic Guidelines problem, not merely a clerical repair.

Every remediation entry must identify the authoritative source repaired, all derived surfaces regenerated or synchronized, and the checks used to confirm agreement. Codex marks the cycle `Complete - Not Closed` only when every ruling is applied or explicitly deferred, the log is current, and the required checks pass. Only the user closes the Audit cycle through AgileCockpit.

## Audit Check

An Audit Check is the lightweight alternative to a full Audit. It is performed before an Epic close and may also be explicitly requested at any time.

| Attribute | Audit | Audit Check |
| --- | --- | --- |
| Trigger | Explicit user request only | Before Epic close or explicit request |
| Scope | Canonical Agile state and every applicable projection surface | Mechanical checks below |
| Method | Policy and canonical validation, projection comparison, judgment, counts, and history | Canonical diagnostics and direct comparisons |
| Output | Findings artifact and full Audit cycle | Short disposition list in Epic-close review |
| Rulings | Dedicated Phase 2 | Part of Epic-close review |

### Required Audit Check checks

1. Canonical diagnostics pass, or every relevant diagnostic has an explicit disposition.
2. The canonical Epic is Complete and its acceptance-criterion states satisfy the close policy.
3. Every related Sprint has the canonical status required for Epic closure.
4. Every related Task and Issue has the required human-verified canonical status.
5. Every acceptance-criterion and evidence reference resolves to the required canonical record.
6. Active Epic and Sprint project pointers agree with canonical state.
7. Canonical counts agree with the AICockpit project summary.
8. Required generated Epic, Sprint, Task, Issue, and traceability projections exist and agree with canonical state.
9. Legacy tracking documents do not assert a conflicting current status that would mislead closeout review.
10. Backend mappings and live GitHub state agree when live access is available; otherwise the limitation is stated.
11. Orphan files and ID-continuity gaps have an approved accounting.

### Audit Check disposition

The Audit Check changes nothing. Present every inconsistency during Epic-close review and record one disposition:

- Corrected under a separately authorized action.
- Deferred with rationale.
- Converted into a tracked Issue or Task.
- Escalated to a recommendation for a full Audit.

An unresolved inconsistency that undermines the Epic's completion or acceptance evidence blocks closure. Minor unrelated drift may be deferred only when the user explicitly rules it so. A large, recurring, or systemic inconsistency is grounds to recommend a full Audit, which still begins only when the user explicitly requests it.

## Cadence

- Full Audit: only upon explicit user request.
- Audit Check: before Epic closure or upon explicit user request.
