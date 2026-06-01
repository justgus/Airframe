# Active Tasks

Tasks listed here are assigned to a Sprint and actively being implemented.

Currently: **5 active Tasks**

---

## T-0007: Define canonical domain model

**Status:** Active  
**GitHub Issue:** #7  
**Component:** AirframeCore  
**Priority:** High  
**Epic:** EP-002  
**Sprint Assigned:** SP-002  
**Date Requested:** 2026-06-01  
**Date Implemented:** TBD  
**Date Verified:** TBD  

**Rationale:**
All CSCIs need a common vocabulary for work, planning, evidence, verification, actors, and backend references.

**Desired Behavior:**
Core models for projects, work items, issues, tasks, sprints, epics, evidence, verification gates, audit, metrics, actors, and backend references compile and are unit tested.

**Requirements:**
1. Define stable IDs and core value types in AirframeCore.
2. Keep domain models UI-independent and serializable where needed.
3. Add unit tests for representative model construction.

**Acceptance Criteria:**
1. Domain model tests pass in `AirframeCore`.
2. Models are importable by AICockpit and AgileCockpit through AirframeCore.

**Implementation Details:**
TBD.

**Evidence:**
- TBD.

---

## T-0008: Define configuration model and fixtures

**Status:** Active  
**GitHub Issue:** #8  
**Component:** AirframeCore  
**Priority:** High  
**Epic:** EP-002  
**Sprint Assigned:** SP-002  
**Date Requested:** 2026-06-01  
**Date Implemented:** TBD  
**Date Verified:** TBD  

**Rationale:**
The system needs a reproducible sample workspace/project configuration before loading, CLI display, and app display can be verified.

**Desired Behavior:**
Sample workspace/project fixtures exist and represent local backend configuration.

**Requirements:**
1. Define workspace and project configuration types.
2. Add sample local fixture data.
3. Ensure fixtures are suitable for Core, CLI, and app tests.

**Acceptance Criteria:**
1. Fixture data is committed with deterministic values.
2. Configuration model tests cover fixture decoding or construction.

**Implementation Details:**
TBD.

**Evidence:**
- TBD.

---

## T-0009: Implement AirframeCore configuration loading

**Status:** Active  
**GitHub Issue:** #9  
**Component:** AirframeCore  
**Priority:** High  
**Epic:** EP-002  
**Sprint Assigned:** SP-002  
**Date Requested:** 2026-06-01  
**Date Implemented:** TBD  
**Date Verified:** TBD  

**Rationale:**
AirframeCore must provide the canonical configuration loading path for both clients.

**Desired Behavior:**
Valid config loads and malformed config fails with structured errors.

**Requirements:**
1. Implement a configuration loader in AirframeCore.
2. Return structured errors for missing or malformed configuration.
3. Add tests for valid, missing, and malformed cases.

**Acceptance Criteria:**
1. `swift test --package-path AirframeCore` passes.
2. Loading behavior is deterministic and documented by tests.

**Implementation Details:**
TBD.

**Evidence:**
- TBD.

---

## T-0010: Implement AICockpit context display

**Status:** Active  
**GitHub Issue:** #10  
**Component:** AICockpit  
**Priority:** Medium  
**Epic:** EP-002  
**Sprint Assigned:** SP-002  
**Date Requested:** 2026-06-01  
**Date Implemented:** TBD  
**Date Verified:** TBD  

**Rationale:**
Agents need a deterministic command that reports the current workspace and project context before requesting work.

**Desired Behavior:**
CLI displays current workspace/project context from AirframeCore.

**Requirements:**
1. Add an AICockpit context command.
2. Load context through AirframeCore rather than duplicating parsing logic.
3. Test command output.

**Acceptance Criteria:**
1. `swift test --package-path AICockpit` passes.
2. `swift run --package-path AICockpit aicockpit context` prints deterministic context output.

**Implementation Details:**
TBD.

**Evidence:**
- TBD.

---

## T-0011: Implement AgileCockpit project context UI

**Status:** Active  
**GitHub Issue:** #11  
**Component:** AgileCockpit  
**Priority:** Medium  
**Epic:** EP-002  
**Sprint Assigned:** SP-002  
**Date Requested:** 2026-06-01  
**Date Implemented:** TBD  
**Date Verified:** TBD  

**Rationale:**
The human-facing app needs to show the same context that agents see through AICockpit.

**Desired Behavior:**
App displays current workspace/project context from AirframeCore.

**Requirements:**
1. Load sample context through AirframeCore.
2. Display workspace and project identity in the app shell.
3. Add a focused test for context availability.

**Acceptance Criteria:**
1. AgileCockpit builds through the workspace.
2. The app context UI uses AirframeCore as its source.

**Implementation Details:**
TBD.

**Evidence:**
- TBD.

---

*Last Updated: 2026-06-01 (SP-002 activated)*
