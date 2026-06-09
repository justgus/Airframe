# Controlled GitHub Mutations

**Status:** Active implementation contract for EP-013 / SP-013.

## Purpose

Controlled GitHub mutations allow the live demo to perform narrowly scoped GitHub issue writes while preserving Airframe authority boundaries. Read-only commands remain side-effect free.

## Approved Mutation Classes

| Mutation | Operation | Authority Category | Notes |
| -------- | --------- | ------------------ | ----- |
| Issue comment | `OP-GITHUB-ISSUE-COMMENT` | Evidence | Adds an explicit comment to the mapped GitHub issue. |
| Evidence comment | `OP-GITHUB-EVIDENCE-COMMENT` | Evidence | Adds structured Airframe evidence as a GitHub issue comment. |
| Status label transition | `OP-GITHUB-MOVE-ACTIVE`, `OP-GITHUB-MARK-READY`, `OP-GITHUB-MOVE-BACKLOG` | Workflow Transition | Replaces only Airframe `status-*` labels. |
| Human verification label transition | `OP-HUMAN-VERIFY` | Human Acceptance | Must remain human-controlled; AICockpit must not perform it. |
| Issue closure | `OP-GITHUB-CLOSE-WORK` | Destructive | Out of scope for automated Slice 5 implementation without separate explicit approval. |

## Rules

1. Existing read commands must not mutate GitHub.
2. Live GitHub writes require an explicit mutation command or human-facing action.
3. Live GitHub writes require explicit approval data.
4. Every approved write returns audit evidence identifying action, work item, issue number, actor, and target project.
5. AICockpit may add comments, evidence comments, and permitted workflow transitions, but it must not perform human-only verification.
6. Status transitions may only replace Airframe status labels: `status-backlog`, `status-active`, `status-unverified`, `status-verified`, and `status-closed`.
7. Epic, sprint, type, priority, and unrelated GitHub labels are not edited by status mutation operations.

## AICockpit Commands

```sh
aicockpit github comment T-XXXX \
  --body "Comment text" \
  --approve \
  --approved-by "Human" \
  --backend github-issues

aicockpit github evidence-comment T-XXXX \
  --id EV-XXXX-001 \
  --summary "Evidence summary" \
  --artifact "Verification artifact" \
  --approve \
  --approved-by "Human" \
  --backend github-issues

aicockpit github status T-XXXX \
  --to unverified \
  --approve \
  --approved-by "Human" \
  --backend github-issues
```

Missing approval must fail before live GitHub lookup or write.

## Verification

Automated verification uses stub GitHub transports for approved write behavior and denied/default-disabled paths. Live write demonstrations require an explicit human-selected issue and approval immediately before the command is run.
