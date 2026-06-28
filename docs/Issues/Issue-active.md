# Active Issues

Issues assigned to active Sprints are listed here. Issues move out of this file after they are resolved and human-verified.

## I-0009: Epic close leaves stale active pointers and sprint closeout state

**Status:** Resolved - Not Verified
**GitHub Issue:** #147
**Platform:** macOS
**Component:** AgileCockpit / AirframeCore / Canonical State
**Severity:** High
**Epic:** None
**Sprint:** None
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-25
**Verification Date:** TBD

**Description:**
Closing EP-021 in AgileCockpit transitioned the Epic to Closed but left the project active Epic pointer on EP-021. The project active Sprint pointer also remained stale on SP-032 after SP-032 and SP-033 were closed, which caused Data Health diagnostics to report closed work as active and exposed that active pointer cleanup was incomplete.

**Expected Behavior:**
When AgileCockpit closes an Epic, canonical project state should clear the active Epic pointer. Active Epic UI, release gate scope, and traceability scope should read the canonical project snapshot rather than stale configuration. Sprint closeout data should not leave a closed Sprint configured as active, and follow-up work should define whether closing a Sprint should advance, clear, or require explicit selection of the next current Sprint.

**Resolution:**
Added canonical active Epic clearing support, wired AgileCockpit Epic close to clear the canonical active Epic pointer, switched active Epic UI/scope reads to canonical project state, repaired EP-021/SP-033 canonical and Markdown closeout state, and restored the missing SP-029 canonical Sprint record.

**Files Affected:**
- `AirframeCore/Sources/AirframeCore/CanonicalStoreBackend.swift`
- `AgileCockpit/AgileCockpit/ContentView.swift`
- `AgileCockpit/AgileCockpitTests/AgileCockpitTests.swift`
- `.airframe/airframe-workspace.json`
- `.airframe/state/projects/PRJ-AIRFRAME.json`
- `.airframe/state/sprints/SP-029.json`
- `.airframe/state/sprints/SP-033.json`
- `docs/Epics/`
- `docs/Sprints/`
- `docs/Issues/`

**Follow-up:**
- Investigate and define current Sprint advancement behavior after closing a Sprint when another Sprint is already closed, active, or absent.
- Decide whether AgileCockpit should update `.airframe/airframe-workspace.json` active pointers or treat canonical project state as the only mutable active pointer source.

I-0001 through I-0004 were reconciled to verified historical EP-017/SP-017 state on 2026-06-23 and moved to [Verified/Issue-verified-0001-0004.md](Verified/Issue-verified-0001-0004.md).

## I-0010: Sprint close does not archive Markdown Sprint record

**Status:** Resolved - Not Verified
**GitHub Issue:** #148
**Platform:** macOS
**Component:** AgileCockpit / Documentation / Canonical State
**Severity:** High
**Epic:** EP-018
**Sprint:** SP-023
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-25
**Verification Date:** TBD

**Description:**
AgileCockpit closeActiveSprint transitions the canonical Sprint status and clears the active Sprint pointer, but it does not write a closed Sprint Markdown record under `docs/Sprints/Closed/`.

**Expected Behavior:**
When an authorized human closes a reviewed Sprint, AgileCockpit should preserve the closed Sprint as `docs/Sprints/Closed/Sprint-<ID>.md` and remove the closed Sprint from the active Sprint projection.

**Resolution:**
AgileCockpit now writes closed Sprint Markdown archives from canonical state after Sprint close and refreshes Sprint projections.

## I-0011: Epic close does not archive Markdown Epic record

**Status:** Resolved - Not Verified
**GitHub Issue:** #149
**Platform:** macOS
**Component:** AgileCockpit / Documentation / Canonical State
**Severity:** High
**Epic:** EP-018
**Sprint:** SP-023
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-25
**Verification Date:** TBD

**Description:**
AgileCockpit closeActiveEpic transitions the canonical Epic status and clears the active Epic pointer, but it does not write a closed Epic Markdown record under `docs/Epics/Closed/`.

**Expected Behavior:**
When an authorized human closes an Epic, AgileCockpit should preserve the closed Epic as `docs/Epics/Closed/Epic-<ID>.md` and remove the closed Epic from the active Epic projection.

**Resolution:**
AgileCockpit now writes closed Epic Markdown archives from canonical state after Epic close and refreshes Epic projections.

## I-0012: Close actions do not refresh Sprint and Epic indexes

