# Unverified Tasks

Tasks listed here are implemented but not yet human-verified.

Currently: **5 unverified Tasks**

---

## T-0061 through T-0065: SP-012 Project-Local Installation

**Status:** Implemented - Not Verified
**Sprint:** SP-012
**Epic:** EP-012
**Date Implemented:** 2026-06-09
**Date Verified:** TBD

| Task | GitHub Issue | Title | Status |
| ---- | ------------ | ----- | ------ |
| T-0061 | #61 | Define project-local demo artifact layout | Implemented - Not Verified |
| T-0062 | #65 | Install aicockpit into the project-local demo layout | Implemented - Not Verified |
| T-0063 | #64 | Install AgileCockpit.app into the project-local demo layout | Implemented - Not Verified |
| T-0064 | #63 | Document project-local demo installation and verification | Implemented - Not Verified |
| T-0065 | #62 | Verify project-local installation without manual Cockpit launch | Implemented - Not Verified |

## Implementation Summary

- Added `scripts/install-live-demo.sh` to build `aicockpit` with SwiftPM and copy it to `demos/LiveDemo/bin/aicockpit`.
- Added `scripts/install-live-demo.sh` to build `AgileCockpit.app` with Xcode into project-local DerivedData and copy it to `demos/LiveDemo/Applications/AgileCockpit.app`.
- Added `scripts/verify-sp012.sh` to install artifacts, check artifact presence, run installed CLI diagnostics, run an installed CLI live `github-issues` project summary, and run AgileCockpit automated tests.
- Added `demos/LiveDemo/README.md` with layout, install, verification, and deferred manual launch instructions.
- Updated `.gitignore` so generated demo artifacts and build products remain project-local but untracked.

## Verification Evidence

- `scripts/install-live-demo.sh` passed on 2026-06-09 and produced:
  - `demos/LiveDemo/bin/aicockpit`
  - `demos/LiveDemo/Applications/AgileCockpit.app`
- `scripts/verify-sp012.sh` passed on 2026-06-09.
- Installed CLI configuration diagnostics reported backend `github-issues` at `justgus/Airframe`.
- Installed CLI live project summary reported backend `github-issues`, `totalWorkItemCount: 65`, and `verifiedTaskCount: 60`.
- AgileCockpit automated tests passed under `demos/LiveDemo/DerivedData`.
- T-0056 through T-0060 were human-verified on 2026-06-08 and moved to [Verified/Task-verified-0056-0060.md](Verified/Task-verified-0056-0060.md).

---

*Last Updated: 2026-06-09 (T-0061 through T-0065 implemented for SP-012)*
