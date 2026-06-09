# Active Epics

Draft, Active, and Complete-pending-close Epics are listed here.

---

## EP-013: Controlled GitHub Mutations

**Status:** Complete-pending-close
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-09
**Target Close Date:** TBD
**Close Date:** TBD

## Goal

Implement Slice 5 of the Live Demo GitHub Plan so Airframe can optionally demonstrate controlled GitHub write operations after read-only behavior is verified.

## Rationale

Airframe currently reads live GitHub issue state through a read-only `github-issues` backend. Slice 5 needs write support that preserves Airframe authority boundaries: writes must be explicit, auditable, disabled by default, and subject to user approval before live mutation.

## Scope

- Define the authority, approval, and audit contract for controlled GitHub mutations.
- Add explicit GitHub issue comment and evidence-comment support.
- Add bounded GitHub status label transition support.
- Expose mutation paths only through explicit commands or human-facing actions.
- Verify default-disabled behavior, approval paths, audit evidence, and documentation.

## Out of Scope

- Silent or implicit GitHub writes during read-only commands.
- Long-lived credential storage in Airframe-generated files.
- AICockpit performing human-only acceptance operations.
- Bulk issue edits, project board automation, pull request mutations, or repository writes outside GitHub Issues.
- Closing GitHub issues without explicit human approval.

## Acceptance Criteria

1. Controlled GitHub mutations are disabled by default or require an explicit opt-in path.
2. Each mutation command/action is explicit about the GitHub write it performs.
3. Comment/evidence-comment writes are auditable and tied to an Airframe work item.
4. Status label transitions are bounded to Airframe workflow status labels and preserve local authority rules.
5. Verification proves read-only commands still perform no GitHub mutations.
6. Documentation states approval, audit, and credential expectations for live write demonstrations.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-013 | Plan and implement controlled GitHub mutation work for Slice 5 | Review |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0066 | Define controlled GitHub mutation authority contract | Implemented - Not Verified |
| T-0067 | Add GitHub issue comment mutation support | Implemented - Not Verified |
| T-0068 | Add controlled GitHub status label transition support | Implemented - Not Verified |
| T-0069 | Wire explicit mutation commands and UI affordances | Implemented - Not Verified |
| T-0070 | Verify controlled mutation safety and documentation | Implemented - Not Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

### Notes

- Source plan: [Live Demo GitHub Plan](../Live-Demo-GitHub-Plan.md), Slice 5.
- Candidate write operations are issue comments, evidence comments, status label updates, moving issues to verified, and issue closure.
- User approval remains required before live demonstration writes.
- GitHub issues #66 through #70 were created for T-0066 through T-0070 on 2026-06-09 and moved to Active when SP-013 opened.
- SP-013 implementation passed `scripts/verify-sp013.sh` and AgileCockpit tests on 2026-06-09 and is awaiting human verification.

---

*Last Updated: 2026-06-09 (SP-013 implemented and awaiting verification)*
