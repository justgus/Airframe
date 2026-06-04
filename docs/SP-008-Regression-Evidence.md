# SP-008 Regression Evidence

**Date:** 2026-06-04
**Sprint:** SP-008
**Epic:** EP-008

## Commands

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

## Coverage Summary

| Area | Evidence |
| ---- | -------- |
| AirframeCore | Domain, authority, workflow, audit, local backend, GitHub fixture mapping, dashboard summaries, human verification actions, and configuration diagnostics tests. |
| AICockpit | Help/context commands, proposal commands, task packet, evidence, ready transition, GitHub fixture routing, configuration diagnostics, and JSON error envelope tests. |
| AgileCockpit | Core-backed dashboard model tests, verification action tests, sprint/epic data tests, backend status tests, and UI smoke/accessibility identifier tests. |

## Result

Regression evidence is considered current when all commands above pass from the repository root.
