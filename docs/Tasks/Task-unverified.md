# Unverified Tasks

Tasks listed here are implemented but not yet human-verified.

Currently: **5 unverified Tasks**

---

## T-0086: Reconcile Agile artifact workflow documentation and process guardrails

**Status:** Implemented - Not Verified
**GitHub Issue:** #86
**Component:** Documentation / Process
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-017
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-12
**Date Verified:** TBD

**Implementation Notes:**
- Updated AGENTS.md with artifact workflow labels and implementation preflight guardrails.
- Updated Epic, Sprint, Task, and Issue guideline documents for Sprint Backlog, Epic Backlog, Backlog Issues, and display aliases.
- Preserved the pre-sprint draft work as reviewed under active SP-017 tasks.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-12.
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-12.
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitUITests` passed on 2026-06-12.

## T-0087: Define artifact-specific status presentation model

**Status:** Implemented - Not Verified
**GitHub Issue:** #87
**Component:** AirframeCore
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-017
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-12
**Date Verified:** TBD

**Implementation Notes:**
- Added artifact-specific dashboard status summary models in AirframeCore.
- Added status rows for Epics, Sprints, Tasks, and Issues with symbols and display titles.
- Extended workflow status vocabulary and backend status mapping for the required workflow states.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-12 with 44 tests.

## T-0088: Replace dashboard metrics with workflow status tiles

**Status:** Implemented - Not Verified
**GitHub Issue:** #88
**Component:** AgileCockpit
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-017
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-12
**Date Verified:** TBD

**Implementation Notes:**
- Replaced the dashboard metrics panel with Epics, Sprints, Tasks, and Issues status tiles.
- Rendered status text smaller than tile labels.
- Displayed status symbols beside each status label.
- Tightened the status tile row layout so the four artifact tiles fit in a top-aligned row in the default dashboard layout.
- Replaced two-letter status designations with the workflow status symbols shown in the artifact documents.
- Included closed Epic and Sprint artifact files in dashboard status tile counts so prior closed EP-001 through EP-016 and SP-001 through SP-016 appear in the Closed rows.

**Evidence:**
- AgileCockpit unit tests passed on 2026-06-12.
- AgileCockpit UI tests passed on 2026-06-12.
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitUITests` passed on 2026-06-12 after the status symbol and layout corrections.
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-12 after adding the closed Epic/Sprint artifact regression.

## T-0089: Add interactive dashboard status drill-down

**Status:** Implemented - Not Verified
**GitHub Issue:** #89
**Component:** AgileCockpit
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-017
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-12
**Date Verified:** TBD

**Implementation Notes:**
- Status rows open a drill-down popover with matching item IDs and titles.
- Selecting an item displays rendered work item details.
- Drill-down is backed by the shared AirframeCore status summary model.
- AgileCockpit now supplements backend Task/Issue records with local Epic and Sprint artifact records for dashboard status tiles, so GitHub Issues mode can show active and backlog Epic/Sprint counts even when Epics and Sprints are represented by labels and Markdown artifacts rather than standalone GitHub issues.
- Updated the live workspace configuration to identify EP-017 and SP-017 as the active Epic and Sprint.
- The drill-down popover dismisses on outside click using native popover behavior.
- The drill-down item list is scrollable for large result sets.
- The selected item highlight now follows the selected work item when a different row is clicked.

**Evidence:**
- AgileCockpit unit tests passed on 2026-06-12.
- AgileCockpit UI smoke test covered the dashboard status tile presentation on 2026-06-12.
- Added a regression test proving local Epic/Sprint artifact records contribute to dashboard status tile counts.
- `demos/LiveDemo/bin/aicockpit context --config .airframe/airframe-workspace.json` reports Active Epic EP-017 and Active Sprint SP-017.
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-12 after the popover and drill-down list fixes.
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitUITests` passed on 2026-06-12 after the popover and drill-down list fixes.

## T-0090: Verify dashboard workflow and integrate draft patch

**Status:** Implemented - Not Verified
**GitHub Issue:** #90
**Component:** Verification
**Priority:** Medium
**Epic:** EP-017
**Sprint Assigned:** SP-017
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-12
**Date Verified:** TBD

**Implementation Notes:**
- Reconciled the pre-sprint draft dashboard/status patch under active SP-017 scope.
- Added and verified the LiveDemo post-build copy script.
- The AgileCockpit Xcode target now installs LiveDemo artifacts by default after build; set `AIRFRAME_SKIP_LIVE_DEMO_INSTALL=1` only when the install should be skipped.
- Verified `AgileCockpit.app` and `aicockpit` were copied to the requested LiveDemo locations.
- Updated LiveDemo app signing so copied executable files are signed consistently before the bundle is signed.
- For default ad-hoc LiveDemo signing, the copy script now omits hardened runtime signing options so the local debug dylib can load.
- Updated the LiveDemo copy step to strip test plug-ins and XCTest/Testing frameworks before signing the copied demo app.

**Evidence:**
- `AIRFRAME_INSTALL_LIVE_DEMO=1 xcodebuild build -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -configuration Debug` passed on 2026-06-12.
- `xcodebuild build -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -configuration Debug` passed on 2026-06-12 and installed LiveDemo artifacts without requiring `AIRFRAME_INSTALL_LIVE_DEMO`.
- `demos/LiveDemo/Applications/AgileCockpit.app` exists after the build.
- `demos/LiveDemo/bin/aicockpit` exists and is executable after the build.
- `codesign --verify --deep --strict --verbose=4 demos/LiveDemo/Applications/AgileCockpit.app` passed on 2026-06-12.
- `open -n demos/LiveDemo/Applications/AgileCockpit.app` launched the installed LiveDemo app on 2026-06-12; `pgrep -fl AgileCockpit` showed the process running from the LiveDemo app path.
- `xcodebuild build -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -configuration Debug` passed on 2026-06-12 after stripping test-only bundles from the LiveDemo copy.
- `xcodebuild build -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -configuration Debug` passed on 2026-06-12 after the drill-down popover and closed-artifact dashboard updates.
- `codesign --verify --deep --strict --verbose=4 demos/LiveDemo/Applications/AgileCockpit.app` passed on 2026-06-12 after the latest LiveDemo install.
- `open -n demos/LiveDemo/Applications/AgileCockpit.app` launched the updated installed LiveDemo app on 2026-06-12; `pgrep -fl AgileCockpit` showed it running from the LiveDemo app path.

---

T-0081 through T-0085 were human-verified on 2026-06-11 and moved to [Verified/Task-verified-0081-0085.md](Verified/Task-verified-0081-0085.md).

*Last Updated: 2026-06-12 (T-0086 through T-0090 implemented pending human verification)*
