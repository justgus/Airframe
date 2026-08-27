# Sprint Guidelines

Sprints are fixed execution windows that group Tasks and Issues into a focused body of work. Sprints support the Agile Cockpit requirement for sprint control, sprint health, burndown, velocity, and human-controlled closure.

## Authority and interfaces

- AirframeCore workflow policy and canonical records under `.airframe/state/` define current Sprint state.
- Use AICockpit for agent discovery and authorized Sprint transitions. Use AgileCockpit for human-only Sprint closure.
- `docs/generated/Sprints/` is deterministic output from canonical state and must never be hand-edited.
- Files under `docs/Sprints/` are historical archives, compatibility views, or redirects. They are not workflow mutation surfaces or independent current-state authorities.

For documentation consistency work, follow [Audit Guidelines](../Audits/Audit-Guidelines.md), including its canonical authority order and Findings, Rulings, and Remediation phase gates.

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
├── Sprint-backlog.md
├── Sprint-active.md
└── Closed/
    └── Sprint-SP-XXX.md
```

Historical archives remain supported. In a retained compatibility projection, `Sprint-backlog.md` represents Backlog and Planning; `Sprint-active.md` represents Active and Review. These files must be deterministically generated or be unambiguous redirects, never hand-maintained authorities.

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

- Perform Sprint creation, planning, activation, review, and assignment changes through the authorized canonical interface.
- Preserve the human-only boundary for Sprint closure.
- Regenerate deterministic Sprint projections after canonical changes; do not hand-edit them.
- Project Backlog and Planning into `Sprint-backlog.md`, and Active and Review into `Sprint-active.md`, only when those Legacy compatibility views remain supported.
- Preserve historical Closed archives; do not edit them as the source of current state.
