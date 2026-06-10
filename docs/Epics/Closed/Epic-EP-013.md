# EP-013: Controlled GitHub Mutations

**Status:** Closed
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-09
**Target Close Date:** 2026-06-10
**Close Date:** 2026-06-10

## Goal

Implement Slice 5 of the Live Demo GitHub Plan so Airframe can optionally demonstrate controlled GitHub write operations after read-only behavior is verified.

## Scope Completed

- Defined the authority, approval, and audit contract for controlled GitHub mutations.
- Added explicit GitHub issue comment and evidence-comment support.
- Added bounded GitHub status label transition support.
- Exposed mutation paths only through explicit commands.
- Verified default-disabled behavior, approval paths, audit evidence, and documentation.

## Out Of Scope

- Silent or implicit GitHub writes during read-only commands.
- Long-lived credential storage in Airframe-generated files.
- AICockpit performing human-only acceptance operations.
- Bulk issue edits, project board automation, pull request mutations, or repository writes outside GitHub Issues.
- Closing GitHub issues without explicit human approval.

## Related Sprint

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-013 | Plan and implement controlled GitHub mutation work for Slice 5 | Closed |

## Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0066 | Define controlled GitHub mutation authority contract | Implemented - Verified |
| T-0067 | Add GitHub issue comment mutation support | Implemented - Verified |
| T-0068 | Add controlled GitHub status label transition support | Implemented - Verified |
| T-0069 | Wire explicit mutation commands and UI affordances | Implemented - Verified |
| T-0070 | Verify controlled mutation safety and documentation | Implemented - Verified |

## Closeout

The user verified EP-013 and Live Demo GitHub Plan Slice 5 on 2026-06-10. SP-013 was closed, and GitHub issues #66 through #70 were labeled `status-verified` and closed.
