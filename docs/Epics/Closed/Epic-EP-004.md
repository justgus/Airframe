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

**Acceptance Criteria:**
1. Local backend can create and query issues and tasks.
2. Local backend can attach evidence.
3. A task can be marked ready for human verification.
4. AirframeCore can generate a compact task packet.
5. AirframeCore can produce dashboard summary data from local backend records.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-004 | Local Backend and Task Packet MVP | Closed |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0018 | Define backend adapter protocol and capabilities | Implemented - Verified |
| T-0019 | Implement local filesystem backend | Implemented - Verified |
| T-0020 | Implement evidence attachment workflow | Implemented - Verified |
| T-0021 | Implement task packet generation | Implemented - Verified |
| T-0022 | Implement local dashboard summary APIs | Implemented - Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

Local backend behavior should become the reference behavior for later GitHub mapping.
SP-004 activated, implemented, human-verified, and closed on 2026-06-03. EP-004 was human-approved for closure on 2026-06-03.

---

*Closed: 2026-06-03*
