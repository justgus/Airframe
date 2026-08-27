# Issue Backlog

Issues listed here are open and not assigned to a Sprint.

---

---

*Last Updated: 2026-08-22 (GitHub issue sync)*

## I-0027: Agile Cockpit: support branch-based workspace mutations

**Status:** Open
**GitHub Issue:** #177
**Platform:** Not applicable
**Component:** TBD
**Severity:** Medium
**Epic:** None
**Sprint:** Not Assigned
**Date Identified:** 2026-08-22
**Fix Date:** TBD
**Verification Date:** TBD

**Description:**
Imported from GitHub Issue #177.

> ## Problem
> 
> Agile Cockpit currently applies workflow mutations to the checked-out branch without ensuring that the workspace is on a review branch. In IrisOS, closing SP-001 through the Cockpit wrote the Sprint-close changes directly onto `main`.
> 
> The closure also regenerated canonical projections in the working tree, so the resulting changes needed manual recovery onto a `codex/...` branch before they could be reviewed through the repository PR workflow.
> 
> ## Requested behavior
> 
> Agile Cockpit should support branch-aware mutations for operations such as closing a Sprint.
> 
> ## Acceptance criteria
> 
> - Before a mutating operation, detect the current Git branch and working-tree state.
> - Allow a workspace to configure its protected/default branch and review-branch naming convention.
> - When the current branch is protected, offer to create or select a review branch before writing.
> - Never silently apply a mutation directly to a configured protected branch.
> - Preserve pre-existing tracked and untracked working-tree changes.
> - Report the branch receiving the mutation in the confirmation and completion UI.
> - Add tests covering clean and dirty worktrees, protected branches, and branch-creation failure.
> 
> ## Reproduction
> 
> 1. Open an Airframe workspace while its repository is on `main`.
> 2. Close an active Sprint through Agile Cockpit.
> 3. Observe that state and Markdown projections are written directly to `main` rather than a review branch.
> 
> Observed with the IrisOS SP-001 closure on 2026-08-21.

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
- GitHub Issue #177

**Verification:**
1. TBD.

**Related Items:**
- None.

---
