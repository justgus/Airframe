# SP-006: AgileCockpit Dashboard MVP Integration

**Status:** Closed
**Epic:** EP-006: AgileCockpit Dashboard MVP Integration
**Goal:** Build the first useful AgileCockpit dashboard and human verification workflow over local AirframeCore data.
**Start Date:** 2026-06-04
**End Date:** 2026-06-04
**Capacity:** TBD

### Assigned Tasks

| Task | GitHub Issue | Title | Priority | Status |
| ---- | ------------ | ----- | -------- | ------ |
| T-0029 | #29 | Implement AgileCockpit application shell | High | Implemented - Verified |
| T-0030 | #30 | Implement dashboard summary UI | High | Implemented - Verified |
| T-0031 | #31 | Implement verification queue and review flow | High | Implemented - Verified |
| T-0032 | #32 | Implement human verification actions | High | Implemented - Verified |
| T-0033 | #33 | Implement sprint and epic read views | Medium | Implemented - Verified |
| T-0034 | #34 | Implement metrics and audit views | Medium | Implemented - Verified |
| T-0035 | #35 | Add primary accessibility and UI tests | High | Implemented - Verified |

### Assigned Issues

| Issue | GitHub Issue | Title | Severity | Status |
| ----- | ------------ | ----- | -------- | ------ |

### Sprint Notes

SP-006 kept canonical state and workflow transitions in AirframeCore. AgileCockpit adapts Core data for presentation and routes human verification actions through shared Core APIs.

### Verification Targets

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

### Retrospective

**Completed:**
- SP-006 planned on 2026-06-03.
- SP-006 implemented on 2026-06-04 and moved to Review pending human verification.
- Added Core-backed AgileCockpit dashboard, verification queue, human verification actions, sprint/epic read views, metrics, audit display, and focused app/UI tests.
- T-0029 through T-0035 human-verified on 2026-06-04.
- SP-006 closed on 2026-06-04.

**Returned to Backlog:**
- None.

**What went well:**
- AgileCockpit now provides the human-facing local dashboard and verification workflow.
- Human verification semantics remain centralized in AirframeCore.

**What to improve:**
- Direct macOS accessibility hierarchy assertions were not stable in the local UI runner; future hardening should improve UI-level workflow assertions.

**Carry-forward notes:**
- EP-007 should preserve local backend semantics as the reference behavior while adding GitHub-backed data.

---

*Closed: 2026-06-04*
