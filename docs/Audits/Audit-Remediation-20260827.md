# Audit Remediation — 2026-08-27

**Applies:** `Audit-Rulings-20260827.md` (25 rulings: 17 findings, 5 Guidelines recommendations, 3 open questions)
**Authorization:** Documentation remediation authorized by the user on 2026-08-27.
**Scope boundary:** Apply documentation and documentation-process rulings now. Record required AirframeCore, AICockpit, AgileCockpit, canonical-data, projector, importer, and backend work as system gaps; do not implement that product work or mutate canonical/backend state under this authorization.
**Status:** In Progress

## Progress

| Rulings applied | 10 of 25 |
| --- | --- |
| Session status | Documentation remediation and SP-038 canonical-integrity remediation are applied and mechanically checked. Full Audit remediation remains In Progress pending later Sprints. |

## Ordering constraints observed

1. Repair canonical policy and system behavior before canonical data that depends on the new policy.
2. Repair projector/importer behavior before regenerating derived Markdown.
3. Do not hand-edit generated Markdown.
4. Preserve user-owned edits in Legacy Issue and GitHub-mapping documents.
5. Synchronize GitHub only after canonical state and reconciliation behavior are correct and live access is available.
6. Never represent the R-03 historical disposition as ordinary human verification.

## Agile Airframe system-change and capability-gap register

| Gap | Components | Rulings | Required capability or change | Documentation-remediation disposition |
| --- | --- | --- | --- | --- |
| AF-GAP-01 | AirframeCore, AICockpit | R-01, R-02 | Supported canonical relationship repair for duplicate project membership and missing reciprocal Epic-Issue links. | Implemented by SP-038; pending human verification. |
| AF-GAP-02 | AirframeCore, AICockpit, AgileCockpit | R-03, R-G3, R-Q1, R-16 | A provenance-preserving historical-close acceptance disposition, migration operation, validation, reporting, and human review UI. | Implemented and migrated by SP-038; pending human verification. |
| AF-GAP-03 | AirframeCore configuration, AICockpit, AgileCockpit | R-04 | Remove duplicated active Epic/Sprint configuration pointers and resolve active context exclusively from canonical project state. | System/config migration deferred. |
| AF-GAP-04 | AirframeCore Markdown projector, AICockpit | R-05, R-06, R-07 | Durable projection refresh after canonical mutation, artifact-specific Issue terminology, populated relationship statuses, complete regeneration, and regression coverage. | Generated files remain untouched; implementation deferred. |
| AF-GAP-05 | AICockpit GitHub backend | R-10, R-G4 | Complete pagination plus explicit completeness, limit, retrieved-count, continuation, and failure metadata for every list/summary contract. | Backend implementation deferred. |
| AF-GAP-06 | AirframeCore backend policy, AICockpit, AgileCockpit | R-11 | Canonical/backend status reconciliation that can synchronize an already human-Verified state without granting agents verification authority. | GitHub synchronization deferred; live access unavailable. |
| AF-GAP-07 | AirframeCore requirement importer, AICockpit | R-12 | Correct source-section boundary parsing, controlled re-import/repair, source comparison, and projection regeneration. | Canonical/importer work deferred. |
| AF-GAP-08 | AirframeCore diagnostics, AICockpit | R-01, R-02, R-03, R-16 | Stable invariant diagnostics for uniqueness, reciprocal relationships, and lifecycle/acceptance consistency, including migration-aware valid cases. | Implemented by SP-038; pending human verification. |
| AF-GAP-09 | AirframeCore schema, AICockpit, AgileCockpit | R-14, R-G5, R-Q2 | Explicit optional backend-mapping states: backend not configured, intentionally local, pending, mapped, and error. | Guidelines updated; schema, UI, and classification of 26 records deferred. |
| AF-GAP-10 | AirframeCore projector, AICockpit, AgileCockpit | R-08, R-09, R-13, R-15, R-G2, R-Q3 | Deterministic current-state indexes or durable redirects for retained Legacy paths, with historical archives clearly distinguished. | Guidelines updated; replacement of user-edited Legacy files deferred. |
| AF-GAP-11 | AICockpit, AgileCockpit workspace management | R-17 | Declare which `.airframe` outputs are canonical, durable cache, or disposable runtime state; provide stable locations/names so repositories can ignore only transient output. | No untracked `.airframe` output exists in the current tree; targeted ignore patterns deferred until classification exists. |
| AF-GAP-12 | AICockpit work tracking | R-07 | Create and link a tracked investigation for the original relationship-status omission and systemic projector implications. | Work-item creation deferred under the documentation-only boundary. |

## Applied

### R-01, R-02 — Canonical membership and reciprocal Issue relationships

**Files changed:** canonical PRJ-AIRFRAME, EP-017, and I-0001 through I-0004 records; AirframeCore repair and diagnostic support
**What was done:** Used supported AICockpit repair operations to remove duplicate Task/Issue project membership and restore the four missing EP-017 reverse Issue links.
**Deviations:** None. Generated Markdown was not hand-edited.
**Verification:** Post-repair canonical diagnostics contain zero findings; EV-0167-001 records the repair inventory.
**Status:** Applied - Not Verified

### R-03, R-G3, R-Q1 — Historical-close acceptance provenance