**Status:** Resolved - Not Verified
**GitHub Issue:** #150
**Platform:** macOS
**Component:** AgileCockpit / Documentation / Canonical State
**Severity:** High
**Epic:** EP-018
**Sprint:** SP-023
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-25
**Verification Date:** TBD

**Description:**
AgileCockpit Sprint and Epic close actions update canonical JSON state, but human-facing Markdown indexes and projections can remain stale after close.

**Expected Behavior:**
After an authorized Sprint or Epic close, the relevant Markdown projections and indexes should be regenerated or updated deterministically from canonical state.

**Resolution:**
AgileCockpit close actions now refresh Sprint and Epic Markdown projections and generated records from canonical state.

## I-0013: Epic close eligibility ignores open Sprints

**Status:** Resolved - Not Verified
**GitHub Issue:** #151
**Platform:** macOS
**Component:** AgileCockpit / AirframeCore / Canonical State
**Severity:** High
**Epic:** EP-018
**Sprint:** SP-023
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-25
**Verification Date:** TBD

**Description:**
AgileCockpit reports the active Epic as eligible to close even when related Sprints such as SP-023 and SP-024 are not completed yet.

**Expected Behavior:**
Epic close eligibility should require all related Sprints for the Epic to be closed, or otherwise explicitly excluded by workflow policy, before enabling Epic close.

**Resolution:**
Epic close eligibility now includes related Sprint status and blocks close while related Sprints remain Backlog, Planning, Active, or Review.

## I-0014: AgileCockpit does not refresh active Sprint after external state change

**Status:** Resolved - Not Verified
**GitHub Issue:** #153
**Platform:** macOS
**Component:** AgileCockpit / Canonical State / Refresh Observation
**Severity:** High
**Epic:** EP-022
**Sprint:** SP-034
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-25
**Verification Date:** TBD

**Description:**
AgileCockpit did not update to show SP-024 as the active Sprint after canonical state changed. The user had to exit and restart the app before the correct state appeared.

**Expected Behavior:**
AgileCockpit should detect external canonical state changes and refresh visible active Sprint and Epic state without requiring app restart. The main UI should also expose an explicit Refresh action.

**Acceptance Criteria:**
1. AgileCockpit observes canonical state directory changes that may be delivered through atomic file replacement.
2. A main UI Refresh button reloads Airframe state on demand.
3. Regression coverage proves manual refresh updates active Sprint state from the canonical store.

**Resolution:**
AgileCockpit now watches canonical state subdirectories, exposes a main dashboard Refresh button, and reloads state on manual refresh from the canonical store.

## I-0015: Markdown importer skips closed sprint artifacts under docs/Sprints/Closed

**Status:** Resolved - Not Verified
**GitHub Issue:** #154
**Platform:** macOS
**Component:** AirframeCore / Canonical State / Markdown Importer
**Severity:** High
**Epic:** EP-022
**Sprint:** SP-034
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-26
**Verification Date:** TBD

**Description:**
`state import-markdown` omits sprint records from `docs/Sprints/Closed/`, leaving closed sprint artifacts such as SP-002 and SP-003 out of canonical state.

**Expected Behavior:**
Closed sprint artifacts should import the same way closed task and epic artifacts do, preserving the sprint record and its relationships.

**Acceptance Criteria:**
1. `state import-markdown` reads `docs/Sprints/Closed/` for sprint artifacts.
2. Closed sprint records import with their original status and relationships intact.
3. Regression coverage proves SP-002 and SP-003 import from closed sprint markdown.

**Resolution:**
Verified markdown artifact discovery imports closed sprint records from `docs/Sprints/Closed` while preserving their status and relationships.

**Evidence:**
- `swift test --package-path AICockpit` passed on 2026-06-26, including `stateImportMarkdownIncludesClosedSprintArtifactsFromClosedDirectory`.
- `swift test --package-path AirframeCore` passed on 2026-06-26.
- `swift run --package-path AICockpit aicockpit state diagnostics --config .airframe/airframe-workspace.json --backend canonical --output json` passed with no diagnostics on 2026-06-26.

## I-0016: Markdown importer maps active epic and sprint statuses incorrectly

**Status:** Resolved - Not Verified
**GitHub Issue:** #157
**Platform:** macOS
**Component:** AirframeCore / Canonical State / Markdown Importer
**Severity:** High
**Epic:** EP-022
**Sprint:** SP-034
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-26
**Verification Date:** TBD

**Description:**
Active epics and sprints can import as backlog, which creates blocking diagnostics after a clean markdown import.

**Expected Behavior:**
Active epic and sprint artifacts should import as active, not backlog, so diagnostics remain clean after a correct markdown import.

