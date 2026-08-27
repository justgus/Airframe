# Documentation Audit — 2026-08-27

**Scope:** AirframeCore workflow policy; `.airframe/state/` canonical workspace, project, Epic, Sprint, Task, Issue, acceptance-criterion, evidence, workflow, transition, and backend-mapping records; applicable `docs/generated/` projections; Legacy Agile Markdown under `docs/Issues/`, `docs/Tasks/`, `docs/Sprints/`, and `docs/Epics/`; live GitHub synchronization when available; and prior Audit artifacts.
**Method:** Read-only canonical diagnostics, structured-record enumeration, relationship and ID-continuity checks, canonical-to-generated and canonical-to-Legacy comparisons, filesystem inventory, targeted source inspection, and available live-backend inspection. Counts are independently derived rather than accepted from document summaries.
**Result:** 17 findings — 7 Critical, 7 Moderate, 3 Minor.
**Status:** Findings complete — awaiting user authorization to begin the Rulings session.

## Summary table

| # | Layer | Surface | Kind | Severity | One-line finding |
| --- | --- | --- | --- | --- | --- |
| F-01 | Project | Canonical | Canonical | Moderate | Project membership arrays contain 47 duplicate references. |
| F-02 | Epic / Issues | Canonical | Canonical | Moderate | I-0001–I-0004 point to EP-017, but EP-017 has no reciprocal Issue links. |
| F-03 | Epics / ACs | Canonical | Canonical | Critical | Eight Closed Epics own 42 acceptance criteria recorded as unverified. |
| F-04 | Workspace | Legacy configuration | Legacy | Moderate | Workspace configuration still points to closed EP-018 and SP-023 as active. |
| F-05 | Tasks | Generated | Projection | Moderate | T-0154–T-0159 projections say Not Verified although canonical state is Verified. |
| F-06 | Issues | Generated | Projection | Minor | All 30 Issue projections use the Task-specific “Implemented - Verified” label. |
| F-07 | Epics / Sprints | Generated | Projection | Moderate | 416 relationship-table status cells are blank. |
| F-08 | Issues | Legacy | Legacy | Critical | Legacy Issue records show 13 unresolved and omit four Issues although all 30 are canonically Verified. |
| F-09 | Tasks | Legacy | Legacy | Critical | Legacy Task records distribute 20 Tasks across non-Verified states although all 165 are canonically Verified. |
| F-10 | Project | Backend | Backend | Critical | GitHub-backed summary stops at 100 work items versus 256 canonical and 177 live Agile GitHub Issues. |
| F-11 | Tasks / Issues | Backend | Backend | Critical | Twenty-nine live GitHub status labels disagree with canonical Verified state. |
| F-12 | Requirements | Canonical / Generated | Canonical | Critical | Twenty-five canonical requirement statements contain imported section headings or unrelated document tails. |
| F-13 | Guidelines | Legacy | Guidelines | Moderate | Artifact Guidelines still direct Markdown-first mutation despite canonical-first authority. |
| F-14 | Tasks / Issues | Guidelines / Canonical | Guidelines | Moderate | Guidelines require a GitHub Issue for every Task and Issue, but 26 canonical records intentionally or actually lack one. |
| F-15 | Sprints | Guidelines / Legacy | Guidelines | Minor | Sprint Guidelines omit `Sprint-backlog.md` and direct backlog records into `Sprint-active.md`. |
| F-16 | Canonical diagnostics | Canonical | Guidelines | Critical | Canonical diagnostics report success while F-01, F-02, and F-03 remain present. |
| F-17 | Epics | Legacy | Misplaced | Minor | `docs/Epics/.DS_Store` is an orphan file in a tracking directory. |

## Findings

### F-01 — Project membership arrays contain 47 duplicate references

