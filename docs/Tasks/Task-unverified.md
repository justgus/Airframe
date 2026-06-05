# Unverified Tasks

Tasks listed here are implemented but not yet human-verified.

Currently: **5 unverified Tasks**

---

## SP-009: Live Demo Runtime Configuration

| Task | GitHub Issue | Title | Status |
| ---- | ------------ | ----- | ------ |
| T-0046 | #46 | Define live demo workspace configuration contract | Implemented - Not Verified |
| T-0047 | #47 | Implement AICockpit runtime configuration selection | Implemented - Not Verified |
| T-0048 | #48 | Implement AgileCockpit runtime configuration selection | Implemented - Not Verified |
| T-0049 | #49 | Add Airframe live demo project configuration and usage docs | Implemented - Not Verified |
| T-0050 | #50 | Verify Slice 1 live project identity and fallback behavior | Implemented - Not Verified |

## Implementation Summary

- T-0046 added the reusable Airframe runtime configuration resolver and a tracked `.airframe/airframe-workspace.json` for the Airframe live demo.
- T-0047 wired AICockpit to load runtime config from `--config`, `AIRFRAME_CONFIG_PATH`, or `.airframe/airframe-workspace.json`, and store path from `--store`, `AIRFRAME_STORE_PATH`, or `.airframe/airframe-local-backend.json`.
- T-0048 wired AgileCockpit startup/model construction to try runtime configuration before embedded sample fallback.
- T-0049 updated live demo and AICockpit usage documentation with concrete Slice 1 commands and boundaries.
- T-0050 captured direct verification evidence for Core, CLI, app, and live project identity checks.

## Verification Evidence

- `swift test --package-path AirframeCore` passed on 2026-06-04.
- `swift test --package-path AICockpit` passed on 2026-06-04.
- `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test` passed on 2026-06-04.
- `swift run --package-path AICockpit aicockpit context --config .airframe/airframe-workspace.json` reported:
  - workspace `Airframe Live Demo`;
  - project `Agile Airframe`;
  - repository `justgus/Airframe`;
  - backend `github-fixture at justgus/Airframe`;
  - active epic `EP-009`;
  - active sprint `SP-009`.
- `swift run --package-path AICockpit aicockpit config diagnose --config .airframe/airframe-workspace.json --output json` reported `status` as `ok`.
- `swift run --package-path AICockpit aicockpit context` from the repository root picked up `.airframe/airframe-workspace.json` and reported the same live project identity.

## Residual Risk

- Slice 1 intentionally uses `github-fixture`; live GitHub issue reads remain out of scope until the next implementation slice.
- AgileCockpit runtime launch with environment variables is covered by model tests and app startup wiring; no manual app launch verification was performed in this pass.

---

*Last Updated: 2026-06-04 (SP-009 implemented and awaiting human verification)*