**Acceptance Criteria:**
1. Markdown import preserves active epic and sprint status.
2. Imported active epics and sprints do not trigger `activeEpicNotActive` or `activeSprintNotActive` diagnostics.
3. Regression coverage proves active epic and sprint markdown imports as active.

**Resolution:**
Verified markdown status parsing preserves active Epic and Sprint artifacts as active during import.

**Evidence:**
- `swift test --package-path AICockpit` passed on 2026-06-26, including `stateImportMarkdownPreservesActiveEpicAndSprintStatuses`.
- `swift test --package-path AirframeCore` passed on 2026-06-26.
- `swift run --package-path AICockpit aicockpit state diagnostics --config .airframe/airframe-workspace.json --backend canonical --output json` passed with no diagnostics on 2026-06-26.

## I-0017: Markdown importer drops task Epic and Sprint back-links from batch documents

**Status:** Resolved - Not Verified
**GitHub Issue:** #158
**Platform:** macOS
**Component:** AirframeCore / Markdown Importer / Task Batch Imports
**Severity:** High
**Epic:** EP-022
**Sprint:** SP-034
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-26
**Verification Date:** TBD

**Description:**
Tasks imported from batch markdown documents can lose their epicID and sprintID relationships, leaving the canonical store with missing task-to-sprint links.

**Expected Behavior:**
Batch task imports should preserve Epic and Sprint back-links when they are present in the source artifacts.

**Acceptance Criteria:**
1. Batch task documents import with their Epic and Sprint IDs intact.
2. Imported tasks do not trigger `taskEpicMissing` or `taskSprintMissing` when the source artifact includes the links.
3. Regression coverage proves the verified batch files import with correct back-links.

**Resolution:**
Verified batch task markdown imports preserve Epic and Sprint back-links from source documents.

**Evidence:**
- `swift test --package-path AICockpit` passed on 2026-06-26, including `stateImportMarkdownPreservesBatchTaskBackLinksFromVerifiedDocuments`.
- `swift test --package-path AirframeCore` passed on 2026-06-26.
- `swift run --package-path AICockpit aicockpit state diagnostics --config .airframe/airframe-workspace.json --backend canonical --output json` passed with no diagnostics on 2026-06-26.

## I-0018: Canonical backend lacks a create path for missing records

**Status:** Resolved - Not Verified
**GitHub Issue:** #155
**Platform:** macOS
**Component:** AICockpit / AirframeCore / Canonical Store
**Severity:** High
**Epic:** EP-022
**Sprint:** SP-034
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-26
**Verification Date:** TBD

**Description:**
The canonical backend can repair and mutate existing records, but it cannot create missing canonical records through the CLI.

**Expected Behavior:**
The canonical backend should support controlled creation of missing canonical records where the workflow requires it.

**Acceptance Criteria:**
1. Canonical backend exposes a create path for permitted record kinds.
2. Missing canonical records needed by repairs can be created without manual JSON edits.
3. Regression coverage proves the canonical create path works for the intended record types.

**Resolution:**
Verified AICockpit canonical create commands route through the canonical backend and link created records to their owning Epic and Sprint.

**Evidence:**
- `swift test --package-path AICockpit` passed on 2026-06-26, including `canonicalStoreBackendCreatesAndLinksTaskRecords`.
- `swift test --package-path AirframeCore` passed on 2026-06-26.
- `swift run --package-path AICockpit aicockpit state diagnostics --config .airframe/airframe-workspace.json --backend canonical --output json` passed with no diagnostics on 2026-06-26.

## I-0019: state repair ignores --output json and always emits markdown

**Status:** Resolved - Not Verified
**GitHub Issue:** #156
**Platform:** macOS
**Component:** AICockpit / Canonical Repair / CLI Output
**Severity:** High
**Epic:** EP-022
**Sprint:** SP-034
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-26
**Verification Date:** TBD

**Description:**
`aicockpit state repair` still emits markdown-style output even when `--output json` is requested.

**Expected Behavior:**
Repair commands should honor the requested output format consistently, with markdown remaining available only when explicitly requested.

**Acceptance Criteria:**
1. `state repair --output json` emits JSON.
2. Markdown remains available when explicitly requested.
3. Regression coverage proves repair output format selection is stable.

**Resolution:**
Verified `state repair` output rendering honors the requested output format, including JSON.

