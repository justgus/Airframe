# AICockpit Agent Usage

AICockpit provides deterministic local commands for agents working in an Airframe workspace. Command behavior lives in `AICockpitKit`; the executable target only forwards arguments.

## Output

Commands default to compact Markdown. Use `--output json` for machine-readable output.

## Local Store

Use `--store path` to select the local backend JSON file. If omitted, AICockpit uses `.airframe/airframe-local-backend.json` from the current working directory.

## Commands

```sh
aicockpit --help
aicockpit version
aicockpit context
aicockpit project summary [--store path] [--output markdown|json]
aicockpit task propose --id T-XXXX --title "Title" [--store path]
aicockpit issue propose --id I-XXXX --title "Title" [--store path]
aicockpit task next [--store path] [--output markdown|json]
aicockpit task packet T-XXXX [--store path] [--output markdown|json]
aicockpit evidence attach T-XXXX --id EV-XXXX --summary "Summary" --artifact "Artifact" [--store path]
aicockpit work ready T-XXXX [--store path] [--output markdown|json]
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
