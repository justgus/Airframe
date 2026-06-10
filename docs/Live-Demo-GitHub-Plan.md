# Airframe Live Demonstration Plan With GitHub Support

**Date:** 2026-06-04  
**Status:** Draft plan  
**Target demonstration project:** `justgus/Airframe`  
**Local clone:** `/Users/justgus/Xcode-Projects/Airframe`

## 1. Purpose

Install and run Airframe against a real project with GitHub issue support so the system can demonstrate:

- agent-facing work discovery and task packets through AICockpit;
- human-facing project review, planning, and verification through AgileCockpit;
- AirframeCore as the shared workflow, authority, configuration, backend, and audit source of truth;
- clear separation between read-only GitHub inspection and explicitly approved GitHub mutations.

Airframe itself is the recommended first live demonstration candidate because it already has a real GitHub repository, mapped GitHub issues, sprint/epic/task documentation, labels, and a local clone.

## 2. Demonstration Principles

- Do not present fixture-backed behavior as live GitHub behavior.
- Start with read-only GitHub support before enabling remote writes.
- Keep installation project-local until global installation is explicitly approved.
- Require explicit user approval before comments, label edits, issue closes, issue creation, pushes, or other remote mutations.
- Keep the demo reproducible from the local clone and documented commands.

## 3. Target Architecture

```text
Airframe live demo
├── AirframeCore
│   ├── configuration loading
│   ├── authority and workflow evaluation
│   ├── local backend
│   └── GitHub-backed read adapter
├── AICockpit
│   ├── project context
│   ├── project summary
│   ├── next task
│   └── task packet
└── AgileCockpit
    ├── dashboard
    ├── sprint and epic views
    ├── verification queue
    └── backend/configuration status
```

## 4. Proposed Configuration

Add a project configuration file, either in the Airframe repo or in a separate demo workspace:

```text
.airframe/airframe-workspace.json
```

Required fields:

- workspace id, name, and root path;
- project id and name;
- repository slug: `justgus/Airframe`;
- local clone path or workspace root;
- active sprint and epic, when a new sprint/epic is opened;
- backend kind:
  - `github-fixture` for deterministic dry-run behavior;
  - `github-issues` for live read-only GitHub issue access.

Runtime selection should support:

- `--config path`;
- `AIRFRAME_CONFIG_PATH`;
- `--store path`;
- `AIRFRAME_STORE_PATH`;
- default `.airframe/airframe-workspace.json` and `.airframe/airframe-local-backend.json` from the current working directory.

Slice 1 live demo configuration now lives at:

```text
.airframe/airframe-workspace.json
```

The initial Slice 1 backend is `github-fixture`, not `github-issues`. This intentionally preserves the GitHub-shaped mapping and backend identity without claiming live GitHub issue reads before the read-only GitHub adapter exists.

## 5. Implementation Slices

### Slice 1: Runtime Configuration

Goal: both apps can use a live project configuration instead of only embedded sample data.

Planning records:

- Epic: EP-009, Live Demonstration Runtime Configuration
- Sprint: SP-009, Live Demo Runtime Configuration
- Tasks: T-0046 through T-0050

Deliverables:

- AICockpit loads project config from `--config`, `AIRFRAME_CONFIG_PATH`, or `.airframe/airframe-workspace.json`.
- AgileCockpit loads the same project config through environment or launch configuration.
- Existing sample behavior remains available as fallback.
- Config diagnostics report the selected project and backend.

Verification:

```sh
aicockpit context --config .airframe/airframe-workspace.json
aicockpit config diagnose --config .airframe/airframe-workspace.json --output json
```

From the repository root, these commands should report:

- workspace `Airframe Live Demo`;
- project `Agile Airframe`;
- repository `justgus/Airframe`;
- active sprint `None` after SP-009 closeout, or the currently active sprint once the next slice is opened;
- active epic `None` after EP-009 closeout, or the currently active epic once the next slice is opened;
- backend `github-fixture` at `justgus/Airframe`.

