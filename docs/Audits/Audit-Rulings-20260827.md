# Documentation Audit — Rulings — 2026-08-27

**Rules on:** `Audit-Findings-20260827.md` — 17 findings, 5 Guidelines recommendations, and 3 open questions.
**Findings verified by:** User authorization to begin the Rulings session on 2026-08-27.
**Rulings verified by:** User authorization to begin documentation remediation on 2026-08-27.
**Status:** Rulings verified — documentation Remediation authorized.

## Progress

| Category | Complete | Total |
| --- | --- | --- |
| Findings | 17 | 17 |
| Guidelines recommendations | 5 | 5 |
| Open questions | 3 | 3 |

**Next item:** Documentation Remediation in progress

## Rulings

### R-01 — Project membership arrays contain 47 duplicate references

**Rules on:** F-01 · **Severity:** Moderate
**Ruling:** Option 2 — deduplicate the canonical project membership arrays and add canonical validation preventing duplicate membership.
**Rationale:** Canonical membership must itself be valid; downstream consumers must not be required to compensate for duplicate canonical references.
**Action:** Remove the duplicate T-0001–T-0045, I-0007, and I-0008 references from `PRJ-AIRFRAME`; add AirframeCore canonical diagnostics and regression coverage for duplicate project membership references.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-02 — I-0001–I-0004 are absent from EP-017's reciprocal Issue links

**Rules on:** F-02 · **Severity:** Moderate
**Ruling:** Option 1 — add I-0001–I-0004 to EP-017's canonical `issueIDs`.
**Rationale:** The four Issue owner fields and SP-017 relationship agree; EP-017's empty reverse list is the isolated defect.
**Action:** Reconcile EP-017's canonical Issue relationships to include I-0001, I-0002, I-0003, and I-0004, preserving bidirectional relationship invariants.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-03 — Eight Closed Epics own 42 unverified acceptance criteria

**Rules on:** F-03 · **Severity:** Critical
**Ruling:** Option 3 — add an explicit grandfathered historical-close disposition distinct from Verified for the 42 acceptance criteria owned by EP-001–EP-008.
**Rationale:** Preserve the truth that the Epics were human-closed without inventing criterion-level verification evidence that was never recorded.
**Action:** Define a canonical migration disposition for historical acceptance criteria; apply it to the 42 affected criteria; update close validation, reporting, projection, and regression coverage so the disposition is recognized but never represented as ordinary human verification.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-04 — Workspace configuration retains closed active pointers

**Rules on:** F-04 · **Severity:** Moderate
**Ruling:** Option 2 — remove active Epic and Sprint pointer fields from workspace configuration and use canonical project state exclusively.
**Rationale:** Active project pointers must have one mutable source; duplicate configuration state recreates the drift that canonical state is intended to prevent.
**Action:** Remove the active pointer fields from `.airframe/airframe-workspace.json`; update configuration models, consumers, documentation, and regression coverage so active pointers are read only from canonical project state.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-05 — Six generated Task projections are stale on verification

**Rules on:** F-05 · **Severity:** Moderate
**Ruling:** Option 3 — fix or verify the projection-refresh mechanism, then regenerate all generated Agile documentation from canonical state.
**Rationale:** Regeneration alone repairs the current files but does not establish that future canonical mutations will refresh projections durably.
**Action:** Diagnose and correct the canonical-to-Markdown refresh path as needed; add regression coverage for human verification refresh; regenerate the complete generated Epic, Sprint, Task, and Issue projection set; verify all projected primary statuses against canonical records.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-06 — Issue projections use Task-specific verification terminology

**Rules on:** F-06 · **Severity:** Minor
**Ruling:** Option 1 — render artifact-specific `Resolved` terminology for Issues and regenerate the Issue projections.
**Rationale:** The shared canonical enum is an implementation detail; human-facing output must preserve Airframe's established Issue vocabulary.
**Action:** Update the Markdown projector so Issue `implementedNotVerified` and `implementedVerified` render as `Resolved - Not Verified` and `Resolved - Verified`; regenerate all Issue projections and add regression coverage distinct from Task labels.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-07 — Generated Epic and Sprint relationship statuses are blank

