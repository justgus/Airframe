# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

---

## EP-011: AgileCockpit Live Project View

**Status:** Draft  
**Owner:** Human / Airframe Planning  
**Start Date:** 2026-06-06  
**Target Close Date:** TBD  
**Close Date:** TBD

## Goal

Implement Slice 3 of the Live Demo GitHub Plan so AgileCockpit shows the same live Airframe project state as AICockpit through the read-only `github-issues` backend.

## Rationale

Airframe now has a verified read-only GitHub issue adapter for AICockpit. The human-facing AgileCockpit surface needs to consume that same live project state so the demo can show GitHub-backed dashboard, planning, and verification views without presenting fixture-backed data as live behavior.

## Scope

- Display `justgus/Airframe` and `github-issues` backend identity in AgileCockpit.
- Load live GitHub issue-backed dashboard counts through AirframeCore.
- Show sprint and epic planning state from live mapped work records.
- Show implemented-not-verified work in the verification view when live GitHub data contains it.
- Show clear GitHub access failure states instead of falling back to sample or fixture data.

## Out of Scope

- GitHub issue mutation.
- Long-lived token storage in Airframe-generated files.
- Project-local installation work from Slice 4.
- Controlled GitHub mutation support from Slice 5.

## Acceptance Criteria

1. AgileCockpit can be launched against the Airframe live demo configuration and show repository `justgus/Airframe` with backend `github-issues`.
2. Dashboard counts are sourced from live GitHub issue mapping rather than local sample or fixture data.
3. Planning views show the configured active sprint and epic work from live mapped records.
4. Verification view shows implemented-not-verified mapped work when present.
5. GitHub access failures show clear error state and do not silently fall back to sample data.

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

- Source plan: [Live Demo GitHub Plan](../Live-Demo-GitHub-Plan.md), Slice 3.
- EP-010 verified the read-only `github-issues` backend through AICockpit.
- Sprint planning is next before implementation tasks are created.

---

*Last Updated: 2026-06-06 (EP-011 drafted)*