**Layer / File / Kind / Severity:** Project · `.airframe/state/projects/PRJ-AIRFRAME.json` · Canonical · Moderate
**What is there:** The project `taskIDs` array contains T-0001–T-0045 twice; the second run begins at `.airframe/state/projects/PRJ-AIRFRAME.json:482` after the first begins at line 305. The `issueIDs` array contains I-0007 twice at lines 102 and 105 and I-0008 twice at lines 108 and 111.
**What is true:** There are 165 canonical Task files and 30 canonical Issue files. `jq '[.taskIDs[].rawValue] | {entries:length, unique:(unique|length)}'` reports 210 entries and 165 unique Tasks; the equivalent Issue count reports 32 entries and 30 unique Issues.
**Authoritative source:** Canonical file inventory and the unique IDs in each canonical work-item record.
**Affected surfaces:** Canonical
**Diagnostic method:** Project-array enumeration, uniqueness count, and file-ID comparison.
**Repair layer:** Canonical project relationships through AirframeCore/AICockpit repair behavior.
**Why it matters:** Consumers that iterate project membership without deduplication can double-count 45 Tasks and two Issues even though the current dashboard summary happens to count record files instead.
**Options:** Deduplicate the arrays through canonical repair; also add uniqueness validation so the defect cannot recur.

### F-02 — I-0001–I-0004 are absent from EP-017's reciprocal Issue links

**Layer / File / Kind / Severity:** Epic / Issues · `.airframe/state/epics/EP-017.json`, `.airframe/state/issues/I-0001.json`–`I-0004.json` · Canonical · Moderate
**What is there:** EP-017's `issueIDs` array is empty at `.airframe/state/epics/EP-017.json:7`. Each of I-0001–I-0004 names EP-017 in its `epicID` field, for example `.airframe/state/issues/I-0001.json:6`.
**What is true:** All four Issues also belong to SP-017, and the Sprint relationship is reciprocal. The Epic relationship is the only missing reverse link.
**Authoritative source:** The four canonical Issue owner fields plus the reciprocal relationship invariant.
**Affected surfaces:** Canonical
**Diagnostic method:** Bidirectional traversal of every Epic-Issue relationship.
**Repair layer:** Canonical Epic-Issue relationship reconciliation.
**Why it matters:** EP-017 queries can omit four verified defects that are part of its canonical history.
**Options:** Add I-0001–I-0004 to EP-017; or, if their `epicID` assignments are wrong, remove those owner fields and document the intended ownership.

### F-03 — Eight Closed Epics own 42 unverified acceptance criteria

**Layer / File / Kind / Severity:** Epics / acceptance criteria · `.airframe/state/epics/EP-001.json`–`EP-008.json`, corresponding AC files · Canonical · Critical
**What is there:** EP-001–EP-008 are Closed; for example EP-001 is Closed at `.airframe/state/epics/EP-001.json:85`. Every one of their 42 acceptance criteria has `isVerified: false`; EP-001-AC-01 shows this at `.airframe/state/acceptance-criteria/EP-001-AC-01.json:8`.
**What is true:** Current Airframe close policy treats verified Epic acceptance criteria as close evidence. Later Closed Epics have verified AC records; the 42 false values are confined to EP-001–EP-008 imported from historical archives.
**Authoritative source:** Canonical Epic and acceptance-criterion records interpreted through current close policy.
**Affected surfaces:** Canonical, Generated
**Diagnostic method:** Enumerated all AC IDs owned by every Closed Epic and counted `isVerified` values: 47 true, 42 false.
**Repair layer:** Canonical migration/close-evidence policy, not generated Markdown.
**Why it matters:** Canonical state simultaneously asserts final human closure and missing acceptance verification, so it cannot provide an unambiguous close-evidence history for these Epics.
**Options:** Reconstruct legitimate human verification evidence; introduce an explicit grandfathered/migrated disposition distinct from verification; or rule that historical closure is sufficient and encode that policy rather than silently setting false ACs true.

### F-04 — Workspace configuration retains closed active pointers

**Layer / File / Kind / Severity:** Workspace · `.airframe/airframe-workspace.json` · Legacy · Moderate
**What is there:** The configuration names SP-023 as active at lines 17–18 and EP-018 as active at lines 20–21.
**What is true:** Canonical project state has null active pointers, all 37 Sprints and 24 Epics are Closed, and AICockpit canonical context reports no active Sprint or Epic.
**Authoritative source:** `.airframe/state/projects/PRJ-AIRFRAME.json` and canonical AICockpit context.
**Affected surfaces:** Legacy configuration
**Diagnostic method:** Direct pointer comparison and canonical lifecycle enumeration.
**Repair layer:** Workspace configuration or configuration schema, depending on whether those fields should now be removed or synchronized.
**Why it matters:** A consumer that reads configuration instead of canonical project state sees long-closed work as current.
**Options:** Clear the configuration pointers; remove deprecated mutable pointer fields; or generate them from canonical state with an explicit synchronization rule.

