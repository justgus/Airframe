# Unverified Tasks

Tasks listed here are implemented but not yet human-verified.

Currently: **5 unverified Tasks**

---

## T-0066 through T-0070: SP-013 Controlled GitHub Mutations

**Status:** Implemented - Not Verified
**Sprint:** SP-013
**Epic:** EP-013
**Date Implemented:** 2026-06-09
**Date Verified:** TBD

| Task | GitHub Issue | Title | Status |
| ---- | ------------ | ----- | ------ |
| T-0066 | #66 | Define controlled GitHub mutation authority contract | Implemented - Not Verified |
| T-0067 | #67 | Add GitHub issue comment mutation support | Implemented - Not Verified |
| T-0068 | #68 | Add controlled GitHub status label transition support | Implemented - Not Verified |
| T-0069 | #69 | Wire explicit mutation commands and UI affordances | Implemented - Not Verified |
| T-0070 | #70 | Verify controlled mutation safety and documentation | Implemented - Not Verified |

## Implementation Summary

- Added controlled GitHub mutation approval/result models and backend capability flags.
- Extended the GitHub issue transport with explicit comment and status-label mutation operations.
- Added approval-gated GitHub issue comment, evidence comment, and status label transition APIs.
- Added explicit AICockpit commands for `github comment`, `github evidence-comment`, and `github status`.
- Documented the controlled mutation contract in [../Controlled-GitHub-Mutations.md](../Controlled-GitHub-Mutations.md).
- Added `scripts/verify-sp013.sh` for controlled mutation safety verification.

## Verification Evidence

- `scripts/verify-sp013.sh` passed on 2026-06-09.
- `swift test --package-path AirframeCore` passed on 2026-06-09.
- `swift test --package-path AICockpit` passed on 2026-06-09.
- `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test` passed on rerun 2026-06-09.
- Missing approval check for `aicockpit github comment` failed before live GitHub lookup/write with a confirmation requirement.
- T-0061 through T-0065 were human-verified on 2026-06-09 and moved to [Verified/Task-verified-0061-0065.md](Verified/Task-verified-0061-0065.md).
- T-0056 through T-0060 were human-verified on 2026-06-08 and moved to [Verified/Task-verified-0056-0060.md](Verified/Task-verified-0056-0060.md).

---

*Last Updated: 2026-06-09 (T-0066 through T-0070 implemented for SP-013)*
