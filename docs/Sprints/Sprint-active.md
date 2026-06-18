# Active Sprint

## SP-026: Markdown Import and Projection

**Status:** Active
**Epic:** EP-020: Canonical Airframe Workflow State
**Goal:** Import current Markdown artifacts into canonical records and generate deterministic documentation projections.
**Start Date:** 2026-06-18
**End Date:** TBD
**Capacity:** TBD

### Assigned Tasks

| Task | Title | Priority | Status |
| ---- | ----- | -------- | ------ |
| T-0120 | Build Markdown artifact importer for existing work products | High | Active |
| T-0121 | Generate deterministic Markdown projections from canonical records | High | Active |
| T-0122 | Add import and projection regression coverage | High | Active |
| T-0123 | Document canonical migration and projection workflow | Medium | Active |

### Assigned Issues

None.

### Planning Notes

- SP-026 should use the SP-025 canonical record, JSON store, workflow policy, and diagnostics foundation.
- Sprint planning should refine the boundary between import parsing, canonical persistence, and generated Markdown projection.
- T-0120 through T-0123 were activated for SP-026 implementation.
- GitHub Issues #120 through #123 track the candidate Tasks.

### Planning Checklist

- Confirm import scope for Epic, Sprint, Task, and Issue Markdown artifacts.
- Define how imported narrative fields and ambiguous legacy content are preserved.
- Define deterministic projection output expectations before implementation.
- Identify diagnostics that should block migration versus warn.

*Last Updated: 2026-06-18 (SP-026 activated for implementation)*
