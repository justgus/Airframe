# Active Sprint

---

## SP-010: Read-Only GitHub Issues Adapter

**Status:** Review  
**Epic:** EP-010: Read-Only GitHub Adapter  
**Goal:** Implement Slice 2 so `github-issues` reads live `justgus/Airframe` GitHub Issues through `gh`, maps them to Airframe work records, and fails clearly when live access is unavailable.  
**Start Date:** 2026-06-06  
**End Date:** TBD  
**Capacity:** Not formally estimated

### Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0051 | Define live GitHub issue transport and failure contract | High | Implemented - Not Verified |
| T-0052 | Implement read-only GitHub issue listing backend | High | Implemented - Not Verified |
| T-0053 | Implement GitHub issue-to-work-record parsing | High | Implemented - Not Verified |
| T-0054 | Wire github-issues into AICockpit commands | High | Implemented - Not Verified |
| T-0055 | Verify read-only GitHub adapter behavior and docs | Medium | Implemented - Not Verified |

### Assigned Issues

None.

### Sprint Notes

- Planning opened on 2026-06-06 after EP-010 was selected as the next live demo slice.
- Initial transport is the `gh` CLI so Airframe can reuse local GitHub authentication without storing long-lived tokens.
- Scope is read-only GitHub issue access. GitHub issue mutation, AgileCockpit live project view work, and project-local installation remain out of scope.
- Implementation completed on 2026-06-06 and moved to Review pending human verification.
- Verification passed with `swift test --package-path AirframeCore`, `swift test --package-path AICockpit`, and live read-only `aicockpit` commands against `github-issues`.

---

*Last Updated: 2026-06-06 (SP-010 implementation complete)*
