# Canonical State Migration and Projection Workflow

This document defines the initial workflow for moving Airframe Agile artifacts from manually edited Markdown into AirframeCore canonical records while preserving readable repository documentation.

## Ownership Model

AirframeCore canonical records are the source of truth for workflow state.

Markdown remains a repository-readable projection. After migration, generated Markdown should be reviewed like any other generated artifact, but status, relationship, and evidence state should be changed through AirframeCore-backed tools rather than direct Markdown edits.

## Migration Flow

1. Import existing Markdown artifacts into canonical records.
2. Review import diagnostics.
3. Resolve blocking diagnostics before writing canonical state.
4. Persist canonical records into the repo-local canonical store.
5. Generate Markdown projections from canonical records.
6. Compare generated projections with current Markdown for intentional differences.
7. Switch AICockpit and AgileCockpit read paths to canonical records after projection behavior is verified.

## Import Scope

The initial importer covers:

- Epics
- Sprints
- Tasks
- Issues

The importer preserves stable Airframe IDs, workflow status, GitHub issue numbers, Epic and Sprint relationships, relationship-table references, numbered acceptance criteria, narrative blocks, evidence IDs when present, and source file paths.

## Diagnostics

Import diagnostics should be treated as follows:

| Severity | Meaning | Expected Action |
| -------- | ------- | --------------- |
| Warning | Ambiguous but importable source, such as TBD metadata. | Review before migration closeout. |
| Error | Missing required fields or unsupported required structure. | Fix source or provide migration override before canonical write. |
| Blocking | State cannot be safely represented or reconciled. | Stop migration until human review resolves the inconsistency. |

## Projection Rules

Generated Markdown must be deterministic:

- Records are sorted by stable Airframe ID where an index or collection is generated.
- Status labels use the canonical workflow display names.
- Missing optional values render as `TBD`.
- Tables and numbered lists are generated from canonical record arrays.
- Generated output should not depend on dictionary ordering, filesystem ordering, timestamps, or local machine settings.

## Manual Edit Boundary

Before canonical migration is complete, existing Markdown remains the practical working record.

After canonical migration is complete:

- Edit canonical records through AirframeCore-backed workflows.
- Do not manually edit generated status, relationship, count, index, or evidence sections.
- Human-authored narrative may remain editable only if the canonical schema has a matching field and the edit path writes that field back to canonical state.
- Emergency manual repair is allowed only with a recorded diagnostic, repair rationale, and follow-up canonical reconciliation.

## Verification Expectations

Migration is ready to proceed only when:

- Current artifact shapes import into canonical records.
- Invalid source artifacts produce structured diagnostics.
- Generated projections are deterministic.
- Generated index counts and tables derive from canonical records.
- AICockpit and AgileCockpit can continue to preserve human-only authority boundaries after switching read paths.

## Related Work

- EP-020: Canonical Airframe Workflow State
- SP-026: Markdown Import and Projection
- T-0120: Build Markdown artifact importer for existing work products
- T-0121: Generate deterministic Markdown projections from canonical records
- T-0122: Add import and projection regression coverage
- T-0123: Document canonical migration and projection workflow
