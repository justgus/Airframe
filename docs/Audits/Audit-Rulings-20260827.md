# Documentation Audit — Rulings — 2026-08-27

**Rules on:** `Audit-Findings-20260827.md` — 17 findings, 5 Guidelines recommendations, and 3 open questions.
**Findings verified by:** User authorization to begin the Rulings session on 2026-08-27.
**Status:** Rulings in progress.

## Progress

| Category | Complete | Total |
| --- | --- | --- |
| Findings | 8 | 17 |
| Guidelines recommendations | 0 | 5 |
| Open questions | 0 | 3 |

**Next item:** F-09

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
