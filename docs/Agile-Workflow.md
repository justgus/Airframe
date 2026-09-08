# Agile Airframe Workflow Documentation

This folder contains the project-management documentation used to operate Agile Airframe work. It is adapted from the Telemetrix Agile documentation pattern and aligned with the Airframe Core, Agile Cockpit, and AI Cockpit requirements.

## Purpose

Agile Airframe separates human-authorized governance from agent-executable work:

- **Humans** approve verification, close sprints, close epics, and make final acceptance decisions.
- **AI Cockpit / agents** may propose work, implement assigned work, attach evidence, and mark work ready for human verification.
- **Airframe Core** is the authority boundary for identity, workflow state, project scope, audit events, and backend access.

## Work Item Types

| Type | Prefix | Purpose | Primary Folder |
| ---- | ------ | ------- | -------------- |
| Task | `T-XXXX` | Planned implementation work, feature work, refactoring, or requirement changes | `docs/Tasks/` |
| Issue | `I-XXXX` | Bugs, defects, regressions, and unintended behavior | `docs/Issues/` |
| Sprint | `SP-XXX` | Fixed execution window grouping Tasks and Issues | `docs/Sprints/` |
| Epic | `EP-XXX` | Strategic milestone spanning one or more Sprints | `docs/Epics/` |

## Folder Structure

```text
docs/
├── Agile-Workflow.md
├── design/
├── requirements/
├── Tasks/
│   ├── Task-Guidelines.md
│   ├── Task-Documentation.md (Legacy redirect)
│   ├── Task-backlog.md (Legacy redirect)
│   ├── Task-active.md (Legacy redirect)
│   ├── Task-unverified.md (Legacy redirect)
│   └── Verified/
├── Issues/
│   ├── Issue-GUIDELINES.md
│   ├── Issue-Documentation.md (Legacy narrative)
│   ├── Issue-backlog.md (Legacy narrative)
│   ├── Issue-active.md (Legacy redirect)
│   ├── Verified/
│   └── Closed/
├── Sprints/
│   ├── Sprint-GUIDELINES.md
│   ├── Sprint-Documentation.md
│   ├── Sprint-active.md
│   └── Closed/
└── Epics/
    ├── Epic-GUIDELINES.md
    ├── Epic-Documentation.md
    ├── Epic-backlog.md
    ├── Epic-active.md
    └── Closed/
```

## Operating Rules

1. Canonical records under `.airframe/state/` are the current-state authority for Tasks and Issues.
2. Use AICockpit or AgileCockpit to mutate canonical records, then regenerate `docs/generated/` projections.
3. Legacy Task and Issue queues/indexes are redirects or preserved narrative, never workflow mutation surfaces.
4. Agents may mark work as implemented or resolved but not human-verified unless the user explicitly directs it.
5. Sprint and epic closure require human approval.
6. Every implemented item needs verification evidence and clear test steps before being marked ready for human review.
7. Every Task and Issue must have a one-to-one GitHub Issue mapping recorded in `docs/GitHub-Issue-Mapping.md`.
8. Task and Issue creation, backlog moves, and GitHub imports must follow `docs/procedures/GitHub-Issue-Sync-Procedure.md` through canonical interfaces.

## Implementation Plan Review

Implementation plans are canonical records used to capture proposed implementation work before execution begins. A plan records the target Epic, Sprint, Tasks, scope, expected file changes, commands, external effects, verification criteria, proposer, notes, audit links, and decision state.

Agents may submit proposed plans through AICockpit:

```sh
swift run --package-path AICockpit aicockpit plans submit \
  --id PLAN-XXXX \
  --title "Plan title" \
  --summary "Short summary" \
  --task T-XXXX \
  --scope "What will change" \
  --file-change "Path or area" \
  --command "Verification command" \
  --external-effect "Expected external effect" \
  --verification "Human-readable verification criterion" \
  --config .airframe/airframe-workspace.json
```

Agents may list and inspect plans, but plan decisions are human-only:

```sh
swift run --package-path AICockpit aicockpit plans list --config .airframe/airframe-workspace.json
swift run --package-path AICockpit aicockpit plans inspect PLAN-XXXX --config .airframe/airframe-workspace.json
```

AgileCockpit is the human decision surface. The Plan Review section shows pending, approved, deferred, and rejected plans with their target work context and review packet. Human reviewers may approve, defer, or reject a selected plan, optionally adding a decision note. AirframeCore records each decision as a canonical plan decision plus an audit event.

An approved plan authorizes the implementation handoff for the scoped work. Deferral or rejection leaves the work unapproved for implementation until a new or revised plan is submitted and approved.

## Initial State

This project currently has no recorded Tasks, Issues, Sprints, or Epics in the Agile documentation tree. The next available identifiers are listed in the corresponding index files.

*Last Updated: 2026-07-07*
