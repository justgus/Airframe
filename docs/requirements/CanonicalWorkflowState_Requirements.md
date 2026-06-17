# Canonical Workflow State Requirements

**Status:** Planning  
**Date:** 2026-06-17  
**Applies To:** AirframeCore, AICockpit, AgileCockpit

## 1. Purpose

Define requirements for moving Airframe workflow state from Markdown-authored artifacts to AirframeCore-owned canonical records.

Airframe work products are part of the project repository. A branch, fork, checkout, revert, or patch must carry the workflow state that existed with the source code at that revision.

## 2. Scope

These requirements cover:

- Canonical records for Epics, Sprints, Tasks, Issues, requirements, evidence, and trace links.
- Repo-local persistence.
- Validation diagnostics.
- Generated documentation projections.
- Test and CI evidence summaries.
- Release candidate close criteria.
- External requirements import/export stubs.

These requirements do not define a full enterprise requirements management system.

## 3. Requirements

### CWS-FR-001 Canonical Repo-Local Store

Airframe shall maintain canonical workflow state in a repo-local structured store.

Rationale: workflow state must move with the source code across branches, forks, checkouts, and reverts.

### CWS-FR-002 Stable Work Item Identity

Airframe shall assign stable IDs to Epics, Sprints, Tasks, Issues, Requirements, Evidence records, and Trace records.

### CWS-FR-003 Relationship Model

Airframe shall represent relationships between work products by ID, including:

- Epic to Sprint.
- Epic to Task.
- Epic to Issue.
- Sprint to Task.
- Sprint to Issue.
- Requirement to Task.
- Requirement to Test.
- Requirement to Evidence.
- Task or Issue to Evidence.
- Work item to GitHub issue where applicable.

### CWS-FR-004 Workflow Policy Authority

AirframeCore shall own workflow status definitions, allowed transitions, preconditions, and authority checks.

### CWS-FR-005 Markdown Projection

Airframe shall support generating human-readable Markdown documentation from canonical records.

Markdown projections shall not be the sole source of workflow truth.

### CWS-FR-006 Validation Diagnostics

AirframeCore shall detect inconsistent workflow state and report diagnostics with:

- Severity.
- Affected IDs.
- Reason code.
- Explanation.
- Recommended repair options.
- Required authority for repair.

### CWS-FR-007 Repair Preview

Airframe shall support previewing proposed repair actions before applying them.

### CWS-FR-008 Audit Events

Airframe shall record audit events for canonical state mutations, including actor, operation, affected IDs, before state, after state, and authority decision.

### CWS-FR-009 Test Evidence Summary

Airframe shall support recording summarized test evidence without storing every raw local test run.

At minimum, test evidence shall include:

- Command or test source.
- Pass/fail summary.
- Relevant failing tests when applicable.
- Timestamp.
- Environment summary.
- Linked requirement IDs when applicable.
- Optional CI run or artifact link.

### CWS-FR-010 CI Evidence Link

Airframe shall support linking verification evidence to CI runs or CI artifacts when CI is configured.

CI evidence shall supplement, not replace, AirframeCore requirement verification policy.

### CWS-FR-011 Requirement Traceability

Airframe shall support traceability between requirements, implementation work, tests, evidence, and release decisions.

### CWS-FR-012 Fluid Requirements

Airframe shall support requirement changes during development, including created, revised, superseded, deferred, waived, and removed requirement states.

### CWS-FR-013 External Import Export Stubs

Airframe shall reserve interfaces for importing and exporting requirements from external tools.

Version 1.0 shall prioritize diffable local formats such as CSV and JSON. DOORS integration shall remain out of scope for Version 1.0 but shall not be precluded by the data model.

### CWS-FR-014 Release Candidate Gate

Airframe shall support release candidate close criteria based on workflow state, requirement traceability, verification evidence, validation approval, deviations, and blocking Issues.

### CWS-FR-015 Generated Compliance Outputs

Airframe shall support generating compliance and traceability documents from canonical records when templates are available.

Candidate outputs include:

- Compliance Verification Matrix.
- Requirements Traceability Matrix.
- Bidirectional Requirements Traceability Matrix.
- Deviation or waiver report.
- Test plan.
- Verification report.
- Release candidate closeout package.

## 4. Non-Functional Requirements

### CWS-NFR-001 Diffability

Canonical local state should be reasonably diffable in Git.

### CWS-NFR-002 Human Inspectability

Canonical state should be inspectable by humans using common repository tools.

### CWS-NFR-003 Deterministic Projection

Generated documentation should be deterministic to avoid noisy diffs.

### CWS-NFR-004 Backward Compatibility

Existing Markdown artifacts shall remain importable during migration.

### CWS-NFR-005 Authority Preservation

Human-only verification, Sprint closure, Epic closure, release closeout, destructive repair, and policy mutation shall remain protected by AirframeCore authority evaluation.

## 5. Version 1.0 Boundary

Version 1.0 should include:

- Canonical repo-local state model.
- Basic requirement records.
- Requirement-to-work and requirement-to-test trace links.
- Summary test evidence.
- CI evidence link fields.
- CSV and JSON requirement import/export.
- Generated Markdown projections.
- Data health diagnostics.
- Initial AgileCockpit release gate visibility.

Version 1.0 should not include:

- Native DOORS integration.
- Full enterprise requirements management.
- Full document-template authoring.
- Server-based synchronization.
- Mandated code comments for every requirement.

