# Issue Backlog

> **Historical narrative — not a current-state authority.** Current Issue state is in `.airframe/state/` and is viewed through AgileCockpit or the deterministic projections in [`../generated/Issues/`](../generated/Issues/). Do not add, move, or update Issues in this file.

Issues listed here are open and not assigned to a Sprint.

---

## I-0031: Agile Cockpit applies workflow mutations to the checked-out branch without branch guarding

**Status:** Backlog
**GitHub Issue:** #177
**Platform:** macOS
**Component:** AgileCockpit, Sprint Workflow, Canonical State, Markdown Projector
**Severity:** Medium
**Epic:** None
**Sprint:** Not Assigned
**Date Identified:** 2026-08-22
**Fix Date:** TBD
**Verification Date:** TBD

**Description:**
Agile Cockpit applies workflow mutations to whatever branch the workspace currently has checked out, without first checking whether that branch is protected. Closing a Sprint therefore writes canonical state changes and regenerated Markdown projections directly onto `main`.

Reported from the IrisOS project against the SP-001 closure on 2026-08-21. The behavior is a missing capability in Airframe rather than a regression: branch-aware mutation has never been implemented.

**Expected Behavior:**
Before performing a mutating operation, Agile Cockpit should detect the current Git branch and working-tree state. When the current branch is the configured protected branch, it should offer to create or select a review branch and write the mutation there, reporting the receiving branch in both the confirmation and completion UI. Pre-existing tracked and untracked working-tree changes should be preserved.

**Actual Behavior:**
The mutation is applied silently to the checked-out branch. With `main` checked out, Sprint-close state changes and regenerated projections land on `main` with no warning and no branch selection step. Recovering them onto a review branch requires manual Git work after the fact.

**Steps to Reproduce:**
1. Open an Airframe workspace while its repository is on `main`.
2. Close an active Sprint through Agile Cockpit.
3. Observe that canonical state and Markdown projections are written directly to `main` rather than to a review branch.

**Impact:**
- Sprint-close changes bypass the repository PR review workflow.
- Recovering the changes onto a `codex/...` review branch requires manual Git intervention.
- Projection regeneration compounds the problem by producing a large diff directly on the protected branch.
- Any workspace whose process depends on protected-branch enforcement cannot safely use Cockpit mutations.

**Root Cause Analysis:**
TBD. Initial assessment is a missing feature: the mutation path has no branch-detection or branch-selection step, and the workspace model has no field for a protected branch or a review-branch naming convention.

**Resolution:**
TBD.

**Files Affected:**
- TBD.

**Evidence:**
- GitHub Issue #177
- IrisOS SP-001 closure, 2026-08-21

**Verification:**
1. With a clean worktree on the protected branch, close a Sprint and confirm Cockpit prompts for a review branch and writes only to it.
2. With a dirty worktree, confirm pre-existing tracked and untracked changes survive the operation.
3. On a non-protected branch, confirm the mutation proceeds and names the receiving branch in the completion UI.
4. Simulate a branch-creation failure and confirm the mutation aborts without partial writes.
5. Confirm tests cover clean worktree, dirty worktree, protected branch, and branch-creation failure.

**Acceptance Criteria (from GitHub Issue #177):**
- Before a mutating operation, detect the current Git branch and working-tree state.
- Allow a workspace to configure its protected/default branch and review-branch naming convention.
- When the current branch is protected, offer to create or select a review branch before writing.
- Never silently apply a mutation directly to a configured protected branch.
- Preserve pre-existing tracked and untracked working-tree changes.
- Report the branch receiving the mutation in the confirmation and completion UI.
- Add tests covering clean and dirty worktrees, protected branches, and branch-creation failure.

**Related Items:**
- Reported from the IrisOS project.
- Related to audit finding F-08 in [Audit-Findings-20260827.md](../Audits/Audit-Findings-20260827.md): the nightly sync originally imported this Issue as I-0027, an ID already allocated to a verified Issue. Renumbered to I-0031.

---

*Last Updated: 2026-09-07 (GitHub issue sync)*

## I-0032: [SP-046] Reduce AICockpit token churn

**Status:** Open
**GitHub Issue:** #180
**Platform:** Not applicable
**Component:** TBD
**Severity:** Medium
**Epic:** None
**Sprint:** Not Assigned
**Date Identified:** 2026-09-07
**Fix Date:** TBD
**Verification Date:** TBD

**Description:**
Imported from GitHub Issue #180.

> ## Airframe
> - id: SP-046
> - kind: sprint
> - status: Active
> - epic: EP-025
> 
> ## Goal
> 
> Reduce AICockpit token churn while preserving canonical-first artifact management, relationship integrity, and human approval boundaries.
> 
> ## Schedule and capacity
> 
> - Start date: 2026-09-06
> - End date: 2026-09-20
> - Capacity: 7 backlog tasks
> 
> ## Assigned Tasks
> 
> - T-0192 — Command-specific help and complete Task option documentation
> - T-0193 — Compact output and selective detail projections
> - T-0194 — Task/Sprint/Epic relationship reconciliation
> - T-0195 — Versioned machine-readable command schema
> - T-0196 — Targeted validation and concise mutation receipts
> - T-0197 — Approved planning-structure materialization
> - T-0198 — Agent token-economy operating guidance
> 
> ## Verification
> 
> - Run focused AICockpit and AirframeCore tests.
> - Run targeted canonical state diagnostics after coherent implementation batches.
> 
> ## Notes
> 
> - T-0190 remains assigned to SP-045 and is out of scope.
> - PLAN-025-046 is pending a human-only decision in AgileCockpit.
> - GitHub synchronization follows canonical record creation.

**Expected Behavior:**
TBD.

**Actual Behavior:**
TBD.

**Steps to Reproduce:**
1. TBD.

**Impact:**
- TBD.

**Root Cause Analysis:**
TBD.

**Resolution:**
TBD.

**Files Affected:**
- TBD.

**Evidence:**
- GitHub Issue #180

**Verification:**
1. TBD.

**Related Items:**
- None.

---
