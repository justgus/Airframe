# I-0005 through I-0006: SP-021 Verified Issues

**Status:** Resolved - Verified
**Sprint:** SP-021
**Epic:** EP-018
**Date Verified:** 2026-06-16
**Verified By:** Human via GitHub

| Issue  | GitHub Issue | Title                                                             | Severity | Status |
| ------ | ------------ | ----------------------------------------------------------------- | -------- | ------ |
| I-0005 | #111 | AgileCockpit header emphasizes app identity over project identity | Medium   | Resolved - Verified |
| I-0006 | #112 | AgileCockpit cannot run concurrent project instances              | High     | Resolved - Verified |

## I-0005: AgileCockpit header emphasizes app identity over project identity

**Status:** Resolved - Verified
**GitHub Issue:** #111
**Platform:** macOS
**Component:** AgileCockpit
**Severity:** Medium
**Epic:** EP-018
**Sprint:** SP-021
**Date Identified:** 2026-06-16
**Fix Date:** 2026-06-16
**Verification Date:** 2026-06-16

**Description:**
The AgileCockpit header gave the application identity the most prominent placement even when the user was reviewing a specific live project workspace.

**Expected Behavior:**
The current project name or repository should be the most prominent text in the AgileCockpit header. The app name should remain visible but secondary.

**Actual Behavior:**
The header made the app identity more prominent than the active project identity, making it harder to distinguish Airframe and Telemetrix live demo windows.

**Root Cause Analysis:**
The header used the static app name as the title and displayed project identity as secondary metadata.

**Resolution:**
The header now uses the configured project name as the primary title, shows the repository immediately underneath, and moves the app/workspace identity to secondary caption text.

**Files Affected:**
- `AgileCockpit/AgileCockpit/ContentView.swift`: Made project identity the primary header text and added secondary app/workspace identity text.
- `AgileCockpit/AgileCockpitTests/AgileCockpitTests.swift`: Added coverage for the secondary app/workspace status text.

**Evidence:**
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests/agileCockpitSampleDashboardContextIsAvailable -only-testing:AgileCockpitTests/agileCockpitConfiguredDashboardUsesLiveProjectContext -only-testing:AgileCockpitTests/agileCockpitConfiguredDashboardUsesGitHubIssuesBackend` passed on 2026-06-16.
- GitHub Issue #111 carried `status-verified` on 2026-06-16.

**Verification:**
- Human verified this issue in GitHub on 2026-06-16.

**Related Items:**
- EP-018
- SP-021
- I-0006

---

## I-0006: AgileCockpit cannot run concurrent project instances

**Status:** Resolved - Verified
**GitHub Issue:** #112
**Platform:** macOS
**Component:** AgileCockpit / LiveDemo launcher
**Severity:** High
**Epic:** EP-018
**Sprint:** SP-021
**Date Identified:** 2026-06-16
**Fix Date:** 2026-06-16
**Verification Date:** 2026-06-16

**Description:**
Launching AgileCockpit from the Telemetrix project and then from the Airframe project could still show Telemetrix data, and an already running Telemetrix instance prevented a separate Airframe cockpit from being brought up independently.

**Expected Behavior:**
Airframe and Telemetrix should be able to run AgileCockpit at the same time as separate visible instances. Each instance should read and display only its own project-local workspace configuration and backend data.

**Actual Behavior:**
The second launch could reuse or display the first project's data, and the app could not reliably present both projects on screen simultaneously.

**Root Cause Analysis:**
The project-local launcher used `open --fresh` on the shared AgileCockpit bundle. Launch Services can still target the existing bundle identity, so the second project launch could reuse the already running app process instead of creating a separate process with the new project environment.

**Resolution:**
The launcher now uses `open -n --fresh` so each project-local launch requests a new app instance with that launcher's `AIRFRAME_CONFIG_PATH` and `AIRFRAME_STORE_PATH`.

**Files Affected:**
- `.airframe/scripts/ac-launch-cockpit.sh`: Added `-n` to force a new app instance for each project-local launch.
- `../Telemetrix/.airframe/scripts/ac-launch-cockpit.sh`: Human applied the same `open -n --fresh` launcher fix.
- `AgileCockpit/AgileCockpit/ContentView.swift`: Made project identity more visible so concurrent instances are easier to distinguish.

**Evidence:**
- `bash -n .airframe/scripts/ac-launch-cockpit.sh` passed on 2026-06-16.
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests/agileCockpitSampleDashboardContextIsAvailable -only-testing:AgileCockpitTests/agileCockpitConfiguredDashboardUsesLiveProjectContext -only-testing:AgileCockpitTests/agileCockpitConfiguredDashboardUsesGitHubIssuesBackend` passed on 2026-06-16.
- GitHub Issue #112 carried `status-verified` on 2026-06-16.

**Verification:**
- Human verified this issue in GitHub on 2026-06-16.

**Related Items:**
- EP-018
- SP-021
- I-0005
