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

### Related Sprints

| Sprint | Status |
| ---- | ---- |
| SP-003 |  |

### Related Tasks

| Task | Status |
| ---- | ---- |
| T-0012 |  |
| T-0013 |  |
| T-0014 |  |
| T-0015 |  |
| T-0016 |  |
| T-0017 |  |

**Notes:**
- Acceptance Criteria: 1. LLM actor can perform allowed proposal/evidence operations. 2. LLM actor cannot perform human-only operations. 3. Project mismatch is denied by default. 4. Denied operations return deterministic reason codes. 5. Audit records are created for allowed and denied write attempts. 6. CLI and app both display denial information without duplicating policy logic.
