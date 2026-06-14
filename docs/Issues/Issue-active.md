# Active Issues

Issues listed here are assigned to a Sprint and are either being fixed or awaiting human verification.

---

## I-0001: Dashboard status drill-down shows stray blue selection rectangle

**Status:** Resolved - Not Verified
**GitHub Issue:** #101
**Platform:** macOS
**Component:** AgileCockpit
**Severity:** Medium
**Epic:** EP-017
**Sprint:** SP-017
**Date Identified:** 2026-06-12
**Fix Date:** 2026-06-12
**Verification Date:** TBD

**Description:**
The dashboard status drill-down popup displays a large blue rectangle at the top of each work product list. The rectangle looks like a selection indicator, but it is visible before a meaningful work product selection has been made.

**Expected Behavior:**
The popup should show no selected-row highlight until a work item is selected. After selection, only the selected work item row should be highlighted.

**Actual Behavior:**
A stroked blue focus rectangle appears as the first element in every popup work product list. It does not move when the selected work product changes and is visually distinct from the filled selected-row highlight.

**Steps to Reproduce:**
1. Open AgileCockpit.
2. Click a dashboard status row with one or more work products.
3. Observe the top of the popup work product list before selecting a work item.

**Impact:**
- The popup looks broken.
- The selection affordance is misleading and distracts from the work product list.

**Root Cause Analysis:**
The work product rows are rendered as SwiftUI `Button` views. On macOS, the popover gives keyboard focus to the first focusable button and draws a stroked focus ring around it. That focus ring is not the app's selected-row highlight and does not track `selectedStatusWorkItemID`.

**Resolution:**
Disabled focusability on the status drill-down row buttons so macOS does not draw the persistent first-row focus ring. The app's filled selected-row highlight remains tied to the clicked work product.

**Files Affected:**
- `AgileCockpit/AgileCockpit/ContentView.swift`: Disabled focusability on status drill-down row buttons, removed default first-item selection on status drill-down open, and kept row highlight rendering behind a concrete selected ID check.
- `AgileCockpit/AgileCockpitTests/AgileCockpitTests.swift`: Added regression coverage that opening a status drill-down does not preselect a work item.

**Evidence:**
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-12.

**Verification:**
1. Open a dashboard status drill-down with multiple work products.
2. Confirm no stray blue rectangle appears before selection.
3. Click different work products and confirm the highlight follows only the selected row.

**Related Items:**
- EP-017
- SP-017
- T-0089

---

*Last Updated: 2026-06-12 (I-0001 resolved pending human verification)*

---

## I-0002: Status drill-down detail pane omits full work product text

**Status:** Resolved - Not Verified
**GitHub Issue:** #102
**Platform:** macOS
**Component:** AgileCockpit
**Severity:** Medium
**Epic:** EP-017
**Sprint:** SP-017
**Date Identified:** 2026-06-12
**Fix Date:** 2026-06-12
**Verification Date:** TBD

**Description:**
The status drill-down detail pane shows only a subset of a work product's fields. The UI needs to expose the full local work-product text so the selected Epic, Sprint, Task, or Issue can be read end to end from the dashboard.

**Expected Behavior:**
The detail pane should present the entire contents of the local work-product file or equivalent full text, not just selected summary fields.

**Actual Behavior:**
Only some fields are shown in the detail pane.

**Steps to Reproduce:**
1. Open AgileCockpit.
2. Click a dashboard status row with one or more work products.
3. Select a work product.
4. Observe the detail pane on the right.

**Impact:**
- Users cannot inspect the complete work product from the dashboard drill-down.
- The dashboard cannot serve as a full reference point for the selected local artifact.

**Root Cause Analysis:**
The detail pane was built from a partial field summary rather than the full source text of the selected work product.

**Resolution:**
The detail pane now renders the full source text for the selected local artifact when available, and a full text dump of the work record fields otherwise.

**Files Affected:**
- `AgileCockpit/AgileCockpit/ContentView.swift`: Added full-detail text aggregation and switched the drill-down pane to render the complete text payload.

**Evidence:**
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-12.

**Verification:**
1. Open a dashboard status drill-down with a local Epic or Sprint artifact.
2. Confirm the detail pane shows the full file text.
3. Confirm the full text can be read and scrolled end to end.

**Related Items:**
- EP-017
- SP-017
- T-0089

---

## I-0003: Status drill-down detail pane uses incomplete fallback text for Tasks and Issues

**Status:** Resolved - Not Verified
**GitHub Issue:** #103
**Platform:** macOS
**Component:** AgileCockpit
**Severity:** High
**Epic:** EP-017
**Sprint:** SP-017
**Date Identified:** 2026-06-13
**Fix Date:** 2026-06-14
**Verification Date:** TBD

**Description:**
The AgileCockpit dashboard status drill-down detail pane falls back to a synthetic field dump for Task and Issue records instead of using the source Markdown artifact sections. This omits the review history needed for work product inspection, including findings, root cause analysis, resolution notes, evidence, and verification instructions.

