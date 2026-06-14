# AICockpit Agent Usage

AICockpit provides deterministic local commands for agents working in an Airframe workspace. Command behavior lives in `AICockpitKit`; the executable target only forwards arguments.

## Output

Commands default to compact Markdown. Use `--output json` for machine-readable output.

## Local Store

Use `--store path` to select the local backend JSON file. If omitted, AICockpit uses `.airframe/airframe-local-backend.json` from the current working directory.

`AIRFRAME_STORE_PATH` can also select the local backend store for commands that do not pass `--store`.

## Project Configuration

Use `--config path` to select an Airframe workspace configuration file. If omitted, AICockpit checks `AIRFRAME_CONFIG_PATH`, then `.airframe/airframe-workspace.json` from the current working directory, then falls back to the embedded sample configuration.

## Commands

Mutation command contracts for SP-018 are defined in [MutationCommandContract.md](MutationCommandContract.md).

```sh
aicockpit --help
aicockpit version
aicockpit context [--config path]
aicockpit config diagnose [--config path] [--output markdown|json]
aicockpit project summary [--config path] [--store path] [--output markdown|json]
aicockpit task propose --id T-XXXX --title "Title" [--config path] [--store path]
aicockpit issue propose --id I-XXXX --title "Title" [--config path] [--store path]
aicockpit task create --id T-XXXX --title "Title" [--status backlog|active] [--config path] [--store path]
aicockpit issue create --id I-XXXX --title "Title" [--status backlog|active] [--config path] [--store path]
aicockpit sprint create --id SP-XXXX --title "Title" [--status backlog|planning] [--config path] [--store path]
aicockpit epic create --id EP-XXXX --title "Title" [--status proposed|draft|backlog] [--config path] [--store path]
aicockpit task update T-XXXX [--title "Title"] [--status backlog|active|implemented] [--config path] [--store path]
aicockpit issue update I-XXXX [--title "Title"] [--status backlog|active|resolved] [--config path] [--store path]
aicockpit sprint update SP-XXXX [--title "Title"] [--status backlog|planning|active|review] [--config path] [--store path]
aicockpit epic update EP-XXXX [--title "Title"] [--status proposed|draft|backlog|active|complete] [--config path] [--store path]
aicockpit task status T-XXXX --to backlog|active|implemented [--config path] [--store path]
aicockpit issue status I-XXXX --to backlog|active|resolved [--config path] [--store path]
aicockpit sprint status SP-XXXX --to backlog|planning|active|review [--config path] [--store path]
aicockpit epic status EP-XXXX --to proposed|draft|backlog|active|complete [--config path] [--store path]
aicockpit task next [--config path] [--store path] [--output markdown|json]
aicockpit task packet T-XXXX [--config path] [--store path] [--output markdown|json]
aicockpit evidence attach T-XXXX --id EV-XXXX --summary "Summary" --artifact "Artifact" [--config path] [--store path]
aicockpit work ready T-XXXX [--config path] [--store path] [--output markdown|json]
```

## Example Flow

```sh
STORE=/tmp/airframe-local-backend.json

swift run --package-path AICockpit aicockpit task propose \
  --store "$STORE" \
  --id T-9001 \
  --title "Implement CLI command parser" \
  --acceptance "Parser tests pass" \
  --scope AICockpitKit \
  --constraint "Keep executable target thin" \
  --evidence-required "swift test --package-path AICockpit"

swift run --package-path AICockpit aicockpit task next --store "$STORE"
swift run --package-path AICockpit aicockpit task packet T-9001 --store "$STORE"

swift run --package-path AICockpit aicockpit evidence attach T-9001 \
  --store "$STORE" \
  --id EV-9001-001 \
  --summary "AICockpit tests passed" \
  --artifact "swift test --package-path AICockpit"

swift run --package-path AICockpit aicockpit work ready T-9001 --store "$STORE" --output json
```

## Authority

Write commands are evaluated through AirframeCore authority and workflow policy. AICockpit does not perform human-only acceptance operations.
