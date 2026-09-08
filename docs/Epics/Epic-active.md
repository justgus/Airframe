# Epic Active

Epics listed here are drafted, active, or complete-pending-close and are the current focus of planning or execution.

---

## EP-025: Audit Finding Remediation

**Status:** Active
**Owner:** 
**Start Date:** TBD
**Target Close Date:** TBD
**Close Date:** TBD

**Goal:**
Remediate the findings of the 2026-08-27 Audit across configuration, requirement data, projections, legacy artifacts, GitHub integration, and canonical evidence, so that canonical state, its generated projections, and the GitHub backend agree and stay that way.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |
| SP-038 |  | Closed |
| SP-039 | Remove duplicated active-context pointers and define an explicit backend-mapping model, so the active Epic and Sprint have one authoritative source and Cockpit interfaces render mapping state directly. | Closed |
| SP-040 | Correct the requirement importer's section-boundary handling, repair the requirements it mis-parsed, and regenerate the requirement projections so canonical requirement data matches its documented source. | Closed |
| SP-041 | Make canonical projection refresh durable and complete, and render artifact terminology and relationship statuses consistently, so generated documents are a trustworthy view of canonical state. | Planning |
| SP-042 | Retire the mutable Legacy Issue and Task current-state files and reconcile the remaining Legacy links, archives, and compatibility policy, so canonical state is the single source for current work status. | Planning |
| SP-044 | Make canonical implementation evidence attachable, inspectable, reviewable, and integrity-checked through AICockpit and AgileCockpit. | Planning |
| SP-043 | Complete GitHub integration with full pagination and disclosure, canonical-to-GitHub reconciliation, and branch-aware workspace mutations, then verify the integrated audit remediation end to end. | Planning |
| SP-045 | Reduce agent token consumption by adding granular read primitives to AICockpit, so that answering a question about one record does not require loading the corpus. | Closed |
| SP-046 | Reduce AICockpit token churn while preserving canonical-first artifact management, relationship integrity, and human approval boundaries. | Planning |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |
| T-0166 | Define historical-close acceptance disposition | Implemented - Verified |
| T-0167 | Repair canonical membership and reciprocal relationships | Implemented - Verified |
| T-0168 | Implement systematic canonical invariant diagnostics | Implemented - Verified |
| T-0169 | Remove duplicated active-context configuration pointers | Implemented - Verified |
| T-0170 | Define optional backend-mapping state model | Implemented - Verified |
| T-0171 | Expose mapping and active-context state in Cockpit interfaces | Implemented - Verified |
| T-0172 | Correct requirement importer section boundaries | Implemented - Verified |
| T-0173 | Repair and source-compare affected requirements | Implemented - Verified |
| T-0174 | Regenerate and validate requirement projections | Implemented - Verified |
| T-0175 | Make canonical projection refresh durable | Backlog |
| T-0176 | Render artifact terminology and relationship statuses | Backlog |
| T-0177 | Investigate projection omission and regenerate the complete set | Backlog |
| T-0178 | Retire mutable Legacy Issue current-state files | Backlog |
| T-0179 | Retire mutable Legacy Task current-state files | Backlog |
| T-0180 | Reconcile Legacy links, archives, and compatibility policy | Backlog |
| T-0181 | Implement complete GitHub pagination and disclosure | Backlog |
| T-0182 | Implement canonical-to-GitHub reconciliation | Backlog |
| T-0183 | Implement branch-aware AgileCockpit mutations | Backlog |
| T-0184 | Complete integrated audit remediation verification | Backlog |
| T-0185 | Implement canonical evidence repository operations | Backlog |
| T-0186 | Add native AICockpit evidence commands | Backlog |
| T-0187 | Add AgileCockpit evidence review interface | Backlog |
| T-0188 | Diagnose and migrate evidence relationship integrity | Backlog |
| T-0189 | Verify native evidence workflow and retire fallback | Backlog |
| T-0190 | Add granular read primitives and close the github-issues mutation gap in AICockpit | Implemented - Verified |
| T-0191 |  |  |
| T-0192 | Add command-specific help and complete Task option documentation | Backlog |
| T-0193 | Add compact output and selective detail projections | Backlog |
| T-0194 | Reconcile Task Sprint and Epic relationships on mutation | Backlog |
| T-0195 | Publish versioned machine-readable command schema | Backlog |
| T-0196 | Add targeted validation and concise mutation receipts | Backlog |
| T-0197 | Materialize approved planning structures atomically | Backlog |
| T-0198 | Document agent token-economy operating guidance | Backlog |
| T-0199 | De-duplicate AgileCockpit cache payloads and digest the launch fingerprint | Implemented - Verified |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |
| I-0031 | AgileCockpit should support branch-based workspace mutations | Backlog |
| I-0032 | Workspace appears empty during slow startup traceability rebuild | Implemented - Verified |
| I-0033 | Empty narrative fields render as blank sections in Sprint and Epic detail views | Backlog |
| I-0034 | Requirement gap diagnostics ignore lifecycle status and flag unstarted requirements | Implemented - Verified |
| I-0035 | Correct Sprint close-action label for active Sprints | Backlog |

## EP-026: First-Class Requirements, Tests, and Evidence Work Products

**Status:** Draft
**Owner:** justgus
**Start Date:** TBD
**Target Close Date:** TBD
**Close Date:** TBD

**Goal:**
Elevate Requirements, Tests, and Acceptance Criteria evidence to first-class Agile work products with their own workflow states, authority boundaries, and Cockpit surfaces.

### Related Sprints

| Sprint | Goal | Status |
| ------ | ---- | ------ |

### Related Tasks

| Task | Title | Status |
| ---- | ----- | ------ |

### Related Issues

| Issue | Title | Status |
| ----- | ----- | ------ |

*Last Updated: 2026-09-08*
