# Task Backlog

Tasks listed here are proposed and not assigned to an active Sprint.

Currently: **34 backlog Tasks**

---

## EP-003 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0012 | #12 | Implement actor and certified context model | High | Actor identity/type/project context data is represented without trusting caller assertions. |
| T-0013 | #13 | Implement authority evaluator | High | Allowed, denied, and requires-confirmation results are returned with reason codes. |
| T-0014 | #14 | Implement workflow transition evaluator | High | Task, issue, sprint, epic, and verification state transitions are validated. |
| T-0015 | #15 | Implement audit event service | High | Allowed and denied write attempts generate audit records. |
| T-0016 | #16 | Implement AICockpit denied-operation output | Medium | CLI prints compact human-readable and JSON denial output. |
| T-0017 | #17 | Implement AgileCockpit authority and audit display | Medium | UI shows disabled/denied actions and audit records from AirframeCore. |

## EP-004 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0018 | #18 | Define backend adapter protocol and capabilities | High | Backend protocol and capability model are unit tested. |
| T-0019 | #19 | Implement local filesystem backend | High | Local issue/task records can be created, queried, and updated. |
| T-0020 | #20 | Implement evidence attachment workflow | High | Evidence can be attached to authorized work items. |
| T-0021 | #21 | Implement task packet generation | High | Task packets include objective, scope, acceptance criteria, constraints, evidence requirements, protected paths, and report format. |
| T-0022 | #22 | Implement local dashboard summary APIs | High | Dashboard summary data can be produced from local backend fixtures. |

## EP-005 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0023 | #23 | Finalize AICockpit MVP command names and parser | High | MVP command names are documented and parser tests pass. |
| T-0024 | #24 | Implement issue and task proposal commands | High | CLI can propose issues and tasks through AirframeCore. |
| T-0025 | #25 | Implement next-task and task-packet commands | High | CLI can retrieve next work and generate task packets. |
| T-0026 | #26 | Implement evidence and ready-for-verification commands | High | CLI can attach evidence and mark work ready through AirframeCore. |
| T-0027 | #27 | Implement Markdown and JSON output contracts | High | Output contract tests pass for MVP commands. |
| T-0028 | #28 | Document AICockpit agent usage | Medium | Agent usage docs cover local setup and command examples. |

## EP-006 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0029 | #29 | Implement AgileCockpit application shell | High | App shell supports navigation, project context, and global status. |
| T-0030 | #30 | Implement dashboard summary UI | High | Dashboard shows recently done, active, ready, blocked, next, upcoming, sprint health, and epic progress sections. |
| T-0031 | #31 | Implement verification queue and review flow | High | User can open ready work and inspect evidence/acceptance criteria. |
| T-0032 | #32 | Implement human verification actions | High | User can accept, reject, or request evidence through AirframeCore. |
| T-0033 | #33 | Implement sprint and epic read views | Medium | App shows sprint and epic detail data from AirframeCore. |
| T-0034 | #34 | Implement metrics and audit views | Medium | App displays metric summaries and audit event records. |
| T-0035 | #35 | Add primary accessibility and UI tests | High | Primary workflow controls have accessibility labels and tests. |

## EP-007 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0036 | #36 | Implement GitHub backend capability map and configuration | High | GitHub capability/configuration model is represented and tested. |
| T-0037 | #37 | Implement GitHub issue/task mapping | High | Canonical issues/tasks map to GitHub records. |
| T-0038 | #38 | Implement GitHub sprint/epic/evidence mapping | Medium | Sprint, epic, evidence, and audit references map where supported. |
| T-0039 | #39 | Integrate GitHub backend with AICockpit | Medium | CLI commands work against GitHub-backed projects through AirframeCore. |
| T-0040 | #40 | Integrate GitHub backend status with AgileCockpit | Medium | App displays GitHub-backed data and backend status through canonical APIs. |

## EP-008 Tasks

| Task | GitHub Issue | Title | Priority | Acceptance Summary |
| ---- | ------------ | ----- | -------- | ------------------ |
| T-0041 | #41 | Add full regression and integration test pass | High | AirframeCore, AICockpit, and AgileCockpit test suites pass together. |
| T-0042 | #42 | Harden CLI output and error contracts | High | CLI output and error snapshots/contracts are stable. |
| T-0043 | #43 | Harden AgileCockpit accessibility and UI flows | High | Primary app workflows pass accessibility and UI verification. |
| T-0044 | #44 | Add configuration diagnostics and failure handling | Medium | Configuration, stale data, and backend failure states are clear and tested. |
| T-0045 | #45 | Write release candidate verification documentation | Medium | Release candidate checklist and manual verification docs exist. |

---

*Last Updated: 2026-06-01 (SP-002 activated)*
