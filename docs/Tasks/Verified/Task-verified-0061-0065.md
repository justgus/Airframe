# Verified Tasks T-0061 through T-0065

**Date Verified:** 2026-06-09
**Sprint:** SP-012
**Epic:** EP-012
**Verified By:** Human

## Tasks

| Task | GitHub Issue | Title | Status |
| ---- | ------------ | ----- | ------ |
| T-0061 | #61 | Define project-local demo artifact layout | Implemented - Verified |
| T-0062 | #65 | Install aicockpit into the project-local demo layout | Implemented - Verified |
| T-0063 | #64 | Install AgileCockpit.app into the project-local demo layout | Implemented - Verified |
| T-0064 | #63 | Document project-local demo installation and verification | Implemented - Verified |
| T-0065 | #62 | Verify project-local installation without manual Cockpit launch | Implemented - Verified |

## Verification Summary

The user verified SP-012 and its tasks on 2026-06-09. GitHub issues #61 through #65 were labeled `status-verified` and closed.

## Evidence

- `scripts/install-live-demo.sh` passed on 2026-06-09 and produced project-local artifacts under `demos/LiveDemo/`.
- `scripts/verify-sp012.sh` passed on 2026-06-09.
- Installed CLI configuration diagnostics reported backend `github-issues` at `justgus/Airframe`.
- Installed CLI live project summary reported backend `github-issues`, `totalWorkItemCount: 65`, and `verifiedTaskCount: 60`.
- AgileCockpit automated tests passed under `demos/LiveDemo/DerivedData`.
