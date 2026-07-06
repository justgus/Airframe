# Airframe Offline Runtime Dependency Inventory

**Task:** T-0148
**Epic:** EP-019
**Date:** 2026-07-01

## Purpose

This inventory identifies Airframe runtime paths that can require GitHub, the `gh`
CLI, credentials, network access, or a remote server. It separates core local
operation from optional GitHub-backed behavior so EP-019 can harden offline-only
operation without removing GitHub support.

## Summary

Airframe's core local operation is currently file-based when the canonical store
exists at `.airframe/state` or when a local fixture store is selected. The live
GitHub dependency is concentrated in `AirframeGitHubCLITransport` and only enters
normal command or app execution when the effective backend is `github-issues` and
the canonical store is not selected, or when canonical diagnostics repair is
configured to use a GitHub repair backend.

The current workspace configuration still names `github-issues`, but AICockpit
and AgileCockpit both prefer the canonical store when `.airframe/state` exists.
That means local read, planning, task packet, dashboard, and canonical workflow
state operations can run without GitHub for this repository.

## Required Local Operation Paths

| Area | Local path | External dependency | EP-019 AC |
| ---- | ---- | ---- | ---- |
| Configuration loading | `AirframeRuntimeConfigurationResolver` reads `--config`, `AIRFRAME_CONFIG_PATH`, or `.airframe/airframe-workspace.json` from disk. | None beyond local files. | AC-01 |
| Canonical state | `AirframeCanonicalStoreBackend` reads and writes `.airframe/state` JSON records. | None beyond local files. | AC-01, AC-02, AC-04 |
| AICockpit backend selection | Without an explicit `--backend`, AICockpit selects `AirframeCanonicalStoreBackend` when `.airframe/state` exists. Explicit `--backend canonical` also uses local canonical state. | None beyond local files. | AC-02, AC-06 |
| AgileCockpit primary backend | AgileCockpit selects `AirframeCanonicalStoreBackend` when `.airframe/state` exists, before consulting configured backend kind. | None beyond local files. | AC-03, AC-06 |
| Local fixture backend | `AirframeLocalFilesystemBackend` reads and writes `airframe-local-backend.json` or `AIRFRAME_STORE_PATH`. | None beyond local files. | AC-01, AC-02 |
| Markdown import/export | AICockpit import/export and `MarkdownArtifactProjector` use local docs plus canonical records. | None beyond local files. | AC-04, AC-05 |
| Refresh notifications | AICockpit posts and AgileCockpit observes distributed refresh notifications for local state changes. | Local OS notification center only; no network/server. | AC-03 |

## Optional GitHub-Backed Paths

| Area | Trigger | Dependency | Offline classification | EP-019 AC |
| ---- | ---- | ---- | ---- | ---- |
| GitHub Issues backend reads | Effective backend is `github-issues` and canonical store is not selected. | `gh issue list/view`, GitHub auth, network. | Optional remote backend. Must not be required for local operation. | AC-06 |
| GitHub work item creation/update | AICockpit task/issue create/update with effective `github-issues` backend and approval. | `gh issue create/edit`, GitHub auth, network. | Optional controlled remote mutation. | AC-06 |
| GitHub status transitions | AICockpit `github status` or backend GitHub transition methods. | `gh issue edit`, GitHub auth, network. | Optional controlled remote mutation. | AC-06 |
| GitHub comments/evidence comments | AICockpit `github comment` and `github evidence-comment`. | `gh issue comment`, GitHub auth, network. | Optional controlled remote mutation. | AC-06 |
| AgileCockpit repair backend | `.airframe/state` exists and workspace backend kind is `github-issues`; repair actions may use `AirframeGitHubIssuesBackend`. | `gh` and GitHub auth for GitHub-backed repair actions. | Optional repair/sync path; primary dashboard remains canonical. | AC-03, AC-06 |
| GitHub fixture backend | Explicit `github-fixture` backend. | Local JSON store only, despite GitHub-shaped labels. | Offline-capable fixture path, not live GitHub. | AC-05 |

## Findings

1. `AirframeGitHubCLITransport` is the only runtime path found that launches an
   external executable for GitHub. It shells through `/usr/bin/env gh` and wraps
   failures as `AirframeBackendError.githubAccessFailed`.
2. `AirframeGitHubIssuesBackend` defaults to `AirframeGitHubCLITransport`, so any
   live GitHub issue read or mutation depends on `gh`, credentials, and network
   access.
3. AICockpit avoids that live path by default when `.airframe/state` exists,
   because `AICockpitArguments.backend` returns `AirframeCanonicalStoreBackend`
   before consulting the workspace backend kind unless `--backend` is explicit.
4. AgileCockpit also avoids the live path for primary loading when
   `.airframe/state` exists. It constructs `AirframeCanonicalStoreBackend` before
   switching on the configured backend kind.
5. AgileCockpit can still construct a GitHub repair backend when canonical state
   exists and the workspace config says `github-issues`. That is a sync/repair
   path, not the primary local dashboard path.
6. Configuration diagnostics validate backend shape, including GitHub repository
   slug format for GitHub backends, but do not require contacting GitHub.
7. Existing tests already cover important offline-adjacent behavior:
   AICockpit canonical creation and task packet paths, AgileCockpit local-only
   closeout, canonical dashboard behavior, and live GitHub failure display.

## Follow-Up Work

- T-0149 should define the explicit supported local-only operating profile,
  including whether `canonical` is the preferred real workspace backend and
  `local-fixture` remains a fixture/test backend.
- T-0150 should add focused AICockpit regression coverage for canonical command
  flows without GitHub credentials.
- T-0151 should harden AgileCockpit repair/sync affordances so optional GitHub
  repair paths cannot make local operation feel blocked.
- T-0153 should consolidate these into an offline regression suite that does not
  invoke live `gh` or require GitHub credentials.

## Evidence Commands

```sh
rg -n "AirframeGitHubCLITransport|GitHubIssuesBackend|github-issues|githubIssues|gh |Process|transport|configuredBackend|configuredRepairBackend|backend\\(" AirframeCore/Sources AICockpit/Sources AgileCockpit/AgileCockpit
rg -n "AIRFRAME_|ProcessInfo|environment|credential|token|GITHUB|GitHub|network|server|URLSession|Data\\(contentsOf|FileManager|distributed|refresh" AirframeCore/Sources AICockpit/Sources AgileCockpit/AgileCockpit
rg -n "github-issues|github-fixture|local-fixture|canonical|AirframeGitHubCLITransport|StubGitHub|gh authentication|required|offline|local-only|configuredDashboard" AICockpit/Tests AgileCockpit/AgileCockpitTests AirframeCore/Tests
swift run --package-path AICockpit aicockpit task packet T-0148 --config .airframe/airframe-workspace.json --backend canonical --output json
```