**Rules on:** F-07 · **Severity:** Moderate
**Ruling:** Option 1 — populate every relationship Status cell from canonical state. Also open a tracked investigation into why the status values were omitted in the first place.
**Rationale:** Status is required context for Epic and Sprint review, and the omission may reveal a projector design or regression gap beyond the visible blank cells.
**Action:** Update the projector to resolve and render canonical statuses for every related Sprint, Task, and Issue; regenerate all affected projections; add regression coverage; and create a tracked investigation linked to F-07/R-07 covering the original omission's cause and any systemic projector implications.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-08 — Legacy Issue tracking is materially stale and incomplete

**Rules on:** F-08 · **Severity:** Critical
**Ruling:** Option 3 — retain historical Issue archives, but retire the mutable Legacy Issue working files and index as current-state authorities in favor of canonical generated views and AgileCockpit.
**Rationale:** Historical archives preserve useful narrative, while parallel mutable queues and indexes recreate the drift that canonical state was introduced to eliminate.
**Action:** Preserve and clearly mark historical Issue archives; retire or replace `Issue-active.md`, `Issue-backlog.md`, and `Issue-Documentation.md` with unambiguous redirects or generated canonical views; update all links, Guidelines, and procedures that treat those files as current state.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-09 — Legacy Task tracking assigns 20 Verified Tasks to earlier states

**Rules on:** F-09 · **Severity:** Critical
**Ruling:** Option 3 — retain historical Task archives, but retire the mutable Legacy Task working files and index as current-state authorities in favor of canonical generated views and AgileCockpit.
**Rationale:** Historical archives preserve useful narrative, while parallel mutable queues and indexes recreate the drift that canonical state was introduced to eliminate. This also keeps Task documentation consistent with the ruling for Legacy Issue documentation in R-08.
**Action:** Preserve and clearly mark historical Task archives; retire or replace `Task-backlog.md`, `Task-active.md`, `Task-unverified.md`, and `Task-Documentation.md` with unambiguous redirects or generated canonical views; update all links, Guidelines, and procedures that treat those files as current state.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-10 — GitHub-backed project summary truncates the Agile dataset at 100

**Rules on:** F-10 · **Severity:** Critical
**Ruling:** Option 3 — implement complete pagination, add explicit partial-result diagnostics as a safeguard, and distinguish GitHub-backed coverage from the complete canonical project inventory.
**Rationale:** Pagination repairs the immediate truncation defect; completeness metadata prevents silent recurrence; and backend totals must not imply coverage of canonical-only Epics, Sprints, or unmapped work.
**Action:** Update the GitHub backend summary path to traverse all result pages; expose the applied limit, pagination/completeness state, and a clear partial-result diagnostic whenever enumeration is incomplete; label backend counts as GitHub coverage rather than complete canonical inventory; add regression coverage with more than 100 work items.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-11 — Twenty-nine GitHub status labels disagree with canonical state

**Rules on:** F-11 · **Severity:** Critical
**Ruling:** Option 2 — synchronize the 29 stale GitHub status labels from canonical state and add reconciliation diagnostics for future canonical/backend disagreement.
**Rationale:** The corresponding records are already human-Verified canonically, so correcting established backend labels restores an existing accepted state rather than performing a new verification. Diagnostics should expose future drift without granting agents authority to initiate human-only verification.
**Action:** Synchronize the established GitHub workflow labels for the 29 affected Tasks and Issues to their canonical Verified state; add reconciliation diagnostics and regression coverage for canonical/backend status disagreement; preserve the rule that only prior human verification authorizes a Verified backend label.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-12 — Canonical requirement statements contain imported document structure

**Rules on:** F-12 · **Severity:** Critical
**Ruling:** Option 3 — fix the importer boundary logic, repair or re-import all 25 affected canonical records, mechanically compare every repaired statement with its source section, regenerate projections, and add section-boundary regression coverage.
**Rationale:** Remediation must correct both the contaminated canonical data and the mechanism that created it; source comparisons are required to ensure cleanup does not remove legitimate normative text.
**Action:** Correct requirement-import parsing so statements end at the proper source boundary; repair or re-import the 25 affected canonical requirements; compare each repaired statement with its authoritative source section; regenerate all affected requirement and traceability projections; add regression tests covering headings, separators, lists, and document-tail boundaries.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-13 — Artifact Guidelines still prescribe Markdown-first mutation