**Evidence:**
- `swift test --package-path AICockpit` passed on 2026-06-26, including `stateRepairRestoresCanonicalActiveEpicFromDiagnostics` and `stateRepairReconcilesCanonicalEpicTaskLinksFromDiagnostics`.
- `swift test --package-path AirframeCore` passed on 2026-06-26.
- `swift run --package-path AICockpit aicockpit state diagnostics --config .airframe/airframe-workspace.json --backend canonical --output json` passed with no diagnostics on 2026-06-26.

## I-0020: Canonical moves can leave stale reverse links on closed work

**Status:** Resolved - Not Verified
**GitHub Issue:** None
**Platform:** macOS
**Component:** AirframeCore / Canonical State / AgileCockpit / AICockpit
**Severity:** High
**Epic:** EP-022
**Sprint:** SP-034
**Date Identified:** 2026-06-26
**Fix Date:** 2026-06-26
**Verification Date:** TBD

**Description:**
After I-0015 through I-0019 were moved from EP-018/SP-024 to EP-022/SP-034, Data Health still reported the Issues as owned by closed EP-018. The Issue records and visible documentation showed EP-022/SP-034, but stale reverse links remained in canonical owner records and were not visible in the detail panel.

**Expected Behavior:**
Moving Tasks or Issues between Epics or Sprints should update child forward links and all owner reverse links through a single canonical operation. AgileCockpit should not hide canonical relationship arrays that Data Health uses for diagnostics.

**Acceptance Criteria:**
1. Current stale canonical links are repaired so EP-018 and SP-024 no longer own I-0015 through I-0019.
2. AirframeCore exposes canonical move operations for Tasks and Issues that update old owner links, child forward links, and new owner links together.
3. `updateWorkRecord` and reconciliation helpers cannot leave Tasks or Issues linked from both old and new Epics or Sprints.
4. Regression coverage proves moving a Task or Issue off closed work clears stale reverse links.
5. AgileCockpit detail views expose canonical relationship state or clearly label non-canonical detail text.

**Resolution:**
Repaired EP-018 and SP-024 canonical reverse links, added canonical `moveTask` and `moveIssue` repository operations, made Task/Issue reconciliation remove stale owner links, reconciled Issue `updateWorkRecord` behavior, and appended canonical relationship data to AgileCockpit status detail text.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-26.
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-26.
- `swift run --package-path AICockpit aicockpit state diagnostics --config .airframe/airframe-workspace.json --backend canonical --output json` passed with no diagnostics on 2026-06-26.

## I-0021: Active Sprint exclusivity is not enforced across canonical state

**Status:** Resolved - Not Verified
**GitHub Issue:** #159
**Platform:** macOS
**Component:** AirframeCore / Canonical State / Canonical Diagnostics / AgileCockpit
**Severity:** High
**Epic:** EP-022
**Sprint:** SP-034
**Date Identified:** 2026-06-26
**Fix Date:** 2026-06-26
**Verification Date:** TBD

**Description:**
AgileCockpit can show SP-034 as the current active Sprint in dashboard-style views while the header and Sprint Work tab show Sprint None. The active Sprint record exists, but the canonical project `activeSprintID` pointer is missing or stale, so different views use different current Sprint sources.

**Expected Behavior:**
For Airframe's current single-user, single-development-path workflow, only one Sprint may be Active at a time. The sole Active Sprint is the current Sprint by default, and `project.activeSprintID` must agree with it. Data Health should report multiple Active Sprints and should report a mismatch when exactly one Sprint is Active but the project active Sprint pointer is missing or different.

**Acceptance Criteria:**
1. Canonical diagnostics detect more than one Active Sprint.
2. Canonical diagnostics detect exactly one Active Sprint when `project.activeSprintID` is missing or points elsewhere.
3. AgileCockpit header and Sprint Work tab use a consistent current Sprint source.
4. Regression coverage proves SP-034 active with nil project pointer is diagnosed or normalized.
5. Repair behavior must not silently choose between multiple Active Sprints.

**Resolution:**
Added Active Sprint exclusivity diagnostics, an `activeSprintPointerMismatch` diagnostic with a safe `setActiveSprintID` repair for the sole-active-Sprint case, preserved missing/invalid pointer diagnostics, updated AICockpit repair help, made AgileCockpit display and Sprint Work selection use a consistent current Sprint selector, and repaired `PRJ-AIRFRAME.activeSprintID` to `SP-034` through AICockpit.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-26.
- `swift test --package-path AICockpit` passed on 2026-06-26.
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-26.
- `swift run --package-path AICockpit aicockpit state diagnostics --config .airframe/airframe-workspace.json --backend canonical --output json` passed with no diagnostics on 2026-06-26.

*Last Updated: 2026-06-26 (I-0021 resolved locally and awaits verification)*
