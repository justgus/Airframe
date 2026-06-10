# GitHub Issue Mapping

This document records the required one-to-one mapping between GitHub Issues and Airframe work records.

## Rules

- Every Airframe Task must have exactly one GitHub Issue number.
- Every Airframe Issue must have exactly one GitHub Issue number.
- Every GitHub Issue in this repository must be assigned to exactly one Airframe Task ID or one Airframe Issue ID.
- Task GitHub Issue titles must begin with `[T-XXXX]`.
- Issue GitHub Issue titles must begin with `[I-XXXX]`.
- GitHub Issue bodies must include `Airframe Type:` and `Airframe ID:` fields.
- Local status changes must be reflected in the linked GitHub Issue, and GitHub closure must be reflected in the local Airframe record.

## Current Task Mapping

| Airframe Task | GitHub Issue | Epic | Title |
| ------------- | ------------ | ---- | ----- |
| T-0001 | #1 | EP-001 | Scaffold AirframeCore Swift package |
| T-0002 | #2 | EP-001 | Scaffold AICockpit Swift package executable |
| T-0003 | #3 | EP-001 | Scaffold AgileCockpit macOS SwiftUI app |
| T-0004 | #4 | EP-001 | Assemble Airframe workspace and schemes |
| T-0005 | #5 | EP-001 | Establish baseline build and test documentation |
| T-0006 | #6 | EP-001 | Verify clean checkout workspace baseline |
| T-0007 | #7 | EP-002 | Define canonical domain model |
| T-0008 | #8 | EP-002 | Define configuration model and fixtures |
| T-0009 | #9 | EP-002 | Implement AirframeCore configuration loading |
| T-0010 | #10 | EP-002 | Implement AICockpit context display |
| T-0011 | #11 | EP-002 | Implement AgileCockpit project context UI |
| T-0012 | #12 | EP-003 | Implement actor and certified context model |
| T-0013 | #13 | EP-003 | Implement authority evaluator |
| T-0014 | #14 | EP-003 | Implement workflow transition evaluator |
| T-0015 | #15 | EP-003 | Implement audit event service |
| T-0016 | #16 | EP-003 | Implement AICockpit denied-operation output |
| T-0017 | #17 | EP-003 | Implement AgileCockpit authority and audit display |
| T-0018 | #18 | EP-004 | Define backend adapter protocol and capabilities |
| T-0019 | #19 | EP-004 | Implement local filesystem backend |
| T-0020 | #20 | EP-004 | Implement evidence attachment workflow |
| T-0021 | #21 | EP-004 | Implement task packet generation |
| T-0022 | #22 | EP-004 | Implement local dashboard summary APIs |
| T-0023 | #23 | EP-005 | Finalize AICockpit MVP command names and parser |
| T-0024 | #24 | EP-005 | Implement issue and task proposal commands |
| T-0025 | #25 | EP-005 | Implement next-task and task-packet commands |
| T-0026 | #26 | EP-005 | Implement evidence and ready-for-verification commands |
| T-0027 | #27 | EP-005 | Implement Markdown and JSON output contracts |
| T-0028 | #28 | EP-005 | Document AICockpit agent usage |
| T-0029 | #29 | EP-006 | Implement AgileCockpit application shell |
| T-0030 | #30 | EP-006 | Implement dashboard summary UI |
| T-0031 | #31 | EP-006 | Implement verification queue and review flow |
| T-0032 | #32 | EP-006 | Implement human verification actions |
| T-0033 | #33 | EP-006 | Implement sprint and epic read views |
| T-0034 | #34 | EP-006 | Implement metrics and audit views |
| T-0035 | #35 | EP-006 | Add primary accessibility and UI tests |
| T-0036 | #36 | EP-007 | Implement GitHub backend capability map and configuration |
| T-0037 | #37 | EP-007 | Implement GitHub issue/task mapping |
| T-0038 | #38 | EP-007 | Implement GitHub sprint/epic/evidence mapping |
| T-0039 | #39 | EP-007 | Integrate GitHub backend with AICockpit |
| T-0040 | #40 | EP-007 | Integrate GitHub backend status with AgileCockpit |
| T-0041 | #41 | EP-008 | Add full regression and integration test pass |
| T-0042 | #42 | EP-008 | Harden CLI output and error contracts |
| T-0043 | #43 | EP-008 | Harden AgileCockpit accessibility and UI flows |
| T-0044 | #44 | EP-008 | Add configuration diagnostics and failure handling |
| T-0045 | #45 | EP-008 | Write release candidate verification documentation |
| T-0046 | #46 | EP-009 | Define live demo workspace configuration contract |
| T-0047 | #47 | EP-009 | Implement AICockpit runtime configuration selection |
| T-0048 | #48 | EP-009 | Implement AgileCockpit runtime configuration selection |
| T-0049 | #49 | EP-009 | Add Airframe live demo project configuration and usage docs |
| T-0050 | #50 | EP-009 | Verify Slice 1 live project identity and fallback behavior |
| T-0051 | #51 | EP-010 | Define live GitHub issue transport and failure contract |
| T-0052 | #52 | EP-010 | Implement read-only GitHub issue listing backend |
| T-0053 | #53 | EP-010 | Implement GitHub issue-to-work-record parsing |
| T-0054 | #54 | EP-010 | Wire github-issues into AICockpit commands |
| T-0055 | #55 | EP-010 | Verify read-only GitHub adapter behavior and docs |
| T-0056 | #56 | EP-011 | Wire AgileCockpit live backend configuration |
| T-0057 | #59 | EP-011 | Load live GitHub dashboard counts in AgileCockpit |
| T-0058 | #57 | EP-011 | Show live sprint and epic planning state |
| T-0059 | #60 | EP-011 | Show live implemented-not-verified work |
| T-0060 | #58 | EP-011 | Verify AgileCockpit live project view behavior |
| T-0061 | #61 | EP-012 | Define project-local demo artifact layout |
| T-0062 | #65 | EP-012 | Install aicockpit into the project-local demo layout |
| T-0063 | #64 | EP-012 | Install AgileCockpit.app into the project-local demo layout |
| T-0064 | #63 | EP-012 | Document project-local demo installation and verification |
| T-0065 | #62 | EP-012 | Verify project-local installation without manual Cockpit launch |
| T-0066 | #66 | EP-013 | Define controlled GitHub mutation authority contract |
| T-0067 | #67 | EP-013 | Add GitHub issue comment mutation support |
| T-0068 | #68 | EP-013 | Add controlled GitHub status label transition support |
| T-0069 | #69 | EP-013 | Wire explicit mutation commands and UI affordances |
| T-0070 | #70 | EP-013 | Verify controlled mutation safety and documentation |
| T-0071 | #71 | EP-014 | Define Slice 6 end-to-end demo script and success criteria |
| T-0072 | #75 | EP-014 | Rehearse project-local AICockpit live GitHub workflow |
| T-0073 | #72 | EP-014 | Rehearse AgileCockpit live project review workflow |
| T-0074 | #74 | EP-014 | Verify controlled GitHub write demo with explicit approval |
| T-0075 | #73 | EP-014 | Document final live demo runbook and rollback notes |

## Current Issue Mapping

No Airframe Issues are currently defined. Next local Issue ID: `I-0001`.

*Last Updated: 2026-06-10 (T-0071 through T-0075 mapped to GitHub issues #71 through #75)*
