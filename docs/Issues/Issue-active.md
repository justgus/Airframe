# Active Issues

Issues assigned to active Sprints are listed here. Issues move out of this file after they are resolved and human-verified.

## I-0009: Epic close leaves stale active pointers and sprint closeout state

**Status:** Resolved - Not Verified
**GitHub Issue:** #147
**Platform:** macOS
**Component:** AgileCockpit / AirframeCore / Canonical State
**Severity:** High
**Epic:** None
**Sprint:** None
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-25
**Verification Date:** TBD

**Description:**
Closing EP-021 in AgileCockpit transitioned the Epic to Closed but left the project active Epic pointer on EP-021. The project active Sprint pointer also remained stale on SP-032 after SP-032 and SP-033 were closed, which caused Data Health diagnostics to report closed work as active and exposed that active pointer cleanup was incomplete.

**Expected Behavior:**
When AgileCockpit closes an Epic, canonical project state should clear the active Epic pointer. Active Epic UI, release gate scope, and traceability scope should read the canonical project snapshot rather than stale configuration. Sprint closeout data should not leave a closed Sprint configured as active, and follow-up work should define whether closing a Sprint should advance, clear, or require explicit selection of the next current Sprint.

**Resolution:**
Added canonical active Epic clearing support, wired AgileCockpit Epic close to clear the canonical active Epic pointer, switched active Epic UI/scope reads to canonical project state, repaired EP-021/SP-033 canonical and Markdown closeout state, and restored the missing SP-029 canonical Sprint record.

**Files Affected:**
- `AirframeCore/Sources/AirframeCore/CanonicalStoreBackend.swift`
- `AgileCockpit/AgileCockpit/ContentView.swift`
- `AgileCockpit/AgileCockpitTests/AgileCockpitTests.swift`
- `.airframe/airframe-workspace.json`
- `.airframe/state/projects/PRJ-AIRFRAME.json`
- `.airframe/state/sprints/SP-029.json`
- `.airframe/state/sprints/SP-033.json`
- `docs/Epics/`
- `docs/Sprints/`
- `docs/Issues/`

**Follow-up:**
- Investigate and define current Sprint advancement behavior after closing a Sprint when another Sprint is already closed, active, or absent.
- Decide whether AgileCockpit should update `.airframe/airframe-workspace.json` active pointers or treat canonical project state as the only mutable active pointer source.

I-0001 through I-0004 were reconciled to verified historical EP-017/SP-017 state on 2026-06-23 and moved to [Verified/Issue-verified-0001-0004.md](Verified/Issue-verified-0001-0004.md).

## I-0010: Sprint close does not archive Markdown Sprint record

**Status:** Resolved - Not Verified
**GitHub Issue:** #148
**Platform:** macOS
**Component:** AgileCockpit / Documentation / Canonical State
**Severity:** High
**Epic:** EP-018
**Sprint:** SP-023
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-25
**Verification Date:** TBD

**Description:**
AgileCockpit closeActiveSprint transitions the canonical Sprint status and clears the active Sprint pointer, but it does not write a closed Sprint Markdown record under `docs/Sprints/Closed/`.

**Expected Behavior:**
When an authorized human closes a reviewed Sprint, AgileCockpit should preserve the closed Sprint as `docs/Sprints/Closed/Sprint-<ID>.md` and remove the closed Sprint from the active Sprint projection.

**Resolution:**
AgileCockpit now writes closed Sprint Markdown archives from canonical state after Sprint close and refreshes Sprint projections.

## I-0011: Epic close does not archive Markdown Epic record

**Status:** Resolved - Not Verified
**GitHub Issue:** #149
**Platform:** macOS
**Component:** AgileCockpit / Documentation / Canonical State
**Severity:** High
**Epic:** EP-018
**Sprint:** SP-023
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-25
**Verification Date:** TBD

**Description:**
AgileCockpit closeActiveEpic transitions the canonical Epic status and clears the active Epic pointer, but it does not write a closed Epic Markdown record under `docs/Epics/Closed/`.

**Expected Behavior:**
When an authorized human closes an Epic, AgileCockpit should preserve the closed Epic as `docs/Epics/Closed/Epic-<ID>.md` and remove the closed Epic from the active Epic projection.

**Resolution:**
AgileCockpit now writes closed Epic Markdown archives from canonical state after Epic close and refreshes Epic projections.

## I-0012: Close actions do not refresh Sprint and Epic indexes

**Status:** Resolved - Not Verified
**GitHub Issue:** #150
**Platform:** macOS
**Component:** AgileCockpit / Documentation / Canonical State
**Severity:** High
**Epic:** EP-018
**Sprint:** SP-023
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-25
**Verification Date:** TBD

**Description:**
AgileCockpit Sprint and Epic close actions update canonical JSON state, but human-facing Markdown indexes and projections can remain stale after close.

**Expected Behavior:**
After an authorized Sprint or Epic close, the relevant Markdown projections and indexes should be regenerated or updated deterministically from canonical state.

**Resolution:**
AgileCockpit close actions now refresh Sprint and Epic Markdown projections and generated records from canonical state.

## I-0013: Epic close eligibility ignores open Sprints

**Status:** Resolved - Not Verified
**GitHub Issue:** #151
**Platform:** macOS
**Component:** AgileCockpit / AirframeCore / Canonical State
**Severity:** High
**Epic:** EP-018
**Sprint:** SP-023
**Date Identified:** 2026-06-25
**Fix Date:** 2026-06-25
**Verification Date:** TBD

**Description:**
AgileCockpit reports the active Epic as eligible to close even when related Sprints such as SP-023 and SP-024 are not completed yet.

**Expected Behavior:**
Epic close eligibility should require all related Sprints for the Epic to be closed, or otherwise explicitly excluded by workflow policy, before enabling Epic close.

**Resolution:**
Epic close eligibility now includes related Sprint status and blocks close while related Sprints remain Backlog, Planning, Active, or Review.

*Last Updated: 2026-06-25 (I-0010 through I-0013 opened for SP-023)*
