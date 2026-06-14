# Sprint Guidelines

Sprints are fixed execution windows that group Tasks and Issues into a focused body of work. Sprints support the Agile Cockpit requirement for sprint control, sprint health, burndown, velocity, and human-controlled closure.

## Lifecycle

```text
Backlog -> Planning -> Active -> Review -> Closed
```

## Statuses

- **Backlog**: Sprint is identified but not fully defined or ready to activate.
- **Planning**: Sprint is defined and ready to activate, but has not started.
- **Active**: Sprint is in progress.
- **Review**: Sprint work is complete or time-boxed; verification and carry-forward decisions are pending.
- **Closed**: Human-approved closure is complete and retrospective is recorded.

## Authorization

AI Cockpit / agents may create draft Sprint records, update progress, move incomplete items back to backlog during review, and draft retrospectives.

Only a human may close a Sprint.

## File Organization

```text
docs/Sprints/
├── Sprint-GUIDELINES.md
├── Sprint-Documentation.md
├── Sprint-active.md
└── Closed/
    └── Sprint-SP-XXX.md
```

## Sprint Template

```markdown
## SP-XXX: [Sprint Title]

**Status:** Backlog / Planning / Active / Review / Closed
**Epic:** [EP-XXX: Epic Title or None]
**Goal:** [One or two sentences]
**Start Date:** YYYY-MM-DD
**End Date:** YYYY-MM-DD
**Capacity:** [Estimated available time]

### Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |

### Assigned Issues

| Issue | Title | Severity | Status |
| ----- | ----- | -------- | ------ |

### Sprint Notes

[Constraints, dependencies, and focus areas.]

### Retrospective

**Completed:**
- [Item]

**Returned to Backlog:**
- [Item and reason]

**What went well:**
- [Observation]

**What to improve:**
- [Observation]

**Carry-forward notes:**
- [Notes for future Sprints]
```

## Update Checklist

- Update `Sprint-Documentation.md` whenever a Sprint is created, activated, reviewed, closed, or has assignment changes.
- Update assigned Task and Issue records when Sprint assignment changes.
- Keep backlogged and planning Sprints in `Sprint-active.md` until the Sprint is closed.
- Keep at most one active Sprint in `Sprint-active.md`.
- Archive closed Sprints under `Closed/`.
