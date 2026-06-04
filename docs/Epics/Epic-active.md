# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

---

## EP-003: Workflow, Authority, and Audit Foundation

**Status:** Complete
**Owner:** HumanOwner
**Start Date:** 2026-06-02
**Target Close Date:** 2026-06-03
**Close Date:** TBD

**Goal:**
Implement the deny-by-default workflow, authority, project-context, and audit foundation used by both clients.

**Rationale:**
Authority and workflow are the primary safety boundary of Agile Airframe and must be centralized in AirframeCore before meaningful write operations are exposed.

**Scope:**
- Actor and certified context model.
- Authority evaluator.
- Workflow transition evaluator.
- Audit event service.
- CLI denied-operation output.
- App action availability and audit display.

**Out of Scope:**
- GitHub authentication.
- Full backend persistence.
- Final UI polish.

**Acceptance Criteria:**
1. LLM actor can perform allowed proposal/evidence operations.
2. LLM actor cannot perform human-only operations.
3. Project mismatch is denied by default.
4. Denied operations return deterministic reason codes.
5. Audit records are created for allowed and denied write attempts.
6. CLI and app both display denial information without duplicating policy logic.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-003 | Workflow, Authority, and Audit Foundation | Closed |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0012 | Implement actor and certified context model | Implemented - Verified |
| T-0013 | Implement authority evaluator | Implemented - Verified |
| T-0014 | Implement workflow transition evaluator | Implemented - Verified |
| T-0015 | Implement audit event service | Implemented - Verified |
| T-0016 | Implement AICockpit denied-operation output | Implemented - Verified |
| T-0017 | Implement AgileCockpit authority and audit display | Implemented - Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

No client should implement independent authorization rules.
SP-003 activated on 2026-06-02. T-0012 and T-0013 were human-verified on 2026-06-02. T-0014 through T-0017 were human-verified on 2026-06-03. EP-003 is complete and pending human epic closeout.

---

## EP-008: Verification, Hardening, and Release Candidate

**Status:** Active
**Owner:** HumanOwner
**Start Date:** 2026-06-04
**Target Close Date:** TBD
**Close Date:** TBD

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
| SP-008 | Verification, Hardening, and Release Candidate Planning | Planning |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0041 | Add full regression and integration test pass | Backlog |
| T-0042 | Harden CLI output and error contracts | Backlog |
| T-0043 | Harden AgileCockpit accessibility and UI flows | Backlog |
| T-0044 | Add configuration diagnostics and failure handling | Backlog |
| T-0045 | Write release candidate verification documentation | Backlog |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

This Epic should avoid scope expansion and focus on confidence, repeatability, and documentation.
EP-008 activated on 2026-06-04.
SP-008 planning opened on 2026-06-04 with T-0041 through T-0045.

---

*Last Updated: 2026-06-04 (EP-007 closed and EP-008 planning opened)*
