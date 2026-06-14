# Unverified Tasks

Tasks listed here are implemented but not yet human-verified.

Currently: **15 unverified Tasks**

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

## T-0091: Define AICockpit work item mutation command contract

**Status:** Implemented - Not Verified
**GitHub Issue:** #91
**Component:** AICockpit / Documentation
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-018
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-14
**Date Verified:** TBD

**Rationale:**
AICockpit needs explicit command contracts for creating and updating work items locally and on GitHub.

**Acceptance Criteria:**
1. Commands are defined for creating and updating Tasks, Issues, Sprints, and Epics.
2. Local and GitHub behavior is specified.
3. Approval and authority requirements are specified.
4. AICockpit is explicitly prohibited from applying Verified to Tasks or Issues.

**Implementation Notes:**
- Added `AICockpit/docs/MutationCommandContract.md` defining create, update, and status command surfaces for Tasks, Issues, Sprints, and Epics.
- Documented local artifact write behavior and live GitHub issue/label mutation behavior.
- Documented live GitHub approval requirements with `--approve --approved-by name`.
- Explicitly rejected Task/Issue Verified, Sprint Closed, Epic Closed, policy configuration, destructive, and human-only acceptance operations for AICockpit.
- Linked the mutation command contract from `AICockpit/docs/AgentUsage.md`.

**Evidence:**
- `swift test --package-path AICockpit` passed on 2026-06-14.
- `git diff --check` passed on 2026-06-14.

## T-0092: Implement AICockpit local work item mutation support

**Status:** Implemented - Not Verified
**GitHub Issue:** #92
**Component:** AICockpit / AirframeCore
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-018
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-14
**Date Verified:** TBD

**Rationale:**
Agents need local mutation capability that preserves AirframeCore workflow policy and local artifact consistency.

**Acceptance Criteria:**
1. AICockpit can create local Tasks, Issues, Sprints, and Epics.
2. AICockpit can update allowed local work item fields and statuses.
3. Invalid transitions are rejected through AirframeCore.
4. Attempts to apply Task or Issue Verified are rejected.

**Implementation Notes:**
- Added record-level update support to the Airframe backend protocol and local filesystem backend.
- Added AICockpit `create`, `update`, and `status` commands for Tasks and Issues.
- Preserved workflow transition checks for status updates and rejected invalid transitions without mutation.
- Added explicit human-only rejection for Task and Issue verification commands.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-14.
- `swift test --package-path AICockpit` passed on 2026-06-14.

## T-0093: Implement controlled GitHub work item mutation support

**Status:** Implemented - Not Verified
**GitHub Issue:** #93
**Component:** AICockpit / AirframeCore GitHub Backend
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-018
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-14
**Date Verified:** TBD

**Rationale:**
GitHub-backed projects need controlled creation and update of mapped GitHub Issues with auditability and explicit approval.

**Acceptance Criteria:**
1. AICockpit can create mapped GitHub Issues for Tasks and Issues with explicit approval.
2. AICockpit can update allowed GitHub metadata and labels with explicit approval.
3. GitHub status labels stay synchronized with local workflow status.
4. AICockpit rejects status-verified for Tasks and Issues, even with approval.

**Implementation Notes:**
- Added GitHub issue creation and update operations to the GitHub transport abstraction and CLI transport.
- Added controlled GitHub create/update methods that require `--approve --approved-by` before live mutation.
- Updated GitHub issue title, body, status labels, priority labels, sprint labels, and epic labels from Airframe records.
- Routed AICockpit Task/Issue create, update, and status commands to controlled GitHub backend methods when `--backend github-issues` is selected.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-14.
- `swift test --package-path AICockpit` passed on 2026-06-14.

## T-0094: Add AICockpit Sprint and Epic planning mutation support

**Status:** Implemented - Not Verified
**GitHub Issue:** #94
**Component:** AICockpit / AirframeCore
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-018
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-14
**Date Verified:** TBD

**Rationale:**
Planning work should be manageable through AICockpit without granting human-only closure authority.

**Acceptance Criteria:**
1. AICockpit can create and update Sprint backlog and Planning records.
2. AICockpit can create and update Epic Proposed, Draft, Backlog, and Active records where policy allows.
3. AICockpit cannot perform human-only Sprint or Epic closure.

**Implementation Notes:**
- Allowed the local backend to store Sprint and Epic work records.
- Added AICockpit `sprint create`, `sprint update`, `sprint status`, `epic create`, `epic update`, and `epic status` commands.
- Supported Sprint Backlog, Planning, Active, and Review statuses.
- Supported Epic Proposed, Draft, Backlog, Active, and Complete statuses.
- Rejected Sprint Closed and Epic Closed through AICockpit as human-only closure operations.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-14.
- `swift test --package-path AICockpit` passed on 2026-06-14.

## T-0095: Verify AICockpit mutation authority boundaries

**Status:** Implemented - Not Verified
**GitHub Issue:** #95
**Component:** Verification
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-018
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-14
**Date Verified:** TBD

**Rationale:**
AICockpit mutation support must prove it can do allowed planning work and cannot bypass human-only authority.

**Acceptance Criteria:**
1. Tests prove local create/update commands work for allowed artifacts.
2. Tests prove GitHub create/update commands require explicit approval.
3. Tests prove AICockpit cannot verify Tasks or Issues locally or on GitHub.
4. Tests prove human-only Sprint/Epic closure remains blocked.

