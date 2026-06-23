# I-0007: SP-028 Verified Issue

**Status:** Resolved - Verified
**Sprint:** SP-028
**Epic:** EP-020
**Date Verified:** 2026-06-18
**Verified By:** Human

| Issue  | GitHub Issue | Title                                                             | Severity | Status |
| ------ | ------------ | ----------------------------------------------------------------- | -------- | ------ |
| I-0007 | #132 | Verification tab can stall or fail silently while loading queue details | High | Resolved - Verified |

## I-0007: Verification tab can stall or fail silently while loading queue details

**Status:** Resolved - Verified
**GitHub Issue:** #132
**Platform:** macOS
**Component:** AgileCockpit
**Severity:** High
**Epic:** EP-020
**Sprint:** SP-028
**Date Identified:** 2026-06-18
**Fix Date:** 2026-06-18
**Verification Date:** 2026-06-18

**Description:**
The AgileCockpit Verification tab sometimes did not display promptly. When many Tasks were waiting for verification, the Verification Detail panel could take time to render, making the UI appear sluggish. The Verification Queue load could also fail quietly. Verification actions could also appear to block after Accept, Reject, or Request More Evidence was clicked, leaving the user uncertain whether the command was accepted.

**Expected Behavior:**
AgileCockpit should show an explicit Loading panel while the Verification Queue and detail data are loading. If loading fails, the app should show a clear Load Failed panel with error context and a Reload action.

After the user clicks Accept, Reject, or Request More Evidence, AgileCockpit should immediately acknowledge the click with visible pending feedback and disable or otherwise guard duplicate submission until the action completes. If the action fails, the UI should show a clear failure state instead of failing silently.

Reject and Request More Evidence should allow the reviewer to submit a comment with the action.

**Resolution:**
Added explicit Verification Queue, Verification Detail, and Verification Action states to AgileCockpit. The Verification tab now shows Loading and Load Failed panels with Reload behavior instead of silently falling through to an empty detail state. Verification detail packet loading no longer happens synchronously inside SwiftUI rendering. Accept, Reject, and Request More Evidence now show immediate pending feedback and visible failure state. Reject and Request More Evidence can include a reviewer comment, which is attached as evidence when the backend supports evidence attachment.

**Files Affected:**
- `AgileCockpit/AgileCockpit/ContentView.swift`
- `AgileCockpit/AgileCockpitTests/AgileCockpitTests.swift`

**Evidence:**
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-18.
- `xcodebuild test -quiet -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitUITests` passed on 2026-06-18.
- `swift test --package-path AirframeCore` passed on 2026-06-18 with 69 tests.
- `swift test --package-path AICockpit` passed on 2026-06-18 with 31 tests.
- `git diff --check` passed on 2026-06-18.
- GitHub Issue #132 carried `status-verified` after human verification on 2026-06-18.

**Verification:**
- Human verified I-0007 on 2026-06-18.

**Related Items:**
- EP-020
- SP-028