**Rules on:** F-13 · **Severity:** Moderate
**Ruling:** Option 2 — rewrite all four Artifact Guidelines as canonical-first procedures, clearly classifying canonical, generated, Legacy, and backend surfaces.
**Rationale:** Artifact-specific vocabulary and procedures remain useful, but their authority model must be coherent and must not direct agents to mutate downstream documentation as current state. The rewrite also supports R-08 and R-09 by removing procedural authority from retired Legacy working files.
**Action:** Rewrite the Issue, Task, Sprint, and Epic Guidelines so mutations enter through AirframeCore/AICockpit or an explicitly approved fallback; define `.airframe/state/` as canonical, generated Markdown as regenerated output, Legacy documents as compatibility or historical surfaces, and GitHub as a synchronization surface; update transition, file-layout, indexing, and archival procedures accordingly.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-14 — Mandatory GitHub mapping rules conflict with canonical/local operation

**Rules on:** F-14 · **Severity:** Moderate
**Ruling:** Option 1 — make GitHub mapping optional and define explicit mapping states that distinguish local operation from pending, successful, or failed synchronization.
**Rationale:** Optional mappings preserve Airframe's approved offline/local-only operation, while explicit states distinguish intentionally local records from incomplete or erroneous backend synchronization.
**Action:** Replace the mandatory one-GitHub-Issue rule in Task and Issue Guidelines with an optional mapping policy; define and implement mapping states for not configured, intentionally local, pending synchronization, mapped, and mapping error (or equivalent precise canonical values); update validation, diagnostics, projection, and regression coverage without creating GitHub Issues for the 26 currently unmapped records merely to satisfy the former rule.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-15 — Sprint Guidelines contradict the actual backlog layout

**Rules on:** F-15 · **Severity:** Minor
**Ruling:** Option 1 — document `Sprint-backlog.md`, route Backlog and pre-activation Planning Sprints there, and reserve `Sprint-active.md` for Active and Review current-work views.
**Rationale:** Planning remains pre-activation, so grouping it with Backlog preserves a clear lifecycle boundary before Active work. Under R-13, these Legacy files remain projections or compatibility views rather than mutation authorities.
**Action:** Add `Sprint-backlog.md` to the documented Sprint layout; define Backlog and Planning as its projected states and Active and Review as the `Sprint-active.md` projected states; align links, checklists, and canonical-first procedures with that routing.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-16 — Canonical diagnostics produce a false clean result

**Rules on:** F-16 · **Severity:** Critical
**Ruling:** Option 2 — add the missing rules within a systematic invariant-validation framework covering membership uniqueness, reciprocal relationships, lifecycle and acceptance consistency, stable diagnostic identifiers, and regression tests.
**Rationale:** Canonical diagnostics should establish meaningful consistency rather than only successful loading. The known failures should be handled by reusable invariant checks, with R-03's grandfathered historical-close disposition recognized as valid without being represented as ordinary verification.
**Action:** Extend AirframeCore canonical diagnostics with stable, testable invariant diagnostics for duplicate memberships, both directions of supported relationships, and lifecycle/acceptance consistency; incorporate the R-03 historical-close disposition into close validation; add regression fixtures for each valid and invalid case and ensure diagnostics no longer return a false clean result.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-17 — `.DS_Store` is an orphan in the Epic tracking directory

**Rules on:** F-17 · **Severity:** Minor
**Ruling:** Option 2, expanded — remove the orphan `.DS_Store`; ignore `.DS_Store` repository-wide; also ignore editor backup files such as `*~` and noncanonical untracked `.airframe` artifacts produced or updated by Airframe/AICockpit operation.
**Rationale:** Repository hygiene should prevent recurring Finder metadata, editor backups, and transient tool output from entering version control. Canonical `.airframe/state/` and configuration records must remain visible and must not be hidden by a blanket `.airframe/` ignore rule.
**Action:** Remove `docs/Epics/.DS_Store`; update repository ignore rules for `.DS_Store` and `*~`; inventory recurring untracked files produced or updated under `.airframe/` by Airframe/AICockpit, classify their authority and persistence requirements, and add narrowly targeted ignore patterns only for confirmed noncanonical transient outputs. Do not ignore `.airframe/` wholesale or conceal canonical state/configuration changes.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

## Guidelines recommendation rulings

### R-G1 — Cross-reference Audit procedure and canonical authority

**Rules on:** Guidelines recommendation 1
**Ruling:** Approved — extend all four Artifact Guidelines with a cross-reference to the Audit procedure and canonical authority order.
**Rationale:** Artifact-specific readers must reach the same governing authority hierarchy and three-phase Audit process without duplicating policy text that could drift.
**Action:** As part of the R-13 canonical-first rewrite, add concise cross-references from the Issue, Task, Sprint, and Epic Guidelines to `docs/Audits/Audit-Guidelines.md` and the governing canonical authority order.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-G2 — Define the supported role of Legacy indexes and working files

