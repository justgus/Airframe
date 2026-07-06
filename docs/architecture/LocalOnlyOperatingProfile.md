# Airframe Local-Only Operating Profile

**Task:** T-0149
**Epic:** EP-019
**Date:** 2026-07-01

## Purpose

This profile defines how Airframe operates without GitHub, GitHub credentials,
network access, or any backend server. It is the target profile for EP-019
implementation and regression coverage.

## Backend Target

The supported local-only backend for real workspace operation is the canonical
repo-local store at `.airframe/state`, exposed through
`AirframeCanonicalStoreBackend`.

`AirframeLocalFilesystemBackend` remains a local JSON backend for isolated
fixture workflows and tests. It is offline-capable, but it is not the preferred
real workspace backend once canonical state is present.

`github-fixture` remains an offline-capable fixture backend. It may model
GitHub-shaped records and labels, but it does not require live GitHub access.

`github-issues` is optional remote integration. It must not be required for core
local operation.

## Launch And Selection Rules

1. If `.airframe/state` exists and no explicit backend override is supplied,
   AICockpit uses `AirframeCanonicalStoreBackend` before consulting the
   configured backend kind.
2. If `.airframe/state` exists, AgileCockpit uses
   `AirframeCanonicalStoreBackend` for primary app loading before consulting the
   configured backend kind.
3. Operators may explicitly select `--backend canonical` in AICockpit to make
   local-only intent visible in command transcripts.
4. Operators may explicitly select `local-fixture` for isolated fixture stores
   with `--store` or `AIRFRAME_STORE_PATH`.
5. GitHub issue commands and GitHub-backed repair/sync paths remain explicit
   optional operations.

## Required Local Workflows

| Workflow | Local-only target |
| ---- | ---- |
| Workspace context | Loads local workspace config and canonical active project state. |
| Project summary | Reads canonical records with no GitHub access. |
| Task packet | Assembles from canonical records with no GitHub access. |
| Task/Issue create and update | Writes canonical records locally. |
| Task/Issue agent-allowed transitions | Uses AirframeCore authority and workflow policy locally. |
| Sprint/Epic planning and activation | Writes canonical records and project active pointers locally. |
| AgileCockpit dashboard | Reads canonical records locally. |
| AgileCockpit planning, review, and verification views | Reads and mutates canonical state locally within authority rules. |
| Markdown projection | Generates docs from canonical records locally. |

## Configuration Diagnostics

`aicockpit config diagnose` performs static configuration validation. For a
workspace configured with a GitHub backend, it now adds a non-blocking warning
when `.airframe/state` exists:

```text
canonicalStoreUsesLocalBackend
```

That warning means local operation will use the canonical backend before live
GitHub, and GitHub-backed paths remain optional. The diagnostic is intentionally
non-blocking; the command exits successfully because local operation is
available.

## Offline Failure Policy

- Missing GitHub credentials must not block canonical/local workspace load.
- Missing `gh` must not block canonical/local workspace load.
- Network failure must not block canonical/local workspace load.
- Live GitHub failure may block only explicitly selected `github-issues`
  operations or optional GitHub repair/sync actions.
- Error messages for optional GitHub paths should identify the GitHub dependency
  and avoid implying that the local workspace is unusable.

## Verification Commands

```sh
swift run --package-path AICockpit aicockpit config diagnose --config .airframe/airframe-workspace.json --output json
swift run --package-path AICockpit aicockpit project summary --config .airframe/airframe-workspace.json --backend canonical --output json
swift run --package-path AICockpit aicockpit task packet T-0149 --config .airframe/airframe-workspace.json --backend canonical --output json
swift test --package-path AICockpit
```
