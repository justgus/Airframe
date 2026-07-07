# EP-024: Canonical Test Definition and Management

**Status:** Closed
**Owner:** Human / Airframe Planning
**Start Date:** TBD
**Target Close Date:** TBD
**Close Date:** 2026-07-07

**Goal:**
Add canonical test definition and management support so Agile Airframe can define tests that verify acceptance criteria and trace back to requirements.

**Rationale:**
Agile Airframe has canonical requirements and evidence summaries, but it lacks explicit canonical test definitions and a management surface for tests. Without tests that verify acceptance criteria, requirements without ACs cannot be reviewed or verified cleanly.

**Scope:**
- Define canonical test case, test suite, and test run records.
- Model test-to-acceptance-criterion links as the primary verification trace back to requirements.
- Seed test definitions for the current canonical Airframe dataset.
- Add AICockpit commands to manage and validate test definitions.
- Add an AgileCockpit Tests tab for human review of tests, AC coverage, and requirement traceability.
- Define missing EP-023 acceptance criteria for requirements without AC coverage and pair each new AC with a test definition.

### Related Sprints

| Sprint | Status |
| ---- | ---- |
| SP-037 |  |

### Related Tasks

| Task | Status |
| ---- | ---- |
| T-0160 |  |
| T-0161 |  |
| T-0162 |  |
| T-0163 |  |
| T-0164 |  |
| T-0165 |  |

### Related Issues

| Issue | Status |
| ---- | ---- |
| I-0025 |  |
| I-0026 |  |
| I-0027 |  |
| I-0029 |  |
| I-0028 |  |
| I-0030 |  |

**Notes:**
- Created on 2026-07-06 after the reduced Requirements Traceability Matrix exposed requirements without Epic acceptance-criterion coverage.
- Tests verify acceptance criteria. Requirement test traceability is therefore Requirement -> Epic AC -> Test.
- EP-023 remains the owner for new final-review acceptance criteria needed to cover requirements that currently have no ACs.