AgileCockpit can use the same configuration by launching with:

```sh
AIRFRAME_CONFIG_PATH=.airframe/airframe-workspace.json \
AIRFRAME_STORE_PATH=.airframe/airframe-local-backend.json \
open path/to/project-local/AgileCockpit.app
```

### Slice 2: Read-Only GitHub Adapter

Goal: read GitHub issues from `justgus/Airframe` and map them into Airframe work records.

Preferred initial transport:

- `gh` CLI, because it already handles local GitHub authentication and avoids long-lived token storage in Airframe-generated files.

Read-only commands:

- list issues with labels;
- inspect an issue by number;
- parse task metadata from labels and body;
- derive sprint/epic/status from labels;
- expose backend capabilities honestly.

Verification:

```sh
aicockpit project summary --backend github-issues --output json
aicockpit task packet T-0045 --backend github-issues
```

Implementation status as of 2026-06-06:

- SP-010 implemented the read-only `github-issues` backend through the `gh` CLI transport.
- AirframeCore maps live GitHub issues into Airframe work records using explicit `Airframe Type:` and `Airframe ID:` body metadata plus status, sprint, and epic labels.
- `github-issues` reports read-only capabilities: project summary and task packet are supported; work item creation, updates, evidence attachment, workflow transitions, and human verification are not supported.
- Live read-only verification reported 55 mapped work items from `justgus/Airframe`. After SP-010 closeout, those mapped tasks are all verified.
- `.airframe/airframe-workspace.json` remains on `github-fixture` by default until Slice 3 makes AgileCockpit live project views explicitly GitHub-backed.

### Slice 3: AgileCockpit Live Project View

Goal: AgileCockpit shows the same live Airframe project state as AICockpit.

Deliverables:

- header shows `justgus/Airframe` and `github-issues`;
- dashboard counts come from live issue mapping;
- planning view shows active sprint/epic work when configured;
- verification view shows implemented-not-verified work;
- unavailable GitHub access shows a clear error state, not sample data pretending to be live.

Verification:

```sh
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
open path/to/project-local/AgileCockpit.app
```

### Slice 4: Project-Local Installation

Goal: install demo artifacts without changing global system state.

Proposed layout:

```text
.airframe/
├── airframe-workspace.json
└── airframe-local-backend.json

demos/LiveDemo/
├── bin/aicockpit
├── Applications/AgileCockpit.app
└── README.md
```

Installation commands should be documented and repeatable. Global installation into `/Applications`, `/usr/local/bin`, shell startup files, or package managers is out of scope unless explicitly approved.

### Slice 5: Controlled GitHub Mutations

Status: Completed and verified on 2026-06-10 through EP-013 / SP-013.

Goal: optionally demonstrate write support after read-only behavior is verified.

Candidate write operations:

- add issue comment;
- attach evidence comment;
- update status labels;
- move issue to verified;
- close issue.

Rules:

- disabled by default;
- each mutation must be explicit in the command name or flag;
- user approval required before live demonstration writes;
- audit record required for every write.

### Slice 6: End-to-End Live Demo Rehearsal

Status: Closed on 2026-06-10 through EP-014 / SP-014.

Goal: prove the installed project-local demo can run a full Airframe live workflow against `justgus/Airframe`, including read-only discovery, AgileCockpit review, and explicitly approved GitHub mutation paths, without relying on fixture-backed behavior or global install state.

Planned records:

- Epic: EP-014, Live Demo Rehearsal and Readiness
- Sprint: SP-014, End-to-End Live Demo Rehearsal
- Tasks: T-0071 through T-0075

Deliverables:

- final Slice 6 demo script and success criteria;
- project-local AICockpit live GitHub workflow rehearsal;
- AgileCockpit live project review rehearsal;
- controlled GitHub write demo verification with explicit approval;
- final live demo runbook and rollback notes.

Rules:

- use project-local installed artifacts;
- do not rely on fixture-backed behavior for live demo claims;
- keep all GitHub mutations explicit, approved, and auditable;
- document expected outputs and rollback steps before final rehearsal closeout.

