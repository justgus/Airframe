# EP-021: Requirements Traceability and Release Evidence

**Status:** Closed
**Owner:** Human / Airframe Planning
**Start Date:** 2026-06-23
**Target Close Date:** TBD
**Close Date:** 2026-06-24

**Goal:**
Add lightweight repo-coupled requirements traceability, test evidence summaries, release candidate gate visibility, external import/export stubs, and generated compliance documentation support without turning Airframe into a replacement for DOORS.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-029 | Define the canonical requirement record model and interchange formats. | Closed |
| SP-030 | Add traceability graph queries, revision metadata, and gap diagnostics. | Closed |
| SP-031 | Add summarized evidence records, release gates, and Cockpit views. | Closed |
| SP-032 | Generate compliance documents and regression coverage for the migration. | Closed |
| SP-033 | Import existing requirements documentation into canonical requirement records and expose them in the release gate. | Closed |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0132 | Define canonical requirement records | Implemented - Verified |
| T-0133 | Implement requirement CSV and JSON interchange | Implemented - Verified |
| T-0134 | Add import preview and conflict reporting | Implemented - Verified |
| T-0135 | Add traceability graph queries | Implemented - Verified |
| T-0136 | Add revision metadata and lifecycle diagnostics | Implemented - Verified |
| T-0137 | Add traceability gap diagnostics | Implemented - Verified |
| T-0138 | Add summarized evidence records | Implemented - Verified |
| T-0139 | Add release gate evaluation | Implemented - Verified |
| T-0140 | Add AgileCockpit release gate visibility | Implemented - Verified |
| T-0141 | Generate compliance and traceability documents | Implemented - Verified |
| T-0142 | Add regression tests for import/export, traceability, and gates | Implemented - Verified |
| T-0143 | Define AICockpit requirements import command contract | Implemented - Not Verified |
| T-0144 | Implement canonical requirements import apply path | Implemented - Not Verified |
| T-0145 | Add Markdown requirements seed import support | Implemented - Not Verified |
| T-0146 | Regenerate requirements documentation from canonical state | Implemented - Not Verified |
| T-0147 | Add requirements import regression coverage | Implemented - Not Verified |

### Closeout Notes

- EP-021 was closed by human direction on 2026-06-25 during closeout data repair.
- SP-033 is closed, while T-0143 through T-0147 remain Implemented - Not Verified.
