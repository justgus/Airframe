# Epic Guidelines

Epics are strategic bodies of work that span one or more Sprints and represent a meaningful Agile Airframe milestone or capability.

## Epic vs. Task vs. Sprint

| Concept | Scope | Duration | Tracked By |
| ------- | ----- | -------- | ---------- |
| Task | Single planned work item | Hours to days | Task system |
| Issue | Single bug or defect | Hours to days | Issue system |
| Sprint | Batch of Tasks and Issues | Fixed iteration | Sprint system |
| Epic | Major capability or milestone | Multiple Sprints | Epic system |

## Lifecycle

```text
Proposed -> Draft -> Backlog -> Active -> Complete -> Closed
```

## Statuses

- **Proposed**: Queued in the backlog with rough scope.
- **Draft**: Goal, scope, Tasks, Issues, and acceptance criteria are being defined.
- **Backlog**: Fully defined but has no active Sprint, or partially delivered with remaining acceptance criteria dependent on backlogged or unverified work.
- **Active**: One or more Sprints are executing against the Epic.
- **Complete**: Work appears complete and is pending human closeout.
- **Closed**: Human-approved closeout is complete.

## Authorization

AI Cockpit / agents may propose Epics, draft Epic details, update progress tables, and mark an Epic Complete pending human review.

Only a human may close an Epic.

## File Organization

```text
docs/Epics/
├── Epic-GUIDELINES.md
├── Epic-Documentation.md
├── Epic-backlog.md
├── Epic-active.md
└── Closed/
    └── Epic-EP-XXX.md
```

## Epic Template

```markdown
## EP-XXX: [Epic Title]

**Status:** Proposed / Draft / Backlog / Active / Complete / Closed
**Owner:** [Human owner or project role]
**Start Date:** YYYY-MM-DD
**Target Close Date:** YYYY-MM-DD
**Close Date:** YYYY-MM-DD

**Goal:**
[Outcome the Epic should deliver.]

**Rationale:**
[Why this Epic matters.]

**Scope:**
- [In-scope item]

**Out of Scope:**
- [Out-of-scope item]

**Acceptance Criteria:**
1. [Criterion]

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

[Risks, dependencies, and decisions.]
```

## Update Checklist

- Update `Epic-Documentation.md` when an Epic is proposed, activated, completed, closed, or has related Sprint/Task/Issue changes.
- Keep Proposed and Backlog Epics in `Epic-backlog.md`.
- Keep Draft, Active, and Complete Epics in `Epic-active.md`.
- Archive closed Epics under `Closed/`.
