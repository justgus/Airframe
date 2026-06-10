# T-0071 through T-0075: SP-014 End-to-End Live Demo Rehearsal

**Status:** Implemented - Verified
**Sprint:** SP-014
**Epic:** EP-014
**Date Implemented:** 2026-06-10
**Date Verified:** 2026-06-10

| Task | GitHub Issue | Title | Status |
| ---- | ------------ | ----- | ------ |
| T-0071 | #71 | Define Slice 6 end-to-end demo script and success criteria | Implemented - Verified |
| T-0072 | #75 | Rehearse project-local AICockpit live GitHub workflow | Implemented - Verified |
| T-0073 | #72 | Rehearse AgileCockpit live project review workflow | Implemented - Verified |
| T-0074 | #74 | Verify controlled GitHub write demo with explicit approval | Implemented - Verified |
| T-0075 | #73 | Document final live demo runbook and rollback notes | Implemented - Verified |

## Implementation Summary

- Added [../../Live-Demo-Runbook.md](../../Live-Demo-Runbook.md) with Slice 6 install, read-only AICockpit, AgileCockpit, controlled write, verification, rollback, and known-limit steps.
- Added `scripts/verify-sp014.sh` for repeatable project-local Slice 6 rehearsal verification.
- Updated [../../../demos/LiveDemo/README.md](../../../demos/LiveDemo/README.md) to point at the SP-014 verification flow and runbook.
- Updated the GitHub CLI transport to avoid deadlocking when `gh issue list` emits output larger than a pipe buffer.
- Reinstalled project-local demo artifacts under `demos/LiveDemo/`.

## Verification Evidence

- Initial `scripts/verify-sp014.sh` run failed in sandbox because SwiftPM could not write to `~/.cache/clang/ModuleCache`; rerun was escalated for normal Swift/Xcode cache access.
- A live `gh issue list --repo justgus/Airframe --state all --limit 100 --json number,title,state,labels,body` check returned successfully, isolating the hang to AirframeCore's pipe handling.
- `scripts/verify-sp014.sh` passed on 2026-06-10 after the transport fix.
- `swift test --package-path AirframeCore` passed on 2026-06-10 with 42 Swift Testing tests.
- `swift test --package-path AICockpit` passed on 2026-06-10 with 21 Swift Testing tests.
- AgileCockpit tests passed through `scripts/verify-sp014.sh`; the xcodebuild test session reported 3 UI tests plus the AgileCockpit unit tests passed.
- The SP-014 automated verification checks the missing-approval controlled write failure path and does not perform an approved live GitHub mutation.

## Human Verification

The user verified T-0071 through T-0075 on 2026-06-10 and approved closing SP-014 and EP-014.
