# EP-008: Verification, Hardening, and Release Candidate

**Status:** Closed
**Owner:** HumanOwner
**Start Date:** 2026-06-04
**Target Close Date:** TBD
**Close Date:** 2026-06-04

**Goal:**
Harden the MVP into a release-candidate-quality system with stable verification evidence and documentation.

**Rationale:**
The MVP must be repeatable, testable, and understandable enough for ongoing Agile Airframe use.

**Scope:**
- Full test pass across all CSCIs.
- CLI output contract tests.
- App accessibility and UI verification.
- Configuration diagnostics.
- Backend failure and stale data tests.
- Developer and user documentation.
- Release candidate checklist.

**Out of Scope:**
- New major features after feature freeze.
- Additional backend providers.
- Live GitHub authentication and API operations unless explicitly pulled into release-candidate hardening scope.

**Acceptance Criteria:**
1. AirframeCore tests pass.
2. AICockpit tests pass.
3. AgileCockpit build and tests pass.
4. Manual local workflow verification passes.
5. Mocked or test GitHub workflow verification passes.
6. Documentation explains setup, use, and verification.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-008 | Verification, Hardening, and Release Candidate | Closed |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0041 | Add full regression and integration test pass | Implemented - Verified |
| T-0042 | Harden CLI output and error contracts | Implemented - Verified |
| T-0043 | Harden AgileCockpit accessibility and UI flows | Implemented - Verified |
| T-0044 | Add configuration diagnostics and failure handling | Implemented - Verified |
| T-0045 | Write release candidate verification documentation | Implemented - Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Closeout Notes

- EP-008 activated on 2026-06-04.
- SP-008 planning opened on 2026-06-04 with T-0041 through T-0045.
- SP-008 implementation completed on 2026-06-04.
- Direct verification commands passed on 2026-06-04:
  - `swift test --package-path AirframeCore`
  - `swift test --package-path AICockpit`
  - `xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test`
- T-0041 through T-0045 were human-verified on 2026-06-04.
- SP-008 and EP-008 were closed on 2026-06-04.

*Closed: 2026-06-04*
