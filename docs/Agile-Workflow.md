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
│   ├── Task-Documentation.md
│   ├── Task-backlog.md
│   ├── Task-active.md
│   ├── Task-unverified.md
│   └── Verified/
├── Issues/
│   ├── Issue-GUIDELINES.md
│   ├── Issue-Documentation.md
│   ├── Issue-backlog.md
│   ├── Issue-active.md
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

1. Keep index files lean. Index files contain tables, counts, and links only.
2. Put detailed work records in active, backlog, unverified, verified, closed, or archive files.
3. Update the relevant index whenever status, sprint assignment, verification state, or counts change.
4. Agents may mark work as implemented or resolved but not human-verified unless the user explicitly directs it.
5. Sprint and epic closure require human approval.
6. Every implemented item needs verification evidence and clear test steps before being marked ready for human review.
7. Every Task and Issue must have a one-to-one GitHub Issue mapping recorded in `docs/GitHub-Issue-Mapping.md`.
8. Task and Issue creation, backlog moves, and GitHub imports must follow `docs/procedures/GitHub-Issue-Sync-Procedure.md`.

## Initial State

This project currently has no recorded Tasks, Issues, Sprints, or Epics in the Agile documentation tree. The next available identifiers are listed in the corresponding index files.

*Last Updated: 2026-06-01 (Initial setup)*