**Expected Behavior:**
Selecting a Task or Issue in the status drill-down should show the matching local Markdown section from aggregate artifact files such as `docs/Issues/Issue-active.md`, `docs/Issues/Issue-backlog.md`, `docs/Tasks/Task-active.md`, `docs/Tasks/Task-backlog.md`, `docs/Tasks/Task-unverified.md`, and `docs/Tasks/Verified/Task-verified-*.md` when available.

**Actual Behavior:**
Task and Issue details may show only synthesized backend fields such as ID, kind, title, status, priority, and empty acceptance/scope/evidence placeholders. The source review log is not preserved in the detail pane for those records.

**Steps to Reproduce:**
1. Open AgileCockpit.
2. Click a dashboard status row containing Tasks or Issues.
3. Select a Task or Issue whose detailed record exists in an aggregate Markdown artifact.
4. Observe that the detail pane can show incomplete synthetic fallback text instead of the source artifact section.

**Impact:**
- Reviewers cannot inspect the full work product history from the dashboard drill-down.
- Findings, root cause analysis, resolution notes, evidence, and verification instructions can be hidden from the review surface.
- The dashboard drill-down cannot serve as a reliable work product reference for Tasks and Issues.

**Root Cause Analysis:**
Dashboard detail text was keyed from backend records first. For Task and Issue records that live inside aggregate Markdown files, the dashboard could fall back to synthesized record fields instead of extracting the matching Markdown section.

**Resolution:**
Indexed local Task and Issue aggregate Markdown files by Airframe ID, preserved each matching heading section as the dashboard detail payload, used verified task batch files as the detail source for verified task rows, and retained synthesized fallback text only when no local artifact text exists.

**Files Affected:**
- `AgileCockpit/AgileCockpit/ContentView.swift`: Added section-based local artifact records for Task and Issue aggregate files and merged artifact detail text ahead of backend fallback detail text.
- `AgileCockpit/AgileCockpitTests/AgileCockpitTests.swift`: Added regression coverage for Issue section detail text, Task section detail text, and verified Task batch detail text.

**Evidence:**
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-14.
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitUITests` passed on 2026-06-14.

**Verification:**
1. Open a dashboard status drill-down containing `I-0002`.
2. Select `I-0002`.
3. Confirm the detail pane shows the `Issue-active.md` section for `I-0002`, including description, root cause, resolution, evidence, and verification.
4. Select Tasks from active, backlog, unverified, and verified aggregate files.
5. Confirm each detail pane shows the matching artifact text rather than incomplete synthetic fallback text.

**Related Items:**
- EP-017
- SP-017
- T-0089

---

## I-0004: Status drill-down detail scroll position is retained across item selection

**Status:** Resolved - Not Verified
**GitHub Issue:** #104
**Platform:** macOS
**Component:** AgileCockpit
**Severity:** Medium
**Epic:** EP-017
**Sprint:** SP-017
**Date Identified:** 2026-06-13
**Fix Date:** 2026-06-14
**Verification Date:** TBD

**Description:**
The AgileCockpit dashboard status drill-down detail pane retains its scroll position when the user selects a different work item. If the previous detail text was scrolled to the bottom, selecting another item opens the new detail text at the bottom instead of at the beginning.

**Expected Behavior:**
Whenever the selected drill-down work item changes and the detail view refreshes, the detail pane should reset to the top of the newly selected item text.

**Actual Behavior:**
The detail pane can remain scrolled to the bottom or another prior offset after selecting a different work item.

**Steps to Reproduce:**
1. Open AgileCockpit.
2. Click a dashboard status row with multiple work products.
3. Select a work product with enough detail text to scroll.
4. Scroll the detail pane to the bottom.
5. Select another work product in the list.
6. Observe that the new detail remains at the previous scroll offset instead of starting at the top.

**Impact:**
- Reviewers can miss the start of the selected work product detail.
- The detail refresh appears incomplete or stale because the pane does not present the beginning of the newly selected text.

**Root Cause Analysis:**
The status drill-down detail view reused the same SwiftUI scroll view identity across different selected work items, so SwiftUI could preserve the previous scroll offset when the detail text changed.

**Resolution:**
Scoped the detail view identity to the selected work item ID so selecting a different item reconstructs the detail scroll view at the top of the newly selected content.

**Files Affected:**
- `AgileCockpit/AgileCockpit/ContentView.swift`: Added selection-scoped identity to `WorkDetail` for dashboard status detail rendering.

**Evidence:**
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-14.
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitUITests` passed on 2026-06-14.

**Verification:**
1. Open a dashboard status drill-down with multiple work products.
2. Select one item and scroll the detail pane to the bottom.
3. Select a different item.
4. Confirm the detail pane resets to the top of the newly selected text.

**Related Items:**
- EP-017
- SP-017
- T-0089

*Last Updated: 2026-06-14 (I-0003 and I-0004 resolved pending human verification)*