**Rules on:** Guidelines recommendation 2
**Ruling:** Approved — retire hand-maintained Legacy indexes and working queues as current-state authorities; preserve historical archives; permit Legacy-path current views only when deterministically generated from canonical state or implemented as unambiguous redirects.
**Rationale:** The hybrid role of manually maintained records that also claim to reflect canonical state is a primary source of drift. Historical narrative remains valuable, while current workflow state must have one canonical mutation path.
**Action:** Encode this policy in the canonical-first Artifact Guidelines and applicable documentation; prohibit workflow transitions through Legacy projections; implement R-08, R-09, R-13, and R-15 consistently with deterministic projections or redirects where Legacy paths remain.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-G3 — Define a historical acceptance migration disposition

**Rules on:** Guidelines recommendation 3
**Ruling:** Approved — define an explicit migration disposition for historical Closed Epics whose acceptance criteria predate canonical verification records, tied directly to R-03.
**Rationale:** Historical closure must remain internally consistent without fabricating criterion-level human verification, and the migration mechanism must not weaken acceptance requirements for current or future Epics.
**Action:** Define a disposition distinct from Verified and Unverified; restrict it to explicit historical migration conditions; preserve provenance that closure occurred without reconstructed criterion-level verification; permit it to satisfy historical close consistency only as specified; prohibit its use as a shortcut for newly closed Epics.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-G4 — Require backend pagination and partial-result disclosure

**Rules on:** Guidelines recommendation 4
**Ruling:** Approved — require pagination and explicit partial-result disclosure in every backend list or summary contract.
**Rationale:** Backend limits, failures, permission boundaries, or interrupted pagination must never be silently presented as complete project results.
**Action:** Require complete enumeration by default; when results are incomplete, expose partial status, applied limit, retrieved count, continuation state where applicable, and the reason for incompleteness; prohibit summary commands from presenting partial totals as complete project totals; apply the policy to R-10 and all backend implementations and contracts.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-G5 — Define optional GitHub mapping states

**Rules on:** Guidelines recommendation 5
**Ruling:** Approved — define optional GitHub mapping states compatible with local-only operation and aligned with R-14.
**Rationale:** Local-only and backend-unconfigured records are valid operating states, while pending or failed synchronization must remain distinguishable and diagnosable.
**Action:** Define canonical mapping states for backend not configured, intentionally local, pending synchronization, successfully mapped, and synchronization or mapping error (or equivalent precise values); update validation and diagnostics so valid local states pass while incomplete and failed synchronization are reported.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

## Open-question rulings

### R-Q1 — Historical Closed Epic acceptance disposition

**Rules on:** Open question 1
**Ruling:** Apply the distinct grandfathered historical-close disposition to the 42 acceptance criteria owned by EP-001–EP-008; do not reconstruct or claim individual human verification that was never recorded.
**Rationale:** This confirms R-03 and R-G3: preserve truthful historical closure and provenance without fabricating criterion-level acceptance evidence.
**Action:** Implement through R-03 and R-G3 with the recorded migration restrictions and validation behavior.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-Q2 — Optional GitHub mappings for local-only operation

**Rules on:** Open question 2
**Ruling:** Keep GitHub mappings optional under the local-only profile; do not create GitHub Issues for the 26 currently unmapped canonical Tasks and Issues merely because they lack mappings.
**Rationale:** This confirms R-14 and R-G5: backend-unconfigured and intentionally local records are valid, while incomplete or failed synchronization must be represented by distinct mapping states.
**Action:** Classify the 26 records under the explicit mapping-state model during remediation and create no backend artifacts absent a separate authorized reason.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27

### R-Q3 — Supported role of Legacy working and index documents

**Rules on:** Open question 3
**Ruling:** Retire hand-maintained Legacy working files and indexes as current-state authorities; preserve historical archives; where a Legacy path remains useful, replace it with a deterministic canonical projection or an unambiguous redirect to `docs/generated/` or AgileCockpit.
**Rationale:** This confirms R-08, R-09, and R-G2: current workflow state must have one canonical mutation path while historical narrative and stable compatibility paths may be preserved without becoming competing authorities.
**Action:** Apply the retirement, preservation, projection, and redirect policy consistently across Artifact Guidelines, links, working files, indexes, and archives during remediation.
**Status:** Ruled - Not Applied
**Date:** 2026-08-27
