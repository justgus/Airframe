# Refresh Synchronization

**Status:** Active implementation contract for EP-016 / SP-016.

## Purpose

AICockpit and `.airframe/scripts` can mutate Airframe state while AgileCockpit is open. AgileCockpit must not present stale state after successful workflow, evidence, comment, or status operations.

## Contract

1. The repository/backend remains the source of truth.
2. A refresh notification is only a nudge to reload state.
3. The initial refresh message is `refresh`.
4. AICockpit posts refresh only after successful mutating operations.
5. Read-only commands, denied commands, invalid commands, and failed mutations do not post refresh.
6. AgileCockpit reloads from canonical backend state when it receives refresh.
7. AgileCockpit also observes relevant local Airframe files where feasible, so local state changes can trigger reload even if notification delivery is missed.
8. Future richer events may add payloads, but correctness must not depend on payload contents.

## Initial Mutation Scope

| Operation | Refresh |
| --------- | ------- |
| `task propose` | Yes, after success |
| `issue propose` | Yes, after success |
| `evidence attach` | Yes, after success |
| `work ready` | Yes, after success |
| `github comment` | Yes, after approved success |
| `github evidence-comment` | Yes, after approved success |
| `github status` | Yes, after approved success |
| `context`, `config diagnose`, `project summary`, `task next`, `task packet` | No |

## Failure Semantics

- If mutation authorization is denied, no refresh is sent.
- If backend mutation fails, no refresh is sent.
- If output rendering fails after a mutation, the command fails and does not rely on the notification as evidence of state.
- If AgileCockpit reload fails, it must show a refresh failure status rather than silently presenting stale data as current.

## IPC Choice

The first implementation uses a same-user-session distributed notification named `com.airframe.agilecockpit.refresh` with object/message `refresh`. This fits a transient CLI launched by Codex, Claude Code, or shell scripts without requiring AgileCockpit to run a socket, HTTP server, or XPC service.

AgileCockpit must still reload from source of truth after receiving the notification. The notification does not carry authoritative work item, sprint, epic, or evidence state.