### Slice 7: AgileCockpit Planning Management

Status: Active on 2026-06-10 through EP-015 / SP-015.

Goal: make AgileCockpit the human-facing surface for managing Epics, Sprints, Tasks, and Issues instead of only viewing them.

Planned records:

- Epic: EP-015, AgileCockpit Planning Management
- Sprint: SP-015, Human Planning Controls for Agile Artifacts
- Tasks: T-0076 through T-0080

Deliverables:

- AgileCockpit planning operation contract;
- AirframeCore planning APIs for artifact operations;
- AgileCockpit task and issue planning UI;
- AgileCockpit sprint and epic management UI;
- planning workflow verification and documentation.

Rules:

- route planning operations through AirframeCore;
- keep AICockpit agent-facing and barred from human-only closeout actions;
- require explicit confirmation for sensitive human planning actions;
- surface backend capability limits clearly;
- keep GitHub mutations explicit, approved, and auditable.

## 6. Demo Script

Read-only demo:

1. Show config diagnostics.
2. Show current project summary.
3. Show next task.
4. Show task packet for a real GitHub-backed task.
5. Launch AgileCockpit.
6. Show dashboard backend status.
7. Show sprint/epic planning view.
8. Show verification queue if any mapped tasks are unverified.

Optional write demo:

1. Select a low-risk demo issue.
2. Attach evidence as a GitHub comment.
3. Move status label after explicit approval.
4. Confirm the audit entry and GitHub issue state.

## 7. Verification Criteria

The live demonstration is successful when:

- AICockpit can resolve `justgus/Airframe` from config;
- AICockpit can read GitHub issue-backed project state;
- AICockpit can produce a task packet from a real issue;
- AgileCockpit launches with the same project/backend identity;
- read-only verification performs no GitHub mutations;
- any write demonstration requires explicit approval and records an audit trail.

## 8. Trade Study: Existing Similar Applications

### Decision Question

Are there existing applications that already provide the same essential capability as Airframe: a GitHub-aware project-management layer with agent-facing task packets, human verification gates, explicit authority boundaries, and local/core workflow governance?

### Evaluation Criteria

| Criterion | Meaning |
| --- | --- |
| GitHub-native or GitHub-integrated | Can work with GitHub issues, repositories, labels, or pull requests. |
| Agile project management | Supports issues/tasks, sprints/cycles, epics/projects, boards, or roadmaps. |
| Agent-facing workflow | Provides a CLI, API, MCP, or agent workflow suitable for coding-agent task execution. |
| Human verification gate | Separates agent work from human acceptance. |
| Authority/governance model | Encodes what agents may and may not do. |
| Local/project-owned operation | Can run from the repository or project clone without moving the source of truth to a SaaS product. |

### Products Reviewed

