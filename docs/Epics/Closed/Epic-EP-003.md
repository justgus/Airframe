# EP-003: Workflow, Authority, and Audit Foundation

**Status:** Closed
**Owner:** HumanOwner
**Start Date:** 2026-06-02
**Target Close Date:** 2026-06-03
**Close Date:** 2026-06-04

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

### Closeout Notes

- EP-003 activated on 2026-06-02.
- SP-003 was closed after T-0012 through T-0017 were implemented and human-verified.
- EP-003 remained complete pending closeout until 2026-06-04.
- EP-003 acceptance criteria remain covered by AirframeCore authority/workflow/audit tests and AICockpit/AgileCockpit integration coverage.
- EP-003 was closed on 2026-06-04.

*Closed: 2026-06-04*
