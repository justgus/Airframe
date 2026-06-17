# Requirements Traceability Requirements

**Status:** Planning  
**Date:** 2026-06-17  
**Applies To:** AirframeCore, AICockpit, AgileCockpit

## 1. Purpose

Define requirements for lightweight requirements traceability, verification, validation, and release candidate close criteria in Airframe.

Airframe shall support traceability without becoming a replacement for enterprise requirements tools such as DOORS.

## 2. Definitions

- **Requirement:** A capability, constraint, behavior, interface, quality, or compliance obligation that the project tracks.
- **Verification:** Evidence that the implementation satisfies the stated requirement.
- **Validation:** Human or stakeholder determination that the requirement and resulting behavior satisfy the intended need.
- **Deviation:** Approved divergence from a requirement.
- **Waiver:** Approved decision not to satisfy a requirement for a given release or scope.
- **Trace Link:** Structured relationship between a requirement and work, design, code, test, evidence, or release state.

## 3. Functional Requirements

### RT-FR-001 Requirement Records

Airframe shall maintain canonical requirement records with stable IDs.

### RT-FR-002 Requirement Revision State

Airframe shall support requirement revision metadata, including status, source, version, rationale, and change history.

### RT-FR-003 Fluid Requirement Lifecycle

Airframe shall support requirement lifecycle states suitable for active development, including:

- Proposed.
- Draft.
- Active.
- Implemented.
- Verified.
- Validated.
- Deferred.
- Waived.
- Superseded.
- Removed.

### RT-FR-004 Requirement Source

Airframe shall record whether a requirement was authored in Airframe, imported from a file, imported from an external tool, generated from another artifact, or manually entered.

### RT-FR-005 Implementation Trace

Airframe shall support linking requirements to Tasks, Issues, Epics, Sprints, design records, source references, and commits where available.

### RT-FR-006 Verification Trace

Airframe shall support linking requirements to test cases, test results, manual verification records, CI runs, and evidence artifacts.

### RT-FR-007 Validation Trace

Airframe shall support linking requirements to human validation decisions and stakeholder approval evidence.

### RT-FR-008 Bidirectional Traceability

Airframe shall support queries in both directions:

- From a requirement to implementing work, tests, evidence, and code references.
- From work, tests, evidence, and code references back to requirements.

### RT-FR-009 Traceability Gap Detection

AirframeCore shall detect missing or incomplete traceability for in-scope requirements.

Example gaps:

- Requirement has no implementing work.
- Requirement has no verification method.
- Requirement has no passing verification evidence.
- Requirement has verification evidence but no validation decision where validation is required.
- Source reference claims a requirement that does not exist.

### RT-FR-010 Release Scope

Airframe shall support defining which requirements are in scope for a release candidate.

### RT-FR-011 Release Gate Summary

AgileCockpit shall show release candidate close criteria, including:

- In-scope requirements count.
- Implemented requirements count.
- Verified requirements count.
- Validated requirements count.
- Deferred or waived requirements count.
- Open deviations.
- Blocking traceability gaps.
- Blocking Issues.
- Missing test evidence.
- Missing human approvals.

### RT-FR-012 Deviation And Waiver Records

Airframe shall support deviation and waiver records linked to affected requirements, rationale, authority, release scope, and expiration or review conditions.

### RT-FR-013 Test Result Summaries

Airframe shall support storing summarized test result records that link to requirements.

Raw test logs may be external artifacts or CI artifacts and do not need to be committed to the repository.

### RT-FR-014 CI Integration Link

Airframe shall support optional CI links for test results, coverage results, build results, and release candidate evidence.

### RT-FR-015 Code Reference Trace

Airframe shall support optional code-level trace references to requirements.

Supported references may include:

- Source comments.
- Test names.
- Test metadata.
- Work item records.
- Commit metadata.
- Generated source scans.

Airframe shall not require every requirement to be referenced directly in code comments unless project policy requires it.

### RT-FR-016 Compliance Document Generation

Airframe shall support generating traceability and compliance documents from canonical records and templates.

Initial document targets:

- Compliance Verification Matrix.
- Requirements Traceability Matrix.
- Bidirectional Requirements Traceability Matrix.
- Deviation or waiver report.
- Test plan.
- Verification report.
- Release candidate closeout report.

## 4. Import Export Requirements

### RT-IE-001 CSV Import

Airframe shall support importing requirements from CSV.

### RT-IE-002 CSV Export

Airframe shall support exporting requirements and traceability summaries to CSV.

### RT-IE-003 JSON Import Export

Airframe shall support importing and exporting canonical requirement records as JSON.

### RT-IE-004 Diffable Workflow

Requirement import/export files shall support review through Git diffs where practical.

### RT-IE-005 External Tool Stubs

Airframe shall reserve import/export adapter boundaries for external requirements tools such as DOORS.

Native DOORS integration is out of scope for Version 1.0.

## 5. Release Gate Requirements

### RT-RG-001 Configurable Gate Policy

AirframeCore shall support configurable release gate policy.

### RT-RG-002 Default Gate Policy

The default release candidate gate shall require:

- No blocking Issues.
- All in-scope requirements are implemented, deferred, waived, or explicitly out of scope.
- All in-scope non-deferred requirements have required verification evidence.
- All requirements requiring validation have validation approval.
- All deviations and waivers have approving authority.
- No blocking traceability diagnostics remain.

### RT-RG-003 Gate Explanation

AirframeCore shall explain why a release candidate can or cannot close.

### RT-RG-004 Human Authority

Final release candidate closeout and validation approval shall require human authority.

## 6. Version 1.0 Boundary

Version 1.0 should provide a lightweight traceability foundation:

- Requirement records.
- CSV/JSON import/export.
- Requirement-to-work trace links.
- Requirement-to-test trace links.
- Test evidence summaries.
- Release gate summary.
- Generated traceability reports from simple templates.

Version 1.0 should avoid:

- Full DOORS replacement behavior.
- Deep external requirements-tool synchronization.
- Mandatory source-code annotation for all requirements.
- Heavy template authoring workflows.

