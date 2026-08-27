# Epic Guidelines

Epics are strategic bodies of work that span one or more Sprints and represent a meaningful Agile Airframe milestone or capability.

## Authority and interfaces

- AirframeCore workflow policy and canonical records under `.airframe/state/` define current Epic state.
- Use AICockpit for agent discovery and authorized Epic transitions. Use AgileCockpit for human-only Epic closure.
- `docs/generated/Epics/` is deterministic output from canonical state and must never be hand-edited.
- Files under `docs/Epics/` are historical archives, compatibility views, or redirects. They are not workflow mutation surfaces or independent current-state authorities.

For documentation consistency work, follow [Audit Guidelines](../Audits/Audit-Guidelines.md), including its canonical authority order and Findings, Rulings, and Remediation phase gates.

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

Historical Closed Epics whose criterion-level verification predates canonical evidence may use only the explicitly defined migration disposition approved under Audit ruling R-03. That disposition is distinct from Verified and Unverified, must preserve provenance, and must never be used to bypass acceptance requirements for a newly closed Epic.

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

Historical archives remain supported. Mutable working files and indexes must be retired as current-state authorities; a retained Legacy path must be either a deterministic canonical projection or an unambiguous redirect to `docs/generated/Epics/` or AgileCockpit.

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

- Perform Epic creation, lifecycle transitions, relationship changes, and acceptance updates through the authorized canonical interface.
- Preserve the human-only boundary for Epic closure.
- Regenerate deterministic Epic projections after canonical changes; do not hand-edit them.
- Preserve historical Closed archives. Do not move or edit Legacy working files as the source of a lifecycle transition.
