# Verified Tasks T-0036 through T-0040

**Date Verified:** 2026-06-04
**Verified By:** HumanOwner
**Sprint:** SP-007
**Epic:** EP-007

## Tasks

| Task | GitHub Issue | Title | Status |
| ---- | ------------ | ----- | ------ |
| T-0036 | #36 | Implement GitHub backend capability map and configuration | Implemented - Verified |
| T-0037 | #37 | Implement GitHub issue/task mapping | Implemented - Verified |
| T-0038 | #38 | Implement GitHub sprint/epic/evidence mapping | Implemented - Verified |
| T-0039 | #39 | Integrate GitHub backend with AICockpit | Implemented - Verified |
| T-0040 | #40 | Integrate GitHub backend status with AgileCockpit | Implemented - Verified |

## Verification Evidence

- Human verified all Tasks in SP-007 on 2026-06-04.
- `swift test --package-path AirframeCore` passed during SP-007 implementation verification.
- `swift test --package-path AICockpit` passed during SP-007 implementation verification.
- `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test` passed during SP-007 implementation verification.
- AirframeCore tests covered GitHub capability/configuration, issue/task mapping, sprint/epic/evidence mapping, and GitHub fixture backend behavior.
- AICockpit tests covered canonical commands against the GitHub fixture backend.
- AgileCockpit tests covered GitHub fixture-backed dashboard data and backend status display.

## Notes

SP-007 is fully verified and eligible for sprint closeout.
