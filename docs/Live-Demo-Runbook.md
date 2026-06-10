# Airframe Live Demo Runbook

**Status:** Archived Slice 6 implementation runbook for closed EP-014 / SP-014.
**Target repository:** `justgus/Airframe`  
**Local clone:** `/Users/justgus/Xcode-Projects/Airframe`  
**Install location:** `demos/LiveDemo/`

## Purpose

This runbook rehearses the project-local Airframe live demo against the live `github-issues` backend. It distinguishes live GitHub behavior from fixture-backed behavior and keeps all GitHub mutations explicit, approved, and auditable.

## Prerequisites

- Run from the Airframe repository root.
- GitHub CLI authentication must allow reading `justgus/Airframe` issues.
- `.airframe/airframe-workspace.json` must use backend `github-issues`.
- During SP-014 rehearsal, `.airframe/airframe-workspace.json` identified active sprint `SP-014` and active epic `EP-014`. After closeout, the active sprint and epic are cleared until the next approved slice is opened.
- No global install locations are used.

## Install

```sh
scripts/install-live-demo.sh
```

Expected result:

- `demos/LiveDemo/bin/aicockpit` exists and is executable.
- `demos/LiveDemo/Applications/AgileCockpit.app` exists.
- Build products remain under `demos/LiveDemo/`.

## Read-Only AICockpit Rehearsal

```sh
demos/LiveDemo/bin/aicockpit config diagnose \
  --config .airframe/airframe-workspace.json \
  --output json
```

Expected result:

- diagnostics status is `ok`;
- repository is `justgus/Airframe`;
- backend is `github-issues`;
- active sprint was `SP-014` during rehearsal;
- active epic was `EP-014` during rehearsal.

```sh
demos/LiveDemo/bin/aicockpit project summary \
  --config .airframe/airframe-workspace.json \
  --backend github-issues \
  --output json
```

Expected result:

- output reports backend `github-issues`;
- work item counts included the active SP-014 tasks during rehearsal;
- command performs no GitHub mutations.

```sh
demos/LiveDemo/bin/aicockpit task next \
  --config .airframe/airframe-workspace.json \
  --backend github-issues \
  --output json
```

Expected result:

- next active work resolved to an SP-014 task during rehearsal.

```sh
demos/LiveDemo/bin/aicockpit task packet T-0071 \
  --config .airframe/airframe-workspace.json \
  --backend github-issues \
  --output json
```

Expected result:

- task packet resolves from live GitHub issue #71;
- packet content references Slice 6 demo script and success criteria.

## AgileCockpit Rehearsal

Automated check:

```sh
xcodebuild \
  -workspace Airframe.xcworkspace \
  -scheme AgileCockpit \
  -destination 'platform=macOS' \
  -derivedDataPath demos/LiveDemo/DerivedData \
  test
```

Manual launch when approved:

```sh
AIRFRAME_CONFIG_PATH=.airframe/airframe-workspace.json \
AIRFRAME_STORE_PATH=.airframe/airframe-local-backend.json \
open demos/LiveDemo/Applications/AgileCockpit.app
```

Expected result:

- AgileCockpit uses the project-local app;
- project identity is `Agile Airframe`;
- repository is `justgus/Airframe`;
- backend is `github-issues`;
- sprint and epic views reflected SP-014 / EP-014 work during rehearsal.

## Controlled Write Rehearsal

Safety check without approval:

```sh
demos/LiveDemo/bin/aicockpit github comment T-0074 \
  --config .airframe/airframe-workspace.json \
  --backend github-issues \
  --body "SP-014 missing approval safety check" \
  --output json
```

Expected result:

- command fails before live GitHub lookup or write;
- output says the mutation requires confirmation.

Approved write demonstration, only when the human explicitly approves the live mutation:

```sh
demos/LiveDemo/bin/aicockpit github comment T-0074 \
  --config .airframe/airframe-workspace.json \
  --backend github-issues \
  --body "SP-014 controlled write rehearsal approved by Human." \
  --approve \
  --approved-by "Human" \
  --output json
```

Expected result:

- command name is explicit about the GitHub write;
- approval fields are present;
- mutation result identifies the issue number, actor, work item, and target project;
- audit evidence is returned by AirframeCore.

## One-Command Verification

```sh
scripts/verify-sp014.sh
```

The verification script performs project-local install, read-only AICockpit checks, the missing-approval controlled write safety check, and AgileCockpit automated tests. It does not perform an approved live GitHub mutation.

## Rollback And Cleanup

- If install artifacts are stale, rerun `scripts/install-live-demo.sh`.
- If a live approved comment is added during rehearsal and should be removed, delete that comment manually in GitHub after recording the cleanup decision.
- If a status label is changed during an approved rehearsal, restore the previous Airframe `status-*` label and record the rollback in the task evidence.
- During rehearsal cleanup, do not delete or close SP-014 task issues. The task issues were closed later as part of explicit human-approved SP-014 closeout.

## Known Limits

- The automated SP-014 verification script checks the missing-approval safety path, not an approved live mutation, to avoid mutating GitHub during unattended verification.
- Manual AgileCockpit launch uses `open`, which is intentionally outside the automated verification script.
- GitHub availability and local `gh` authentication are external prerequisites.