### F-05 — Six generated Task projections are stale on verification

**Layer / File / Kind / Severity:** Tasks · `docs/generated/Tasks/T-0154.md`–`T-0159.md` · Projection · Moderate
**What is there:** All six projections say `Implemented - Not Verified` at line 3 of their respective files.
**What is true:** Each corresponding canonical Task record has `status: implementedVerified`; for example `.airframe/state/tasks/T-0154.json:46`.
**Authoritative source:** Canonical Task records.
**Affected surfaces:** Generated
**Diagnostic method:** Compared the primary Status field in all 165 Task projections with canonical status.
**Repair layer:** Projection regeneration and, if regeneration reproduces the defect, projector logic.
**Why it matters:** Generated documentation incorrectly places completed work back into the human-verification queue.
**Options:** Regenerate these projections from canonical state; diagnose the projector or refresh trigger if the stale output recurs.

### F-06 — Issue projections use Task-specific verification terminology

**Layer / File / Kind / Severity:** Issues · all 30 files under `docs/generated/Issues/` · Projection · Minor
**What is there:** Every projection says `Implemented - Verified`, for example `docs/generated/Issues/I-0030.md:3`.
**What is true:** Issue Guidelines define the human-facing Issue state as `Resolved - Verified` (`docs/Issues/Issue-GUIDELINES.md:17`), while Task terminology is `Implemented - Verified`.
**Authoritative source:** Artifact-specific display-label policy in AGENTS.md and Issue Guidelines.
**Affected surfaces:** Generated
**Diagnostic method:** Counted all generated Issue Status fields; 30 of 30 use the generic Task label.
**Repair layer:** Markdown projector's artifact-specific status rendering, followed by regeneration.
**Why it matters:** The status meaning remains inferable, but the projection violates the required Issue vocabulary and can confuse parsers or reviewers expecting `Resolved`.
**Options:** Render `Resolved - Verified` and `Resolved - Not Verified` for Issues while retaining Task labels for Tasks.

### F-07 — Generated Epic and Sprint relationship statuses are blank

**Layer / File / Kind / Severity:** Epics / Sprints · `docs/generated/Epics/*.md`, `docs/generated/Sprints/*.md` · Projection · Moderate
**What is there:** Relationship tables declare Status columns but leave the cells empty; examples include `docs/generated/Epics/EP-024.md:33` and `docs/generated/Sprints/SP-037.md:14`. There are 416 blank relationship-status cells.
**What is true:** Every referenced canonical Sprint, Task, and Issue has a status; in the current dataset they are all Closed or Verified.
**Authoritative source:** Referenced canonical work-item records.
**Affected surfaces:** Generated
**Diagnostic method:** Counted rows matching `| <artifact ID> |  |` and resolved every referenced ID canonically.
**Repair layer:** Markdown projector relationship rendering.
**Why it matters:** The generated parent documents cannot serve as self-contained status reviews despite advertising the field.
**Options:** Populate the cells from canonical records; or remove the Status columns if relationship-only projections are intentional.

### F-08 — Legacy Issue tracking is materially stale and incomplete

**Layer / File / Kind / Severity:** Issues · `docs/Issues/Issue-active.md`, `Issue-Documentation.md`, archives · Legacy · Critical
**What is there:** The index says 13 Issues are Resolved - Not Verified (`Issue-Documentation.md:17`–33), only 13 are Verified (`:48`), total Issues are 26 (`:71`), and I-0027 is next (`:77`). `Issue-active.md` contains 13 Not Verified records, with Status fields at lines 7 through 356. I-0027–I-0030 do not appear in the Legacy index.
**What is true:** Canonical state contains I-0001–I-0030 continuously, and all 30 have `implementedVerified` status. The canonical summary reports 30 Issues.
**Authoritative source:** Canonical Issue records and continuous file-ID enumeration.
**Affected surfaces:** Legacy
**Diagnostic method:** Compared Legacy working/index/archive membership and counts with all canonical Issue records.
**Repair layer:** Legacy compatibility documents, or their retirement in favor of generated views.
**Why it matters:** A reader following the Legacy index would attempt to verify 13 already verified Issues, fail to discover four Issues, and allocate the already-issued ID I-0027 again.
**Options:** Regenerate/rebuild the Legacy Issue surfaces from canonical state; replace them with generated indexes; or formally retire them and redirect readers to canonical projections.

