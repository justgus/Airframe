# Requirements Traceability Import Export Plan

**Status:** Planning  
**Date:** 2026-06-17  
**Applies To:** AirframeCore, AICockpit, AgileCockpit

## 1. Purpose

Define a lightweight import/export plan for requirements and traceability data.

Airframe should support diffable requirements workflows without becoming a replacement for DOORS or other enterprise requirements tools.

## 2. Principles

1. Repo-local canonical records remain the Airframe source of truth for project-coupled development state.
2. External requirements tools may provide imported source data.
3. CSV and JSON are the Version 1.0 interchange formats.
4. Imports must be previewable before they mutate canonical state.
5. Imports must preserve source metadata and revision rationale where possible.
6. Exports must support Git diff review.
7. DOORS and similar tools are future adapters, not Version 1.0 commitments.

## 3. Requirement Record Fields

Candidate fields:

| Field | Purpose |
| --- | --- |
| `id` | Stable Airframe requirement ID. |
| `externalID` | Source tool or document ID, if any. |
| `title` | Short requirement title. |
| `statement` | Requirement text. |
| `rationale` | Why the requirement exists. |
| `source` | Airframe, CSV, external tool, generated, or manual. |
| `sourceURI` | File, tool, or document reference. |
| `status` | Proposed, Draft, Active, Implemented, Verified, Validated, Deferred, Waived, Superseded, Removed. |
| `priority` | Project-defined priority. |
| `verificationMethod` | Test, analysis, inspection, demonstration, review, or mixed. |
| `validationRequired` | Whether human or stakeholder validation is required. |
| `releaseScope` | Release or candidate applicability. |
| `parentIDs` | Parent requirement IDs. |
| `derivedFromIDs` | Source requirement IDs for derived requirements. |
| `supersedesIDs` | Requirements replaced by this requirement. |
| `traceLinks` | Linked work, tests, evidence, code, and design records. |
| `deviationIDs` | Linked deviations or waivers. |
| `revision` | Requirement revision marker. |
| `changeRationale` | Why the requirement changed. |

## 4. CSV Import

CSV import should support a practical Excel-compatible workflow.

Minimum CSV columns:

```text
id,external_id,title,statement,status,verification_method,validation_required,priority,release_scope
```

Optional CSV columns:

```text
rationale,source,source_uri,parent_ids,derived_from_ids,supersedes_ids,change_rationale
```

Import behavior:

- Dry-run by default for command-line import.
- Show created, updated, unchanged, removed, and conflicted records.
- Preserve Airframe IDs when present.
- Match by external ID when Airframe ID is absent and policy allows.
- Require explicit approval for destructive removal.
- Treat missing optional columns as no change.
- Record import source metadata.

## 5. CSV Export

CSV export should support:

- Requirements list.
- Requirements with verification status.
- Requirements with traceability gaps.
- Release-scope requirements.
- Deviation and waiver summary.

Exports should be deterministic.

## 6. JSON Import Export

JSON import/export should use the canonical record schema.

Use cases:

- Repo-to-repo migration.
- Backup and review.
- Generated baselines.
- Future external adapter handoff.

JSON import must validate schema version before applying changes.

## 7. External Tool Adapter Stubs

AirframeCore should define adapter boundaries for external tools.

Candidate protocol capabilities:

- List source requirements.
- Import source requirements.
- Export Airframe requirements.
- Map external IDs to Airframe IDs.
- Report unsupported fields.
- Preserve source revision metadata.

Version 1.0 stubs:

- CSV adapter.
- JSON adapter.
- Placeholder adapter type for future DOORS integration.

No native DOORS API integration is planned for Version 1.0.

## 8. Diffable Review Workflow

Recommended workflow:

1. Export current requirements to CSV or JSON.
2. Edit in Excel or another tool.
3. Import with dry run.
4. Review proposed changes in AgileCockpit or AICockpit JSON output.
5. Apply approved import.
6. Commit canonical state and generated documentation.

## 9. Generated Documentation Outputs

Import/export data should feed generated documents:

- Requirements list.
- Requirements Traceability Matrix.
- Compliance Verification Matrix.
- Bidirectional Requirements Traceability Matrix.
- Deviation or waiver report.
- Release candidate closeout summary.

Generated documents require templates or deterministic default layouts.

## 10. Version 1.0 Boundary

Version 1.0 should include:

- CSV import dry run.
- CSV import apply.
- CSV export.
- JSON import/export.
- Requirement source metadata.
- Requirement change summaries.
- Traceability gap diagnostics.

Version 1.0 should defer:

- DOORS native API integration.
- Round-trip fidelity for proprietary tool metadata.
- Complex document template editing.
- Enterprise approval workflows outside Airframe.

