# Active Sprint

---

## SP-008: Verification, Hardening, and Release Candidate Planning

**Status:** Planning
**Epic:** EP-008: Verification, Hardening, and Release Candidate
**Goal:** Plan release-candidate hardening with stable verification evidence, CLI contracts, app accessibility coverage, diagnostics, and documentation.
**Start Date:** TBD
**End Date:** TBD
**Capacity:** TBD

### Assigned Tasks

| Task | GitHub Issue | Title | Priority | Status |
| ---- | ------------ | ----- | -------- | ------ |
| T-0041 | #41 | Add full regression and integration test pass | High | Backlog |
| T-0042 | #42 | Harden CLI output and error contracts | High | Backlog |
| T-0043 | #43 | Harden AgileCockpit accessibility and UI flows | High | Backlog |
| T-0044 | #44 | Add configuration diagnostics and failure handling | Medium | Backlog |
| T-0045 | #45 | Write release candidate verification documentation | Medium | Backlog |

### Assigned Issues

| Issue | GitHub Issue | Title | Severity | Status |
| ----- | ------------ | ----- | -------- | ------ |

### Sprint Notes

SP-008 should avoid feature expansion. The sprint focus is repeatability, failure clarity, accessibility confidence, and release-candidate documentation over the existing AirframeCore, AICockpit, AgileCockpit, local backend, and GitHub fixture contracts.

### Verification Targets

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

Manual planning checks:

1. Confirm regression evidence covers AirframeCore, AICockpit, and AgileCockpit together.
2. Confirm CLI output and error contracts are stable enough for agent use.
3. Confirm AgileCockpit accessibility and UI smoke coverage exercises primary workflows.
4. Confirm backend/configuration failure states are explicit and testable.
5. Confirm release-candidate documentation captures setup, use, verification, and known limitations.

### Retrospective

**Completed:**
- SP-008 planning opened on 2026-06-04 after EP-007 closeout.

**Returned to Backlog:**
- TBD.

**What went well:**
- TBD.

**What to improve:**
- TBD.

**Carry-forward notes:**
- Live GitHub authentication and API operations remain future work unless explicitly pulled into scope; EP-008 is primarily a hardening and release-candidate sprint.

---

*Last Updated: 2026-06-04 (SP-008 planning opened)*
