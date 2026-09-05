#!/usr/bin/env bash
# Launches the project-local AgileCockpit.app with the Airframe workspace config.
set -euo pipefail

clear_cache=false
for argument in "$@"; do
  case "$argument" in
    --clear-cache) clear_cache=true ;;
    -h|--help)
      echo "Usage: $(basename "$0") [--clear-cache]"
      echo "  --clear-cache  Remove UI caches before launching; canonical records are preserved."
      exit 0
      ;;
    *)
      echo "error: unknown argument: $argument" >&2
      echo "Usage: $(basename "$0") [--clear-cache]" >&2
      exit 2
      ;;
  esac
done

source "$(dirname "$0")/_ac_common.sh"

APP="$REPO_ROOT/../Airframe/demos/LiveDemo/Applications/AgileCockpit.app"
STORE="$REPO_ROOT/.airframe/airframe-local-backend.json"

if [[ ! -d "$APP" ]]; then
  echo "error: AgileCockpit.app not found at $APP" >&2
  echo "Run: ../Airframe/scripts/install-live-demo.sh" >&2
  exit 1
fi

# Preserve UI caches unless a rebuild is explicitly requested.
if [[ "$clear_cache" == true ]]; then
  rm -f -- \
    "$REPO_ROOT/.airframe/agilecockpit-launch-cache.json" \
    "$REPO_ROOT/.airframe/agilecockpit-traceability-cache.json"
  echo "Cleared AgileCockpit UI caches."
fi

echo "Launching AgileCockpit with Airframe workspace config..."
open -n --fresh \
  --env "AIRFRAME_CONFIG_PATH=$AC_CONFIG" \
  --env "AIRFRAME_STORE_PATH=$STORE" \
  "$APP"
