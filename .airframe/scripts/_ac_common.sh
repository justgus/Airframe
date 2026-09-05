#!/usr/bin/env bash
# Sourced by all ac-*.sh scripts. Sets AICOCKPIT and AC_CONFIG, defines ac_run().
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AICOCKPIT="$REPO_ROOT/../Airframe/demos/LiveDemo/bin/aicockpit"
AC_CONFIG="$REPO_ROOT/.airframe/airframe-workspace.json"

if [[ ! -x "$AICOCKPIT" ]]; then
  echo "error: aicockpit binary not found at $AICOCKPIT" >&2
  exit 1
fi

if [[ ! -f "$AC_CONFIG" ]]; then
  echo "error: airframe config not found at $AC_CONFIG" >&2
  exit 1
fi

# Read discipline for agents. Printed once per shell session, to stderr so it
# never contaminates JSON on stdout. Set AC_QUIET=1 to suppress.
# These rules exist because the cheap path is not the obvious one: the derived
# surfaces below restate canonical state at 10-100x the token cost of a query.
if [[ -z "${AC_READ_DISCIPLINE_SHOWN:-}" && -z "${AC_QUIET:-}" ]]; then
  export AC_READ_DISCIPLINE_SHOWN=1
  cat >&2 <<'BANNER'
Airframe read discipline (agents):
  - Query state with these ac-*.sh scripts. Do not read .airframe/state/**,
    the *-cache.json files, or docs/generated/** directly; they are derived.
  - Never `git diff` a *-cache.json. It is single-line JSON; one change emits
    megabytes. They are gitignored here for that reason.
  - Need one requirement or work item? Query it by ID. Do not read a whole
    specification or matrix to find a single entry.
BANNER
fi

# ac_run <subcommand...> — always passes --config
ac_run() {
  "$AICOCKPIT" "$@" --config "$AC_CONFIG"
}
