# EP-002: Core Domain and Configuration Foundation

**Status:** Closed
**Owner:** HumanOwner
**Start Date:** 2026-06-01
**Target Close Date:** TBD
**Close Date:** 2026-06-02

**Goal:**
Define the canonical Airframe domain model and load sample workspace/project configuration through AirframeCore, AICockpit, and AgileCockpit.

**Rationale:**
All clients need a common vocabulary and configuration source before workflow, backend, metrics, or UI behavior can be implemented safely.

**Scope:**
- Define canonical IDs and entity models.
- Define workspace/project configuration structures.
- Implement configuration loading and validation.
- Add local fixture workspace.
- Add CLI context display.
- Add AgileCockpit project context display.

**Out of Scope:**
- Full workflow enforcement.
- Backend persistence beyond fixtures.
- GitHub integration.

### Related Sprints

| Sprint | Status |
| ---- | ---- |
| SP-002 |  |

### Related Tasks

| Task | Status |
| ---- | ---- |
| T-0007 |  |
| T-0008 |  |
| T-0009 |  |
| T-0010 |  |
| T-0011 |  |

**Notes:**
- Acceptance Criteria: 1. AirframeCore loads valid sample configuration. 2. AirframeCore rejects malformed configuration with structured errors. 3. AICockpit displays current workspace/project context. 4. AgileCockpit displays current workspace/project context. 5. Core, CLI, and app tests cover the sample configuration path.
