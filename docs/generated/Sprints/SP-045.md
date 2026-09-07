# SP-045: Performance Improvement and Resource Reduction

**Status:** Closed
**Epic:** EP-025
**Goal:** Reduce agent token consumption by adding granular read primitives to AICockpit, so that answering a question about one record does not require loading the corpus.
**Start Date:** 2026-09-07
**End Date:** 2026-09-21
**Capacity:** 2 tasks

### Assigned Tasks

| Task | Status |
| ---- | ---- |
| T-0190 |  |
| T-0199 |  |

### Assigned Issues

None.

**Notes:**
- Scope driven by measured read amplification: task list ~10,200 tokens for 189 records; requirements have no single-record read at all.
- task|issue|sprint|epic inspect already exists and costs ~186 tokens; this Sprint closes the equivalent gap for requirements and adds filtering to list.
- T-0190 provides granular reads and GitHub-backend mutation support; T-0199 de-duplicates the AgileCockpit cache payload and launch fingerprint.
- Verification: focused AICockpit and AirframeCore tests, token-cost evidence, and targeted canonical diagnostics before status changes.
