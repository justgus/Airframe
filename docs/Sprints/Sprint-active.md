# Active Sprint

---

## SP-017: Workflow Status Dashboard

**Status:** Active
**Epic:** EP-017: Workflow Status Dashboard and Mutation Authority
**Goal:** Deliver artifact-specific workflow status dashboard tiles, drill-down details, and process guardrails.
**Start Date:** 2026-06-12
**End Date:** TBD
**Capacity:** Not formally estimated

### Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0086 | Reconcile Agile artifact workflow documentation and process guardrails | High | Implemented - Not Verified |
| T-0087 | Define artifact-specific status presentation model | High | Implemented - Not Verified |
| T-0088 | Replace dashboard metrics with workflow status tiles | High | Implemented - Not Verified |
| T-0089 | Add interactive dashboard status drill-down | High | Implemented - Not Verified |
| T-0090 | Verify dashboard workflow and integrate draft patch | Medium | Implemented - Not Verified |

### Assigned Issues

| Issue | Title | Severity | Status |
| ----- | ----- | -------- | ------ |
| I-0001 | Dashboard status drill-down shows stray blue selection rectangle | Medium | Resolved - Not Verified |
| I-0002 | Status drill-down detail pane omits full work product text | Medium | Resolved - Not Verified |
| I-0003 | Status drill-down detail pane uses incomplete fallback text for Tasks and Issues | High | In Progress |
| I-0004 | Status drill-down detail scroll position is retained across item selection | Medium | In Progress |

### Sprint Notes

- SP-017 was activated on 2026-06-12 after EP-017 was drafted and the Sprint Backlog was established.
- T-0086 through T-0090 had pre-sprint draft work from an earlier unapproved implementation pass. That work is not accepted as implemented until reviewed and verified under this active Sprint.
- Known pre-sprint draft work includes guideline/AGENTS edits, AirframeCore status-summary model edits, AgileCockpit dashboard tile/drill-down edits, and partial test updates.
- Pre-sprint verification evidence: `swift test --package-path AirframeCore` passed; full AgileCockpit Xcode tests failed because the UI/unit tests had not yet been repaired for the new dashboard behavior.
- The authorized build flow must copy `AgileCockpit.app` to `demos/LiveDemo/Applications` and `aicockpit` to `demos/LiveDemo/bin` after a successful build.
- T-0086 through T-0090 were implemented on 2026-06-12 and moved to Task-unverified pending human verification.
- Verification evidence recorded for SP-017 implementation: AirframeCore tests passed, AgileCockpit unit tests passed, AgileCockpit UI tests passed, and the LiveDemo install build copied both requested artifacts.
- I-0003 and I-0004 were created on 2026-06-13 to track the remaining drill-down detail completeness and scroll reset fixes.

---

SP-016 was human-verified and closed on 2026-06-11. See [Closed/Sprint-SP-016.md](Closed/Sprint-SP-016.md).

*Last Updated: 2026-06-13 (I-0003 and I-0004 assigned to SP-017)*
