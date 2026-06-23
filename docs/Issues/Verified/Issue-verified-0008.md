# I-0008: SP-028 Verified Issue

**Status:** Resolved - Verified
**Sprint:** SP-028
**Epic:** EP-020
**Date Verified:** 2026-06-23
**Verified By:** Human

| Issue | GitHub Issue | Title | Severity | Status |
| ----- | ------------ | ----- | -------- | ------ |
| I-0008 | #133 | Canonical state cannot represent Review Sprints and backend label reconciliation | High | Resolved - Verified |

## I-0008: Canonical state cannot represent Review Sprints and backend label reconciliation

**Status:** Resolved - Verified
**GitHub Issue:** #133
**Platform:** macOS
**Component:** AirframeCore / AICockpit / AgileCockpit
**Severity:** High
**Epic:** EP-020
**Sprint:** SP-028
**Date Identified:** 2026-06-23
**Fix Date:** 2026-06-23
**Verification Date:** 2026-06-23

**Description:**
Agile Airframe canonical state could not fully represent Review Sprints, which made SP-017 and SP-018 unmanageable through the canonical path. Backend label drift also had preview-only diagnostics without an Apply Repair path, leaving projects on the old artifact layout without a supported reconciliation workflow.

**Expected Behavior:**
Canonical workflow state should represent Sprint Review status, preserve Review Sprint documentation, and expose backend label reconciliation repairs that can be previewed and applied through approved UI and CLI flows.

**Resolution:**
Added Review Sprint support to the canonical import and display paths, preserved legacy Markdown mutation helpers for migration, and implemented backend label reconciliation repair application through AirframeCore, AICockpit, and AgileCockpit.

**Files Affected:**
- `AirframeCore/Sources/AirframeCore/CanonicalDiagnostics.swift`
- `AirframeCore/Sources/AirframeCore/CanonicalStoreBackend.swift`
- `AirframeCore/Sources/AirframeCore/MarkdownArtifactImporter.swift`
- `AICockpit/Sources/AICockpitKit/AICockpitCommand.swift`
- `AgileCockpit/AgileCockpit/ContentView.swift`
- `AgileCockpit/AgileCockpitTests/AgileCockpitTests.swift`
- `AirframeCore/Tests/AirframeCoreTests/AirframeCoreTests.swift`

**Evidence:**
- `swift test --package-path AirframeCore` passed on 2026-06-23 with 72 tests.
- `swift test --package-path AICockpit` passed on 2026-06-23 with 31 tests.
- `xcodebuild test -project AgileCockpit/AgileCockpit.xcodeproj -scheme AgileCockpit -destination 'platform=macOS' -only-testing:AgileCockpitTests` passed on 2026-06-23.
- GitHub Issue #133 carried `status-verified` after human verification on 2026-06-23.

**Verification:**
- Human verified I-0008 on 2026-06-23.

**Related Items:**
- EP-020
- SP-017
- SP-018
- SP-028
