# AgileCockpit Human Verification Mutation Contract

AgileCockpit is the human-facing review surface for Airframe work verification. It may perform Task and Issue verification actions only through AirframeCore human authority checks and auditable backend mutations.

This contract defines the SP-019 behavior for local and GitHub-backed verification flows.

## Authority Boundary

AgileCockpit verification actions require a certified human reviewer context:

- Actor authority class: `humanReviewer`
- Operation category: `humanAcceptance`
- Target project: the active Airframe project

AICockpit remains prohibited from applying Task or Issue Verified. AICockpit may move work to Implemented/Resolved pending verification but must not perform final acceptance.

## Eligible Work

AgileCockpit verification actions apply only to work records with status `Implemented - Not Verified`:

- Task: `Implemented - Not Verified` to `Implemented - Verified`
- Issue: `Resolved - Not Verified` to `Resolved - Verified`

The current AirframeCore status model represents both of those verified states as `implementedVerified`; AgileCockpit displays the artifact-specific labels.

## Actions

AgileCockpit exposes these human actions:

| Action | Result |
| ------ | ------ |
| Accept | Move eligible Task/Issue to Verified |
| Reject | Move eligible Task/Issue back to Active/In Progress |
| Request More Evidence | Move eligible Task/Issue back to Active/In Progress |

Each action records an audit event with the action operation ID, work item ID, authority decision, and project ID.

## Local Backend Behavior

For local and fixture-backed projects, AgileCockpit calls `applyHumanVerification` on the backend using the human reviewer context. The backend:

1. Verifies the work item exists.
2. Verifies the current status is `Implemented - Not Verified`.
3. Evaluates human authority through AirframeCore.
4. Applies the resulting status.
5. Returns an `AirframeHumanVerificationResult` for audit recording.

## GitHub Backend Behavior

For live GitHub Issues projects, AgileCockpit uses controlled GitHub verification mutation support:

1. Resolve the selected Airframe work item to its mapped GitHub issue.
2. Evaluate the human reviewer context through AirframeCore.
3. Replace managed status labels with `status-verified` for Accept, or `status-active` for Reject/Request More Evidence.
4. Return an audit-backed mutation result.

GitHub verification must not be available through AICockpit. The same GitHub mutation path must reject LLM agent contexts for Verified status.

## UI Requirements

AgileCockpit must expose eligible Task and Issue verification candidates in the verification view. The UI must:

- Show eligible Tasks and Issues in the verification queue.
- Preserve the selected work item packet and evidence review before action.
- Present human action buttons for Accept, Reject, and Request More Evidence.
- Use artifact-specific display labels: Task Implemented/Verified and Issue Resolved/Verified.

## Verification Criteria

SP-019 is complete when tests prove:

- Local AgileCockpit can verify an eligible Task.
- Local AgileCockpit can verify an eligible Issue.
- GitHub-backed AgileCockpit verification applies the expected status labels through human reviewer context.
- AICockpit still rejects Task/Issue Verified and Sprint/Epic Closed operations.
- Audit rows distinguish human verification actions from agent workflow mutations.