| Product | Relevant Capabilities | Gaps Versus Airframe |
| --- | --- | --- |
| GitHub Issues and Projects | Native issue tracking, project planning, automation, labels, and close integration with code. GitHub describes Issues and Projects as planning and tracking close to code. Source: [GitHub Issues](https://github.com/features/issues). | Does not provide an AirframeCore-like authority model, agent task packet contract, or explicit human verification gate. Agent workflows must be built around GitHub rather than governed by a project-local core. |
| Linear | Strong issue tracking with GitHub sync, including one-way or two-way issue syncing and issue import. Source: [Linear GitHub integration docs](https://linear.app/docs/github-integration). | SaaS issue tracker first. Strong GitHub integration, but not repo-local governance and not designed around Codex/AICockpit style task packets and human-only acceptance operations. |
| Zenhub | GitHub-connected project-management workspace across repositories; keeps GitHub issues and repositories in place while adding planning/reporting. Source: [Zenhub help](https://support.zenhub.com/article/what-is-zenhub). Zenhub also markets AI and automation. Source: [Zenhub product page](https://www.zenhub.com/product). | Very close for GitHub-native planning, but it is not a local AirframeCore-style policy engine and does not appear to provide explicit agent authority classes or project-local verification packet semantics. |
| Thor by Zenhub | AI project manager in Slack; GitHub integration is described as limited to project-management functions such as creating, updating, and commenting on issues. Source: [Thor](https://www.zenhub.com/thor). | Similar AI project-management direction, but Slack/SaaS-oriented. Does not replace Airframe's local core, CLI/app split, or explicit human verification boundary. |
| Shortcut | Software-team project management with issue tracking, sprints, roadmaps, and AI product-manager positioning. Shortcut says it can connect to Cursor and Claude Code to get agents coding and synced to GitHub. Source: [Shortcut](https://www.shortcut.com/index.html). | Strong adjacent competitor for AI-assisted project management. Still external tracker-centric, not a repo-local governance layer with human-only AirframeCore acceptance rules. |
| Jira | Mature issue tracking and agile project management with GitHub integration through the GitHub for Atlassian app. Source: [Atlassian support](https://support.atlassian.com/jira-cloud-administration/docs/integrate-with-github/). | Enterprise workflow depth, but heavy SaaS/admin model. Agent governance and local task-packet execution are not the default product shape. |
| YouTrack | Issue/project tracking with GitHub/GitLab/Bitbucket/Azure Repos integration; JetBrains also lists a remote MCP server for AI-powered tools. Sources: [YouTrack VCS docs](https://www.jetbrains.com/help/youtrack/cloud/integrate-with-version-control.html), [YouTrack integrations](https://www.jetbrains.com/youtrack/features/integrations/). | Not GitHub-native and not repo-local. MCP support is relevant, but Airframe's distinctive value remains local policy, authority, and human verification semantics. |
| OpenProject | Open-source project management with GitHub integration, especially linking pull requests to work packages. Sources: [OpenProject GitHub docs](https://www.openproject.org/docs/system-admin-guide/github-integration/), [OpenProject GitHub integration](https://www.openproject.org/integrations/github/). | Strong open-source planning alternative, but integration is mainly project-management-to-development linkage. It does not appear to target coding-agent governance or local task-packet execution. |
| Plane | Open-source project management for issues, cycles/sprints, docs, and roadmaps. Source: [Plane open source](https://plane.so/open-source), [Plane GitHub repo](https://github.com/makeplane/plane). | Open-source and modern, but still a project-management platform rather than a project-local agent/human governance layer. GitHub support and AI direction may overlap, but Airframe's CLI/core/app authority model is distinct. |

### Findings

Existing tools cover substantial parts of the space:

- GitHub Projects, Zenhub, Linear, Shortcut, Jira, YouTrack, OpenProject, and Plane can manage software work and integrate with GitHub.
- Several products now include AI or agent-adjacent features.
- Zenhub, Shortcut, and YouTrack are especially relevant because they explicitly discuss AI/automation or agent/tool integration.

No reviewed product appears to match Airframe's exact intended combination:

- repository-local Swift core used by both CLI and GUI;
- explicit authority classes for agent versus human operations;
- human-only acceptance/verification boundary;
- task packet generation for coding agents;
- auditable workflow transitions;
- project-local installation path before SaaS/global integration.

### Recommendation

Proceed with the Airframe live demo, but position it carefully:

- Airframe is not trying to beat Jira, Linear, Zenhub, or GitHub Projects as a general tracker.
- Airframe should be demonstrated as a governance and execution layer for coding-agent work on top of GitHub-backed project state.
- The first live demo should emphasize read-only GitHub issue mapping, task packets, and human verification boundaries.
- Mutating GitHub write support should come later and be treated as controlled workflow automation, not ordinary project-management syncing.

## 9. Recommended Next Step

Implement Slice 1 only after explicit approval:

1. add runtime configuration loading for AICockpit;
2. add runtime configuration loading for AgileCockpit;
3. add `.airframe/airframe-workspace.json` for the Airframe live demo;
4. verify that both apps report the live project identity without using GitHub writes.
