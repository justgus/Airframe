# AICockpit CLI Output Contracts

This document records the release-candidate command output contracts used by agents and local verification.

## Formats

AICockpit supports:

- `--output markdown`, the default human-readable format.
- `--output json`, the machine-readable contract for agents and automation.

Commands that write or inspect backend state route through AirframeCore backend APIs. Provider-specific state is reported through `backendCapabilities`.

## Stable Commands

| Command | Contract |
| ------- | -------- |
| `aicockpit context` | Prints workspace, project, repository, backend, active epic, and active sprint. |
| `aicockpit config diagnose [--output markdown\|json]` | Reports structured configuration diagnostics from AirframeCore. |
| `aicockpit project summary [--backend local-fixture\|github-fixture] [--output markdown\|json]` | Reports dashboard counts and backend capabilities. |
| `aicockpit requirements import --format csv\|json --file path --dry-run [--output markdown\|json]` | Parses requirement interchange input through AirframeCore and reports created, updated, unchanged, removed, and conflicted preview counts without mutating canonical state. |
| `aicockpit requirements import --format csv\|json --file path --apply [--output markdown\|json]` | Applies requirement interchange input to canonical requirement and revision records, rejects conflicted imports, and returns the same created, updated, unchanged, removed, and conflicted counts reported by dry run. |
| `aicockpit requirements export --format csv\|json` | Exports canonical requirements and requirement revisions through AirframeCore interchange formats. |
| `aicockpit task propose --id T-XXXX --title title` | Creates a task record and returns the canonical work item. |
| `aicockpit issue propose --id I-XXXX --title title` | Creates an issue record and returns the canonical work item. |
| `aicockpit task next` | Returns the first active task or an empty result. |
| `aicockpit task packet T-XXXX` | Returns objective, scope, acceptance criteria, constraints, evidence requirements, protected paths, report format, and existing evidence. |
| `aicockpit evidence attach T-XXXX --id EV-XXXX --summary text --artifact path` | Attaches evidence through AirframeCore. |
| `aicockpit work ready T-XXXX` | Transitions work to Implemented - Not Verified through AirframeCore workflow policy. |

## JSON Error Contract

Commands that accept `--output json` return structured errors for argument and backend failures:

```json
{
  "status": "error",
  "code": "invalidArguments",
  "message": "unsupported backend unknown-backend"
}
```

Current stable error codes:

| Code | Meaning |
| ---- | ------- |
| `invalidArguments` | Missing or unsupported command arguments. |
| `unknownCommand` | Command name or command shape is not recognized. |
| `backendCommandFailed` | Backend command execution failed after argument parsing. |
| `configurationLoadFailed` | Configuration diagnostics could not load configuration data. |

Markdown mode preserves concise stderr messages for compatibility with existing command-line workflows.

## Verification

Run:

```sh
swift test --package-path AICockpit
```

The test suite covers markdown diagnostics, JSON diagnostics, command output fields, and JSON error envelope behavior.
