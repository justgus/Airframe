# CLAUDE.md

**Read `AGENTS.md` first. It is the governing policy for this repository and it applies to Claude in full.** Everywhere it says "Codex", read "Claude". Do not treat anything in `AGENTS.md` as Codex-only.

That covers the operating principle, the planning-versus-action boundary, file and environment changes, verification, GitHub and external state, sources of truth and precedence, AICockpit artifact management, the full Agile Tracking workflow and authority table, Audits, Airframe project conventions, and communication. None of it is restated here.

This file adds only what is specific to the Claude Code harness. If this file and `AGENTS.md` ever conflict, surface the conflict instead of choosing.

## Plan mode is the approval vehicle

`AGENTS.md` **Planning Versus Action** requires a stated plan and explicit approval before implementation. In Claude Code:

- When a request is scoped as planning, enter plan mode and present the plan through `ExitPlanMode`. Do not narrate a plan and start executing it in the same turn.
- An approved plan authorizes the actions stated in it and nothing more.
- A permissive permission mode (accepted edits, bypassed prompts) is a tooling convenience, not user approval. The approval boundary still applies when the harness would not prompt.

## Git

`AGENTS.md` **GitHub And External State** governs remote mutation. Local git is subject to the same principle:

- Do not commit, push, rebase, or otherwise rewrite git state unless the user asks. Local file edits made within an approved scope are not authorization to commit them.

## Subagents, skills, and background work

- Delegated work inherits every boundary in `AGENTS.md`. A subagent must not perform an action Claude could not perform directly, and Claude is accountable for what its subagents do.
- Spawn subagents only when the user asks for them. Do not fan out agents to accelerate ordinary work in this repository.
- Read-only exploration may be delegated freely within tool permissions. Delegating file mutation, installs, or external state changes requires the same explicit approval as doing it directly.
- Background commands and scheduled or looping work are externally mutating over time. Start them only within an approved scope, and report what is running.
- Relay subagent results rather than assuming they are correct. Verify any claim that would drive a consequential change.

## Reporting

Extending `AGENTS.md` **Verification And Commands** and **Communication**: report verification faithfully. If a build or test fails, say so with the output. If a step was skipped, say that.
