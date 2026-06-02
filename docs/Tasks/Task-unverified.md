# Unverified Tasks

Tasks listed here are implemented but not yet human-verified.

Currently: **4 unverified Tasks**

---

| Task | GitHub Issue | Title | Epic | Sprint | Status |
| ---- | ------------ | ----- | ---- | ------ | ------ |
| T-0014 | #14 | Implement workflow transition evaluator | EP-003 | SP-003 | Implemented - Not Verified |
| T-0015 | #15 | Implement audit event service | EP-003 | SP-003 | Implemented - Not Verified |
| T-0016 | #16 | Implement AICockpit denied-operation output | EP-003 | SP-003 | Implemented - Not Verified |
| T-0017 | #17 | Implement AgileCockpit authority and audit display | EP-003 | SP-003 | Implemented - Not Verified |

## Verification Evidence

- `swift test --package-path AirframeCore` passed.
- `swift test --package-path AICockpit` passed.
- `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test` passed.

*Last Updated: 2026-06-02 (SP-003 implementation complete)*
