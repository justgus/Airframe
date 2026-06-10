# Airframe Live Demo Runbook

**Status:** Slice 6 implementation runbook for EP-014 / SP-014.  
**Target repository:** `justgus/Airframe`  
**Local clone:** `/Users/justgus/Xcode-Projects/Airframe`  
**Install location:** `demos/LiveDemo/`

## Purpose

This runbook rehearses the project-local Airframe live demo against the live `github-issues` backend. It distinguishes live GitHub behavior from fixture-backed behavior and keeps all GitHub mutations explicit, approved, and auditable.

## Prerequisites

- Run from the Airframe repository root.
- GitHub CLI authentication must allow reading `justgus/Airframe` issues.
- `.airframe/airframe-workspace.json` must use backend `github-issues`.
- `.airframe/airframe-workspace.json` must identify active sprint `SP-014` and active epic `EP-014`.
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
- active sprint is `SP-014`;
- active epic is `EP-014`.

```sh
demos/LiveDemo/bin/aicockpit project summary \
  --config .airframe/airframe-workspace.json \
  --backend github-issues \
  --output json
```

Expected result:

- output reports backend `github-issues`;
- work item counts include the active SP-014 tasks;
- command performs no GitHub mutations.

```sh
demos/LiveDemo/bin/aicockpit task next \
  --config .airframe/airframe-workspace.json \
  --backend github-issues \
  --output json
```

Expected result:

- next active work resolves to an SP-014 task.

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
- sprint and epic views reflect SP-014 / EP-014 work.

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
- Do not delete or close SP-014 task issues as part of rehearsal cleanup.

## Known Limits

- The automated SP-014 verification script checks the missing-approval safety path, not an approved live mutation, to avoid mutating GitHub during unattended verification.
- Manual AgileCockpit launch uses `open`, which is intentionally outside the automated verification script.
- GitHub availability and local `gh` authentication are external prerequisites.