**Implementation Notes:**
- Added AICockpit tests for local Task and Issue create/update/status commands.
- Added AICockpit tests for Sprint and Epic planning create commands.
- Added tests proving invalid workflow transitions do not mutate records.
- Added tests proving Task/Issue verification and Sprint/Epic closure are rejected by AICockpit.
- Added AirframeCore GitHub backend tests proving approval-gated create/update behavior and no transport mutation before approval.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-14.
- `swift test --package-path AICockpit` passed on 2026-06-14.

## T-0096: Define AgileCockpit human mutation authority contract

**Status:** Implemented - Not Verified
**GitHub Issue:** #96
**Component:** AgileCockpit / Documentation
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-019
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-14
**Date Verified:** TBD

**Rationale:**
If AICockpit cannot apply Verified, AgileCockpit must own the human-facing verification mutation path.

**Acceptance Criteria:**
1. AgileCockpit authority for Task and Issue verification is documented.
2. Required human context and audit evidence are documented.
3. AICockpit and AgileCockpit mutation boundaries are explicit.

**Implementation Notes:**
- Added `AgileCockpit/docs/HumanVerificationMutationContract.md`.
- Documented AgileCockpit human authority for Task and Issue verification.
- Documented required human reviewer context, audit expectations, GitHub label effects, and AICockpit boundaries.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-14.
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-14.
- `swift test --package-path AICockpit` passed on 2026-06-14.

## T-0097: Implement AgileCockpit local verification mutations

**Status:** Implemented - Not Verified
**GitHub Issue:** #97
**Component:** AgileCockpit / AirframeCore
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-019
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-14
**Date Verified:** TBD

**Rationale:**
The human-facing app needs to apply local Verified status to Tasks and Issues under human authority.

**Acceptance Criteria:**
1. AgileCockpit can mark Tasks Implemented - Verified locally.
2. AgileCockpit can mark Issues Resolved - Verified locally.
3. Verification writes create audit evidence.

**Implementation Notes:**
- Wired AgileCockpit verification actions through AirframeCore human verification APIs.
- Preserved human-only authority evaluation for local Task and Issue verification.
- Added local verification regression coverage in AgileCockpit tests.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-14.
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-14.

## T-0098: Implement AgileCockpit controlled GitHub verification mutations

**Status:** Implemented - Not Verified
**GitHub Issue:** #98
**Component:** AgileCockpit / AirframeCore GitHub Backend
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-019
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-14
**Date Verified:** TBD

**Rationale:**
Human verification in AgileCockpit must synchronize status-verified to mapped GitHub Issues when using the GitHub backend.

**Acceptance Criteria:**
1. AgileCockpit can apply status-verified to mapped Task GitHub Issues through human context.
2. AgileCockpit can apply status-verified to mapped Issue GitHub Issues through human context.
3. GitHub verification writes produce audit evidence.

**Implementation Notes:**
- Added GitHub-backed human verification mutation support to the GitHub Issues backend.
- Required controlled mutations and human reviewer context before replacing GitHub status labels.
- Added in-memory transport tests covering GitHub label replacement and reviewer audit context.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-14.
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-14.

## T-0099: Add human verification UI flows for Tasks and Issues

**Status:** Implemented - Not Verified
**GitHub Issue:** #99
**Component:** AgileCockpit
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-019
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-14
**Date Verified:** TBD

**Rationale:**
Human users need an ergonomic route from verification candidates to verification action.

**Acceptance Criteria:**
1. Dashboard and verification views expose eligible Task verification actions.
2. Dashboard and verification views expose eligible Issue verification actions.
3. Verification UI distinguishes Implemented/Resolved from Verified.

**Implementation Notes:**
- Added Accept, Reject, and Request More Evidence actions for ready-for-verification dashboard items.
- Connected dashboard verification actions to the existing verification view mutation path.
- Kept the UI limited to human-facing AgileCockpit verification flows.

**Evidence:**
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-14.
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitUITests` passed on 2026-06-14.

## T-0100: Verify AICockpit and AgileCockpit authority separation

**Status:** Implemented - Not Verified
**GitHub Issue:** #100
**Component:** Verification
**Priority:** High
**Epic:** EP-017
**Sprint Assigned:** SP-019
**Date Requested:** 2026-06-12
**Date Implemented:** 2026-06-14
**Date Verified:** TBD

**Rationale:**
The system must prove agent-facing and human-facing mutation authority are separated end to end.

**Acceptance Criteria:**
1. Tests prove AICockpit cannot apply Task or Issue Verified.
2. Tests prove AgileCockpit can apply Task or Issue Verified through human context.
3. Tests prove audit records distinguish agent and human mutation paths.
4. Tests prove unauthorized Sprint/Epic closure remains blocked.

**Implementation Notes:**
- Added GitHub backend regression coverage proving LLM context cannot perform human verification.
- Retained AICockpit tests proving Task/Issue Verified and Sprint/Epic Closed statuses are rejected.
- Added AgileCockpit tests proving human reviewer context can perform permitted verification mutations.

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-14.
- `swift test --package-path AICockpit` passed on 2026-06-14.
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-14.

---

T-0081 through T-0085 were human-verified on 2026-06-11 and moved to [Verified/Task-verified-0081-0085.md](Verified/Task-verified-0081-0085.md).

*Last Updated: 2026-06-14 (T-0096 through T-0100 implemented pending human verification)*
