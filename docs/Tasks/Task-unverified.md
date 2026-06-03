# Unverified Tasks

Tasks listed here are implemented but not yet human-verified.

Currently: **0 unverified Tasks**

---

No Tasks are awaiting human verification.

## Verification Evidence

- `swift test --package-path AirframeCore` passed.
- `swift test --package-path AICockpit` passed.
- `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test` passed.
- `swift run --package-path AICockpit aicockpit --help` passed.
- `swift run --package-path AICockpit aicockpit context` passed.
- End-to-end local CLI smoke flow passed for task proposal, next task JSON, evidence attachment, and ready-for-verification JSON.

*Last Updated: 2026-06-03 (SP-005 verified)*
