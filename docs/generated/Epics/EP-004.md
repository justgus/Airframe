# EP-004: Local Backend and Task Packet MVP

**Status:** Closed
**Owner:** HumanOwner
**Start Date:** 2026-06-03
**Target Close Date:** 2026-06-03
**Close Date:** 2026-06-03

**Goal:**
Create a local backend and task packet workflow sufficient for offline development and repeatable verification.

**Rationale:**
The local backend provides a deterministic reference implementation before GitHub-specific behavior is introduced.

**Scope:**
- Backend adapter protocol.
- Local filesystem backend.
- Issue/task create, query, update, and transition support.
- Evidence attachment.
- Task packet generation.
- Dashboard summary APIs.

**Out of Scope:**
- GitHub backend.
- Full AgileCockpit dashboard UI.
- Final CLI JSON schema.

### Related Sprints

| Sprint | Status |
| ---- | ---- |
| SP-004 |  |

### Related Tasks

| Task | Status |
| ---- | ---- |
| T-0018 |  |
| T-0019 |  |
| T-0020 |  |
| T-0021 |  |
| T-0022 |  |

**Notes:**
- Acceptance Criteria: 1. Local backend can create and query issues and tasks. 2. Local backend can attach evidence. 3. A task can be marked ready for human verification. 4. AirframeCore can generate a compact task packet. 5. AirframeCore can produce dashboard summary data from local backend records.
