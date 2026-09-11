# Agent token-economy guidance

Use AICockpit as the canonical-first discovery surface. Start with `context` or
`project summary`, then request one Task packet or artifact inspection by ID;
do not load broad tracking projections to find a single work item.

Use command-specific help (`task create --help`) and the versioned discovery
schema (`schema --output json`) once per session, then reuse that knowledge.
For lists, select `--fields` and `--limit`; for diagnostics, use `--id` when
investigating one artifact. Treat mutation responses as receipts and inspect
the linked artifact only when more detail is required.

Within one Task, run at most one approved full-state diagnostic, import, or
export. Full diagnostics require `--all-records --approve`; full Markdown
imports require `--full-reconcile --approve`; full exports require
`--all-records --approve`. Prefer ID-scoped commands for every retry and
follow-up check.

Plans remain proposals until a human approves them in AgileCockpit. Agent work
may implement an approved plan and make only the workflow transitions allowed
by `AGENTS.md`; it must never substitute a human verification, closure, or
plan decision.