### F-09 — Legacy Task tracking assigns 20 Verified Tasks to earlier states

**Layer / File / Kind / Severity:** Tasks · `docs/Tasks/Task-backlog.md`, `Task-active.md`, `Task-unverified.md`, `Task-Documentation.md` · Legacy · Critical
**What is there:** Six Tasks appear in Backlog (`Task-backlog.md:5`), three appear Active (`Task-active.md:5`), and eleven detailed entries appear in `Task-unverified.md` (`:17`–295). The index internally reports six Backlog, four Active, two Unverified, and 153 Verified (`Task-Documentation.md:185`–189), while its section headings separately claim ten Unverified at line 44.
**What is true:** Canonical state contains T-0001–T-0165 continuously, and all 165 are `implementedVerified`; the canonical summary reports 165 Verified, zero Active, and zero Unverified.
**Authoritative source:** Canonical Task records and canonical project summary.
**Affected surfaces:** Legacy
**Diagnostic method:** Enumerated every detailed Legacy working-file entry, compared index counts internally, then compared every ID and status with canonical records.
**Repair layer:** Legacy compatibility documents, or their retirement in favor of generated views.
**Why it matters:** The documents misdirect implementation and verification work and contain mutually inconsistent queue counts.
**Options:** Rebuild all Legacy Task surfaces from canonical state; replace them with generated indexes; or retire them with clear redirects.

### F-10 — GitHub-backed project summary truncates the Agile dataset at 100

**Layer / File / Kind / Severity:** Project · live GitHub backend · Backend · Critical
**What is there:** `aicockpit project summary --backend github-issues --output json` reports exactly 100 total work items, 26 Issues, 58 Verified Tasks, and 16 Unverified Tasks.
**What is true:** The canonical summary reports 256 work items: 24 Epics, 37 Sprints, 165 Tasks, and 30 Issues. A direct read-only `gh issue list --state all --limit 300` finds 177 Agile-labeled GitHub Issues: 151 Tasks and 26 Issues.
**Authoritative source:** Canonical project membership for total Agile state; direct live GitHub enumeration for the Backend surface.
**Affected surfaces:** Backend
**Diagnostic method:** Compared canonical summary, AICockpit GitHub summary, and direct GitHub list counts.
**Repair layer:** GitHub backend pagination/limit behavior and summary diagnostics.
**Why it matters:** The live dashboard omits at least 77 GitHub-tracked artifacts and 156 canonical Agile Artifacts, producing materially wrong project counts.
**Options:** Implement pagination or a sufficient explicit limit; expose partial-result diagnostics; and define how non-GitHub canonical Epics/Sprints and unmapped records appear in backend summaries.

### F-11 — Twenty-nine GitHub status labels disagree with canonical state

**Layer / File / Kind / Severity:** Tasks / Issues · live GitHub labels · Backend · Critical
**What is there:** GitHub labels 28 artifacts `status-unverified` and I-0027 `status-backlog`. The affected Tasks are T-0107–T-0109, T-0115, T-0148–T-0153, and T-0160–T-0165. The affected Issues are I-0009–I-0019, I-0021, and I-0027.
**What is true:** All 29 corresponding canonical records are `implementedVerified`.
**Authoritative source:** Canonical Task and Issue status records.
**Affected surfaces:** Backend
**Diagnostic method:** Direct live GitHub label enumeration and mapped-ID comparison.
**Repair layer:** Established GitHub status synchronization after confirming the intended canonical authority.
**Why it matters:** GitHub presents accepted work as awaiting verification or not started, which can trigger duplicate work and contradict AgileCockpit.
**Options:** Synchronize the 29 established labels from canonical state; then add reconciliation diagnostics or automated user-authorized verification synchronization.

### F-12 — Canonical requirement statements contain imported document structure

