# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

---

## EP-010: Read-Only GitHub Adapter

**Status:** Draft  
**Owner:** Human / Airframe Planning  
**Start Date:** 2026-06-05  
**Target Close Date:** TBD  
**Close Date:** TBD

## Goal

Implement Slice 2 of the Live Demo GitHub Plan by reading GitHub issues from `justgus/Airframe` and mapping them into Airframe work records.

## Rationale

Airframe needs a read-only live GitHub issue adapter before the live demo can show project work state from GitHub Issues instead of local sample or fixture-backed data.

## Scope

- Add read-only GitHub issue listing through the preferred `gh` CLI transport.
- Inspect individual GitHub issues by number.
- Parse Airframe task metadata from issue labels and body content.
- Derive sprint, epic, and status values from GitHub issue labels.
- Expose GitHub backend capabilities honestly.

## Out of Scope

- GitHub issue mutation.
- Long-lived token storage in Airframe-generated files.
- AgileCockpit live project view work from Slice 3.
- Project-local installation work from Slice 4.

## Acceptance Criteria

1. `aicockpit project summary --backend github-issues --output json` reads live GitHub issue data and reports mapped Airframe work records.
2. `aicockpit task packet T-0045 --backend github-issues` reads and maps the corresponding GitHub issue without mutating remote state.
3. GitHub access failures produce clear errors instead of silently falling back to sample data.
4. Backend capability reporting distinguishes read-only GitHub behavior from local backend behavior.

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

- Source plan: [Live Demo GitHub Plan](../Live-Demo-GitHub-Plan.md), Slice 2.
- Preferred initial transport is `gh` CLI to reuse local GitHub authentication and avoid Airframe-managed token storage.

---

*Last Updated: 2026-06-05 (EP-010 drafted)*
