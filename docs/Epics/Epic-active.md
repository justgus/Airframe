# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

---

## EP-009: Live Demonstration Runtime Configuration

**Status:** Complete
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-04
**Target Close Date:** TBD
**Close Date:** TBD

**Goal:**
Enable Airframe to run against the live `justgus/Airframe` project configuration instead of only embedded sample data.

**Rationale:**
The live demonstration needs AICockpit and AgileCockpit to identify the same real project, local clone, repository slug, backend mode, and runtime store before read-only GitHub issue access is implemented.

**Scope:**
- Define the live Airframe workspace configuration contract.
- Add runtime configuration selection for AICockpit.
- Add runtime configuration selection for AgileCockpit.
- Add project-local live demo configuration and usage documentation.
- Verify that both apps report the live Airframe project identity without GitHub writes.

**Out of Scope:**
- Live GitHub issue read adapter implementation.
- GitHub issue creation, comments, label updates, or issue closure.
- Global app or CLI installation.
- Replacing the embedded sample fallback.

**Acceptance Criteria:**
1. AICockpit can load project context from `--config`, `AIRFRAME_CONFIG_PATH`, or default `.airframe/airframe-workspace.json`.
2. AICockpit can load backend store path from `--store`, `AIRFRAME_STORE_PATH`, or default `.airframe/airframe-local-backend.json`.
3. AgileCockpit can launch against a configured live Airframe project without relying on embedded sample data.
4. Existing sample behavior remains available as fallback for tests and development.
5. Configuration diagnostics identify the selected project, repository, backend kind, and backend location.
6. Slice 1 verification performs no GitHub remote mutations.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-009 | Implement live demo runtime configuration for AICockpit and AgileCockpit. | Review |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0046 | Define live demo workspace configuration contract | Implemented - Not Verified |
| T-0047 | Implement AICockpit runtime configuration selection | Implemented - Not Verified |
| T-0048 | Implement AgileCockpit runtime configuration selection | Implemented - Not Verified |
| T-0049 | Add Airframe live demo project configuration and usage docs | Implemented - Not Verified |
| T-0050 | Verify Slice 1 live project identity and fallback behavior | Implemented - Not Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |
| #46 | [T-0046] Define live demo workspace configuration contract | Open |
| #47 | [T-0047] Implement AICockpit runtime configuration selection | Open |
| #48 | [T-0048] Implement AgileCockpit runtime configuration selection | Open |
| #49 | [T-0049] Add Airframe live demo project configuration and usage docs | Open |
| #50 | [T-0050] Verify Slice 1 live project identity and fallback behavior | Open |

### Notes

- This Epic implements Slice 1 from `docs/Live-Demo-GitHub-Plan.md`.
- GitHub support in this Epic is limited to configuration and honest backend identity; live GitHub issue reads are planned for a later slice.
- GitHub issues #46 through #50 were created and moved to Active on 2026-06-04 after explicit approval.
- EP-009 is complete pending human verification and closeout.

---

*Last Updated: 2026-06-04 (EP-009 complete pending human verification)*