**Layer / File / Kind / Severity:** Requirements · 25 files under `.airframe/state/requirements/` · Canonical · Critical
**What is there:** Twenty-five requirement `statement` values include section separators, later headings, open-issue lists, or Version 1.0 boundary prose. For example `.airframe/state/requirements/AC-DR-004.json:24` appends `---` and `## 6. Interface Requirements` to the actual requirement. CWS-FR-015, CWS-NFR-005, RT-FR-016, RT-IE-005, and RT-RG-004 absorb particularly large subsequent sections.
**What is true:** A canonical requirement statement should contain only the requirement's normative statement; source document section structure belongs outside that field.
**Authoritative source:** Canonical requirement schema semantics and the referenced source requirement documents.
**Affected surfaces:** Canonical, Generated
**Diagnostic method:** Searched all 201 canonical statements for imported Markdown section boundaries and reviewed the 25 matches; the same contamination appears in generated requirement documents.
**Repair layer:** Canonical requirement import/parser behavior, canonical data repair, then projection regeneration.
**Why it matters:** Compliance and release-gate readers can interpret unrelated headings and scope prose as part of a normative requirement.
**Options:** Correct the importer boundary logic and re-import/repair the 25 records; mechanically compare repaired statements with source sections before regenerating requirements documents.

### F-13 — Artifact Guidelines still prescribe Markdown-first mutation

**Layer / File / Kind / Severity:** Guidelines · all four Agile Artifact Guidelines · Guidelines · Moderate
**What is there:** Issue Guidelines require updating local documents for each transition (`Issue-GUIDELINES.md:114`–117); Task Guidelines require moving detailed entries between working Markdown and archives (`Task-Guidelines.md:121`–123); Sprint and Epic Guidelines similarly prescribe direct index/archive maintenance (`Sprint-GUIDELINES.md:82`–86; `Epic-GUIDELINES.md:95`–98).
**What is true:** AGENTS.md and Audit Guidelines establish AirframeCore and `.airframe/state/` as authoritative, with Markdown generated or treated as a compatibility surface. Mutations should enter through canonical APIs and projections should be regenerated.
**Authoritative source:** AGENTS.md canonical conventions and `docs/Audits/Audit-Guidelines.md` canonical authority order.
**Affected surfaces:** Legacy Guidelines
**Diagnostic method:** Compared every Guidelines authorization, file-organization, and update section with current canonical architecture.
**Repair layer:** The four Artifact Guidelines.
**Why it matters:** An agent following the Artifact Guidelines can directly edit downstream documents and recreate canonical/projection divergence.
**Options:** Rewrite all four Guidelines as canonical-first procedures, explicitly classifying Legacy files and generated projections and prohibiting hand-edits to generated output.

### F-14 — Mandatory GitHub mapping rules conflict with canonical/local operation

**Layer / File / Kind / Severity:** Tasks / Issues · Guidelines and canonical records · Guidelines · Moderate
**What is there:** Issue Guidelines say every Issue must have exactly one GitHub Issue (`Issue-GUIDELINES.md:27`); Task Guidelines impose the same rule (`Task-Guidelines.md:27`).
**What is true:** Twenty-one canonical Tasks (T-0110–T-0114, T-0132–T-0147, and T-0154–T-0159) and five canonical Issues (I-0020, I-0027–I-0030) have no `githubIssue`. Airframe's approved local-only architecture also makes GitHub optional.
**Authoritative source:** Canonical records and approved local-only operating profile.
**Affected surfaces:** Canonical, Legacy Guidelines, Backend
**Diagnostic method:** Enumerated null `workItem.githubIssue` fields across all canonical Tasks and Issues.
**Repair layer:** Guidelines policy first; canonical/backend mapping only for records the user rules must be mapped.
**Why it matters:** The repository is noncompliant with its own Guidelines, but automatically creating mappings would contradict optional/offline operation and exceed Audit authority.
**Options:** Make GitHub mapping optional with explicit mapping-state rules; or affirm mandatory mapping and create tracked remediation for the 26 records.

### F-15 — Sprint Guidelines contradict the actual backlog layout

**Layer / File / Kind / Severity:** Sprints · `docs/Sprints/Sprint-GUIDELINES.md` · Guidelines · Minor
**What is there:** The file organization omits `Sprint-backlog.md` (`Sprint-GUIDELINES.md:27`–34), and the checklist says to keep backlogged and planning Sprints in `Sprint-active.md` (`:84`).
**What is true:** `docs/Sprints/Sprint-backlog.md` exists and AGENTS.md identifies it as the Backlog surface. Backlog and Active are distinct canonical statuses and documents.
**Authoritative source:** Canonical lifecycle, actual repository layout, and AGENTS.md.
**Affected surfaces:** Legacy Guidelines
**Diagnostic method:** Compared named paths and status-routing instructions with filesystem inventory.
**Repair layer:** Sprint Guidelines.
**Why it matters:** The current instruction can place Backlog Sprints in two contradictory locations.
**Options:** Add `Sprint-backlog.md` to the layout and route Backlog there; define separately whether Planning belongs in active or backlog compatibility output.

