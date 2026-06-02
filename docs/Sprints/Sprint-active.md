# Active Sprint

---

## SP-003: Workflow, Authority, and Audit Foundation

**Status:** Active  
**Epic:** EP-003: Workflow, Authority, and Audit Foundation  
**Goal:** Implement the deny-by-default workflow, authority, certified context, and audit foundation used by both AICockpit and AgileCockpit.  
**Start Date:** 2026-06-02  
**End Date:** TBD  
**Capacity:** TBD  

### Assigned Tasks

| Task | GitHub Issue | Title | Priority | Status |
| ---- | ------------ | ----- | -------- | ------ |
| T-0012 | #12 | Implement actor and certified context model | High | Implemented - Verified |
| T-0013 | #13 | Implement authority evaluator | High | Implemented - Verified |
| T-0014 | #14 | Implement workflow transition evaluator | High | Implemented - Not Verified |
| T-0015 | #15 | Implement audit event service | High | Implemented - Not Verified |
| T-0016 | #16 | Implement AICockpit denied-operation output | Medium | Implemented - Not Verified |
| T-0017 | #17 | Implement AgileCockpit authority and audit display | Medium | Implemented - Not Verified |

### Assigned Issues

| Issue | GitHub Issue | Title | Severity | Status |
| ----- | ------------ | ----- | -------- | ------ |

### Sprint Notes

SP-003 starts EP-003. The Sprint should establish AirframeCore as the single source of authority, workflow transition policy, certified actor context, and audit event generation.

### Verification Targets

```sh
swift test --package-path AirframeCore
swift test --package-path AICockpit
xcodebuild -workspace Airframe.xcworkspace -scheme AgileCockpit -destination 'platform=macOS' test
```

### Retrospective

**Completed:**
- SP-003 activated on 2026-06-02.
- T-0012 implemented and moved to Implemented - Not Verified on 2026-06-02.
- T-0012 human-verified on 2026-06-02.
- T-0013 implemented and moved to Implemented - Not Verified on 2026-06-02.
- T-0013 human-verified on 2026-06-02.
- T-0014 through T-0017 implemented and moved to Implemented - Not Verified on 2026-06-02.
- AirframeCore, AICockpit, and AgileCockpit verification targets passed on 2026-06-02.

**Returned to Backlog:**
- TBD.

**What went well:**
- TBD.

**What to improve:**
- TBD.

**Carry-forward notes:**
- No client should implement independent authorization rules.

---

*Last Updated: 2026-06-02 (SP-003 implementation complete)*
