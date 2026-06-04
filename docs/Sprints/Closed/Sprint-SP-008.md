# SP-008: Verification, Hardening, and Release Candidate

**Status:** Closed
**Epic:** EP-008: Verification, Hardening, and Release Candidate
**Goal:** Harden release-candidate verification evidence, CLI contracts, app accessibility coverage, diagnostics, and documentation.
**Start Date:** 2026-06-04
**End Date:** 2026-06-04
**Capacity:** TBD

### Assigned Tasks

| Task | GitHub Issue | Title | Priority | Status |
| ---- | ------------ | ----- | -------- | ------ |
| T-0041 | #41 | Add full regression and integration test pass | High | Implemented - Verified |
| T-0042 | #42 | Harden CLI output and error contracts | High | Implemented - Verified |
| T-0043 | #43 | Harden AgileCockpit accessibility and UI flows | High | Implemented - Verified |
| T-0044 | #44 | Add configuration diagnostics and failure handling | Medium | Implemented - Verified |
| T-0045 | #45 | Write release candidate verification documentation | Medium | Implemented - Verified |

### Assigned Issues

| Issue | GitHub Issue | Title | Severity | Status |
| ----- | ------------ | ----- | -------- | ------ |

### Sprint Notes

SP-008 avoided feature expansion and focused on repeatability, failure clarity, accessibility confidence, and release-candidate documentation over the existing AirframeCore, AICockpit, AgileCockpit, local backend, and GitHub fixture contracts.

### Verification Targets

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

### Retrospective

**Completed:**
- SP-008 planning opened on 2026-06-04 after EP-007 closeout.
- Regression evidence, CLI contracts, AgileCockpit UI hardening, configuration diagnostics, and release candidate documentation were implemented on 2026-06-04.
- Direct verification commands passed on 2026-06-04.
- T-0041 through T-0045 human-verified on 2026-06-04.
- SP-008 closed on 2026-06-04.

**Returned to Backlog:**
- None.

**What went well:**
- Release-candidate evidence is repeatable with direct commands across all three CSCIs.
- CLI diagnostics and JSON errors are now stable enough for agent use.
- AgileCockpit UI smoke coverage checks real release-candidate context and verification controls.

**What to improve:**
- The optional verification wrapper is documented as a convenience path only; direct commands remain the authoritative evidence.

**Carry-forward notes:**
- Live GitHub authentication and API operations remain future work outside the release-candidate baseline.

---

*Closed: 2026-06-04*