### F-16 — Canonical diagnostics produce a false clean result

**Layer / File / Kind / Severity:** Canonical diagnostics · AirframeCore/AICockpit validator surface · Guidelines · Critical
**What is there:** `aicockpit state diagnostics --backend canonical --output json` returns `status: ok` with an empty diagnostics array.
**What is true:** The same canonical snapshot contains the duplicate project memberships in F-01, missing reciprocal Issue links in F-02, and Closed-Epic/unverified-AC contradictions in F-03.
**Authoritative source:** Direct structured-record enumeration and current canonical relationship/close policies.
**Affected surfaces:** Canonical
**Diagnostic method:** Ran canonical diagnostics, then independently checked uniqueness, reciprocal relationships, and Closed-parent acceptance state.
**Repair layer:** AirframeCore canonical validator and regression tests.
**Why it matters:** Operators are told canonical state is healthy when it contains defects capable of changing counts, relationship queries, and close-evidence conclusions.
**Options:** Add validator rules for membership uniqueness, both directions of all relationships, and Closed Epic acceptance consistency, with a migration-aware disposition if historical ACs are intentionally grandfathered.

### F-17 — `.DS_Store` is an orphan in the Epic tracking directory

**Layer / File / Kind / Severity:** Epics · `docs/Epics/.DS_Store` · Misplaced · Minor
**What is there:** A Finder metadata file exists beside the defined Epic tracking documents.
**What is true:** Epic Guidelines name only Guidelines, index, backlog, active, and Closed archive content. `.DS_Store` is not an Agile record or approved documentation artifact.
**Authoritative source:** Epic Guidelines and filesystem inventory.
**Affected surfaces:** Legacy
**Diagnostic method:** Enumerated every file directly under all four tracking directories.
**Repair layer:** Repository hygiene and ignore policy.
**Why it matters:** It is harmless to workflow state but is an orphan binary artifact in an audited documentation directory.
**Options:** Remove it and ensure repository ignore rules prevent recurrence.

## Guidelines recommendations

1. Extend all four Artifact Guidelines with a cross-reference to this Audit procedure and canonical authority order.
2. Define whether Legacy indexes remain supported projections or should be retired; their current hybrid status is the main source of drift.
3. Define an explicit migration disposition for historical Closed Epics whose acceptance criteria predate canonical verification records.
4. Require pagination/partial-result disclosure in every backend list or summary contract.
5. Define optional GitHub mapping states compatible with local-only operation.

## Systemic observations

- Canonical file coverage and ID continuity are complete: EP-001–EP-024, SP-001–SP-037, T-0001–T-0165, and I-0001–I-0030 all have exactly one canonical work-item file and one generated per-item projection.
- All 24 Legacy Epic archives and 37 Legacy Sprint archives agree with canonical ID, title, and Closed status.
- The dominant systemic failure is incomplete fan-out after canonical mutations: canonical status, generated per-item files, Legacy queues/indexes, and GitHub labels have diverged in different combinations.
- Current canonical diagnostics validate enough structure to load the store but do not establish the stronger consistency promised by the canonical-first documentation model.
- Requirements projections faithfully expose canonical requirement contamination; this is upstream canonical/import drift, not primarily a projection problem.

## Scope limitations

- Live GitHub was available and inspected read-only.
- `aicockpit tests validate` could not run in the managed sandbox because Swift attempted to write its module cache under `/Users/justgus/.cache/clang/ModuleCache`. The environmental cause is understood, so the command was not rerun. Canonical `state diagnostics` did run successfully and direct canonical test/test-suite inventories found eight ready Tests and two ready Test Suites.
- Projection determinism was evaluated structurally and by canonical comparison. The Audit did not invoke `state export-markdown` because it writes repository projections and Phase 1 prohibits that mutation.

## Open questions for the user

1. For F-03, should EP-001–EP-008 acceptance criteria be reconstructed and verified individually, or receive a distinct grandfathered historical-close disposition?
2. For F-14, should GitHub mappings remain optional under the local-only profile, or should the 26 unmapped canonical Tasks and Issues receive GitHub Issues?
3. Should Legacy working/index documents remain maintained canonical projections, or should they be retired in favor of `docs/generated/` and AgileCockpit?
