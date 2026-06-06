# Unverified Tasks

Tasks listed here are implemented but not yet human-verified.

Currently: **5 unverified Tasks**

---

## SP-010 Implemented Tasks Awaiting Verification

**Date Implemented:** 2026-06-06  
**Sprint:** SP-010  
**Epic:** EP-010  
**Implemented By:** Codex / AICockpit Agent

| Task | GitHub Issue | Title | Status |
| ---- | ------------ | ----- | ------ |
| T-0051 | #51 | Define live GitHub issue transport and failure contract | Implemented - Not Verified |
| T-0052 | #52 | Implement read-only GitHub issue listing backend | Implemented - Not Verified |
| T-0053 | #53 | Implement GitHub issue-to-work-record parsing | Implemented - Not Verified |
| T-0054 | #54 | Wire github-issues into AICockpit commands | Implemented - Not Verified |
| T-0055 | #55 | Verify read-only GitHub adapter behavior and docs | Implemented - Not Verified |

## Implementation Summary

- Added read-only `github-issues` backend capabilities.
- Added a `gh` CLI transport for listing and inspecting GitHub issues.
- Added `AirframeGitHubIssuesBackend` over canonical AirframeCore backend APIs.
- Updated GitHub issue mapping to prefer explicit Airframe body metadata over issue-number fallback.
- Preserved verified Airframe status for closed GitHub issues carrying `status-verified`.
- Wired AICockpit read-only commands to `github-issues`.
- Kept mutating AICockpit commands unavailable on `github-issues` with clear read-only backend errors.

## Verification Evidence

- `swift test --package-path AirframeCore` passed with 38 tests.
- `swift test --package-path AICockpit` passed with 20 tests.
- `swift run --package-path AICockpit aicockpit project summary --config .airframe/airframe-workspace.json --backend github-issues --output json` passed and reported `github-issues`, 55 total work items, 5 active tasks, and 50 verified tasks.
- `swift run --package-path AICockpit aicockpit task packet T-0045 --config .airframe/airframe-workspace.json --backend github-issues` passed and returned a GitHub-backed packet for `T-0045`.
- `swift run --package-path AICockpit aicockpit task packet T-0051 --config .airframe/airframe-workspace.json --backend github-issues` passed and returned the active SP-010 task packet sections from GitHub issue #51.

## Human Verification Steps

1. Review the implementation diff for AirframeCore and AICockpit.
2. Re-run `swift test --package-path AirframeCore`.
3. Re-run `swift test --package-path AICockpit`.
4. Re-run the live read-only `aicockpit project summary` command with `--backend github-issues`.
5. Re-run a live read-only `aicockpit task packet` command for one closed verified task and one active SP-010 task.
6. Confirm no GitHub mutation commands were added to the `github-issues` backend.

---

*Last Updated: 2026-06-06 (SP-010 implemented and awaiting human verification)*
