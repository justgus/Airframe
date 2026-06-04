# EP-005: AICockpit MVP Integration

**Status:** Closed
**Owner:** HumanOwner  
**Start Date:** 2026-06-03
**Target Close Date:** TBD  
**Close Date:** 2026-06-03

**Goal:**
Make AICockpit independently useful for agents working against a local Airframe workspace.

**Rationale:**
Agents need a compact and deterministic command interface before the human UI or GitHub integration can provide full value.

**Scope:**
- Final MVP command names.
- Command parser and routing.
- Project summary command.
- Issue/task proposal commands.
- Next-task and task-packet commands.
- Evidence attachment and ready-for-verification commands.
- Markdown and JSON output contracts.
- Agent usage documentation.

**Out of Scope:**
- Human-only operations.
- Direct backend manipulation outside AirframeCore.
- Full GitHub workflow.

**Acceptance Criteria:**
1. `aicockpit --help` documents MVP commands.
2. AICockpit can propose issues and tasks.
3. AICockpit can retrieve next task and task packet.
4. AICockpit can attach evidence and mark work ready for human verification.
5. JSON output is deterministic and tested for MVP commands.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-005 | AICockpit MVP Integration | Closed |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0023 | Finalize AICockpit MVP command names and parser | Implemented - Verified |
| T-0024 | Implement issue and task proposal commands | Implemented - Verified |
| T-0025 | Implement next-task and task-packet commands | Implemented - Verified |
| T-0026 | Implement evidence and ready-for-verification commands | Implemented - Verified |
| T-0027 | Implement Markdown and JSON output contracts | Implemented - Verified |
| T-0028 | Document AICockpit agent usage | Implemented - Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Closeout Notes

- SP-005 planned on 2026-06-03.
- SP-005 activated on 2026-06-03.
- T-0023 through T-0028 were implemented and moved to Implemented - Not Verified on 2026-06-03.
- T-0023 through T-0028 were human-verified on 2026-06-03.
- SP-005 was closed on 2026-06-03.
- EP-005 was closed on 2026-06-03.

*Closed: 2026-06-03*