**Files changed:** AirframeCore acceptance models and migration service, AICockpit migration interface, AgileCockpit presentation, and 42 canonical acceptance records owned by EP-001 through EP-008
**What was done:** Added a historical-close disposition distinct from human verification, constrained it to the approved closed Epics, migrated exactly 42 eligible records, and prevented its use for current or future Epic close eligibility.
**Deviations:** None. The migration was applied through AICockpit; direct canonical fallback was used only for evidence records.
**Verification:** A repeated migration changed zero records; Core, CLI, and app verification are recorded by EV-0166-001 and EV-0168-001.
**Status:** Applied - Not Verified

### R-16 — Systematic canonical invariant diagnostics

**Files changed:** `AirframeCore/Sources/AirframeCore/CanonicalDiagnostics.swift`, AICockpit help/reporting, and regression tests
**What was done:** Added stable diagnostics and supported repairs for duplicate membership, reciprocal Task/Issue relationships, and lifecycle/acceptance consistency.
**Deviations:** None.
**Verification:** AirframeCore and AICockpit tests pass; the live canonical diagnostic report is clean.
**Status:** Applied - Not Verified

### R-13 — Artifact Guidelines use canonical-first procedures

**Files changed:** `docs/Issues/Issue-GUIDELINES.md`, `docs/Tasks/Task-Guidelines.md`, `docs/Sprints/Sprint-GUIDELINES.md`, `docs/Epics/Epic-GUIDELINES.md`
**What was done:** Reframed all four Guidelines around AirframeCore and `.airframe/state/` authority; identified AICockpit and AgileCockpit mutation boundaries; prohibited hand-editing generated output; classified Legacy and backend surfaces; and replaced Markdown-first transition checklists.
**Deviations:** None for the Guidelines rewrite. Replacement of Legacy files themselves remains governed by R-08, R-09, and AF-GAP-10.
**Verification:** Targeted searches for former mandatory-mapping and Markdown-first instructions; link and terminology checks recorded below.
**Status:** Applied - Not Verified

### R-15 — Sprint Backlog and Planning routing

**Files changed:** `docs/Sprints/Sprint-GUIDELINES.md`
**What was done:** Added `Sprint-backlog.md` to the documented layout; assigned Backlog and Planning to that compatibility projection and Active and Review to `Sprint-active.md`; prohibited treating either as a mutation authority.
**Deviations:** None.
**Verification:** Targeted path/status search recorded below.
**Status:** Applied - Not Verified

### R-17 — Repository hygiene

**Files changed:** `.gitignore`; removed `docs/Epics/.DS_Store`
**What was done:** Added repository-wide `*~` backup-file exclusion; retained the existing `.DS_Store` exclusion; removed the audited orphan. Inventoried `.airframe` untracked output and found none, so no speculative `.airframe` pattern was added.
**Deviations:** The requested `.airframe` ignore coverage produced no safe pattern because every present file is tracked and no untracked tool output exists. AF-GAP-11 records the required product classification capability.
**Verification:** `git status --short --untracked-files=all -- .airframe` returned no entries; `test ! -e docs/Epics/.DS_Store` confirmed the ignored, untracked metadata file is absent. Because it was not tracked, Git cannot restore it; Finder can regenerate it if needed.
**Status:** Applied - Not Verified

### R-G1 — Audit and authority cross-references

**Files changed:** all four Artifact Guidelines
**What was done:** Added concise links to `docs/Audits/Audit-Guidelines.md` and its canonical authority order and phase gates.
**Deviations:** None.
**Verification:** Link-target and occurrence checks recorded below.
**Status:** Applied - Not Verified

## Not applied / deferred

- R-04 through R-07: configuration and projector work remains assigned to later remediation Sprints.
- R-08 and R-09: policy can be documented now, but replacing current Legacy files is deferred because deterministic projection/redirect support is an Airframe gap and `docs/Issues/Issue-Documentation.md` plus `docs/Issues/Issue-backlog.md` contain pre-existing user edits.
- R-10 through R-12: backend and canonical/importer implementation is deferred.
- R-11: GitHub synchronization is deferred; `api.github.com` was unreachable at remediation start.
- R-14 data classification: mapping policy can be documented now; canonical schema/UI work and classification of the 26 records are deferred.
- R-17 `.airframe` patterns: no untracked `.airframe` files were present at remediation start. Tracked canonical/configuration files and tracked Cockpit caches must not be hidden by a blanket ignore.

## Mechanical verification

- `git diff --check` passes.
- All four Artifact Guidelines link to `docs/Audits/Audit-Guidelines.md`.
- Searches find no remaining mandatory `Every Airframe Issue/Task must` GitHub-mapping rule in the four Guidelines.
- Searches find no former Markdown-first update instruction in the four Guidelines.
- Sprint Guidelines name `Sprint-backlog.md` and map Backlog/Planning separately from Active/Review.
- `.gitignore` contains `.DS_Store` and `*~`; `docs/Epics/.DS_Store` is absent.
- No untracked `.airframe` file was present to justify a targeted ignore pattern.
- Pre-existing user edits in `docs/GitHub-Issue-Mapping.md`, `docs/Issues/Issue-Documentation.md`, and `docs/Issues/Issue-backlog.md` were not overwritten.
