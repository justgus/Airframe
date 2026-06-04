# Release Candidate Verification

This checklist is the SP-008 release-candidate verification baseline.

## Automated Verification

Run from the repository root:

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Optional convenience wrapper:

```sh
bash scripts/verify-sp008.sh
```

## Manual Checks

1. Confirm `aicockpit context` reports `SP-008`, `EP-008`, `github-fixture`, and `justgus/Airframe`.
2. Confirm `aicockpit config diagnose --output json` returns `configurationDiagnostics.status` as `ok`.
3. Confirm `aicockpit project summary --backend github-fixture --output json` includes `supportsGitHubIssues: true`.
4. Launch AgileCockpit and confirm the header shows `SP-008`, `EP-008`, and `github-fixture`.
5. Open the Verification section and confirm T-0042 review controls are available.

## Known Boundaries

- Live GitHub authentication and network API access are not implemented in this release-candidate baseline.
- The GitHub backend path is fixture-backed and verifies canonical mapping, provider capabilities, CLI routing, and app status display.
- AirframeCore remains the source of truth for workflow policy, authority checks, backend capabilities, configuration diagnostics, and canonical work records.

## Evidence Captured In SP-008

- AirframeCore configuration diagnostics tests.
- AICockpit CLI diagnostics and JSON error contract tests.
- AgileCockpit UI smoke assertions for launch, backend status, sprint context, and verification controls.
- Repeatable verification script at `scripts/verify-sp008.sh`.
