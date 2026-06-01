# Airframe Core CSCI Design

**Document Type:** CSCI Design Description  
**CSCI:** Airframe Core  
**System:** Agile Airframe  
**Related CSCIs:** Agile Cockpit, AI Cockpit  
**Status:** Draft  

---

## 1. Design Overview

### 1.1 Purpose

This document describes the preliminary design of Airframe Core, the shared project-management core package/library used by Agile Cockpit and AI Cockpit.

### 1.2 Design Goals

Airframe Core is designed to centralize canonical project-management concepts, identity and context certification, authority enforcement, workflow validation, metrics computation, audit generation, task packet assembly, and backend abstraction.

### 1.3 Major Design Constraints

- Airframe Core shall be reusable by multiple client CSCIs.
- Airframe Core shall not be tied exclusively to GitHub or any other backend.
- Airframe Core shall treat project context as part of the security boundary.
- Airframe Core shall deny unsafe operations by default.
- Airframe Core shall expose domain operations rather than backend-specific operations.

---

## 2. Architectural Role

Airframe Core sits below Agile Cockpit and AI Cockpit and above external backends.

```text
        ┌────────────────────┐        ┌────────────────────┐
        │  Agile Cockpit     │        │   AI Cockpit       │
        └─────────┬──────────┘        └─────────┬──────────┘
                  │                             │
                  └──────────────┬──────────────┘
                                 │
              ┌──────────────────▼──────────────────┐
              │              Airframe Core                │
              │                                      │
              │ - Identity / Context                 │
              │ - Authority / Workflow               │
              │ - Canonical entities                 │
              │ - Metrics                            │
              │ - Audit                              │
              │ - Backend adapters                   │
              └──────────────────┬──────────────────┘
                                 │
              ┌──────────────────▼──────────────────┐
              │        External Backends             │
              └─────────────────────────────────────┘
```

Client CSCIs shall communicate with Airframe Core through public APIs. Backend-specific details shall be isolated behind adapter interfaces.

---

## 3. Package / Module Design

### 3.1 Domain Module

The Domain Module defines canonical entity types, identifiers, field requirements, relationships, and domain-level validation.

Entities include:

- Project.
- Repository.
- Epic.
- Sprint.
- Issue.
- Task.
- VerificationGate.
- Evidence.
- Actor.
- CredentialContext.
- AuditEvent.
- MetricRecord.
- BackendReference.

### 3.2 Identity and Context Module

The Identity and Context Module certifies actor identity, actor type, execution project, target project, and credential scope.

It shall derive authority information from trusted credential context and configuration rather than caller assertion.

### 3.3 Authority Module

The Authority Module evaluates whether a certified actor may perform a requested operation in a given context.

Inputs:

- Actor identity.
- Actor type / authority class.
- Execution project.
- Target project.
- Operation.
- Target entity.
- Credential scope.
- Policy configuration.

Outputs:

- Allowed.
- Denied with reason code.
- Requires confirmation.

### 3.4 Workflow Module

The Workflow Module validates state transitions for canonical entities.

It enforces:

- Allowed transitions.
- Human-only gates.
- LLM-allowed transitions.
- Required evidence.
- Closure criteria.
- Sprint and epic lifecycle rules.

### 3.5 Operation Service Module

The Operation Service Module exposes domain operations to client CSCIs. It coordinates identity, authority, workflow, domain validation, backend adapter invocation, and audit generation.

### 3.6 Backend Adapter Module

The Backend Adapter Module defines interfaces for backend providers and implements provider-specific mappings.

Initial adapters may include:

- GitHub adapter.
- Local Markdown adapter.
- SQLite adapter.
- Mock adapter for tests.

### 3.7 Metrics Module

The Metrics Module computes dashboard and management metrics from canonical entities, workflow history, estimates, and backend-derived data.

Metrics include:

- Sprint progress.
- Burndown.
- Velocity.
- Blocked work.
- Recently completed work.
- Upcoming work.
- Verification aging.

### 3.8 Audit Module

The Audit Module creates audit events for allowed and denied write operations. It may persist events through the backend adapter, local cache, or both.

### 3.9 Configuration Module

The Configuration Module loads and validates project configuration, workflow rules, authority policies, backend settings, protected paths, verification commands, and cross-project delegations.

---

## 4. Data Model Design

### 4.1 Project

A Project represents a managed software project or repository group.

Key fields:

- projectId.
- name.
- backend configuration.
- repositories.
- workflow policy reference.
- authority policy reference.

### 4.2 Actor

An Actor represents a certified requester.

Key fields:

- actorId.
- displayName.
- authorityClass.
- credentialSource.
- active status.

### 4.3 Credential Context

CredentialContext represents trusted identity and scope information derived from credentials, sessions, or execution environment.

Key fields:

- credentialId or fingerprint.
- actorId.
- credentialSource.
- executionProject.
- allowed target projects.
- expiration, where applicable.

### 4.4 Work Item

WorkItem is a generalized base concept for issue-like entities.

Specializations:

- Issue.
- Task.

Common fields:

- id.
- projectId.
- title.
- description.
- status.
- priority.
- estimate.
- sprintId.
- epicId.
- acceptance criteria.
- verification gates.
- backend references.

### 4.5 Sprint

Sprint represents a time-boxed work interval.

Key fields:

- sprintId.
- projectId.
- title.
- start date.
- end date.
- status.
- included work items.
- closure criteria.

### 4.6 Epic

Epic represents a larger body of related work.

Key fields:

- epicId.
- projectId.
- title.
- description.
- status.
- child work items.
- closure criteria.

### 4.7 Verification Gate

VerificationGate represents a required check before work can be accepted.

Key fields:

- gateId.
- workItemId.
- description.
- required evidence type.
- status.

### 4.8 Evidence

Evidence represents supporting information for verification.

Key fields:

- evidenceId.
- workItemId.
- submittedBy.
- timestamp.
- summary.
- command results.
- file references.
- backend references.

### 4.9 Audit Event

AuditEvent represents an attempted or completed operation.

Key fields:

- auditEventId.
- timestamp.
- actorId.
- authorityClass.
- executionProject.
- targetProject.
- operation.
- target entity.
- result.
- reason code.
- backend reference.

---

## 5. Workflow Design

### 5.1 Candidate Workflow States

Initial candidate workflow states include:

```text
Draft
Proposed
Approved
Ready
In Progress
Implemented
Ready for Human Verification
Accepted
Rejected
Closed
Deferred
Superseded
Blocked
```

Final state names shall be refined during detailed design.

### 5.2 LLM-Allowed Transitions

LLM agents may request transitions such as:

- Draft to Proposed.
- Approved to In Progress.
- In Progress to Implemented.
- Implemented to Ready for Human Verification.

All transitions remain subject to authority and workflow validation.

### 5.3 Human-Only Transitions

Human actors may request transitions such as:

- Proposed to Approved.
- Ready for Human Verification to Accepted.
- Accepted to Closed.
- Rejected to In Progress.
- Sprint open.
- Sprint close.
- Epic open.
- Epic close.

### 5.4 Project Context Binding

For mutation operations, the execution project must match the target project unless explicit delegation exists.

### 5.5 Cross-Project Delegation

Cross-project delegation shall be explicit, narrow, auditable, and configured through policy. Delegations should default to proposal-only operations for LLM agents.

### 5.6 Denied Transition Handling

Denied transitions shall return structured reason codes and may include allowed next operations.

---

## 6. Authority Design

### 6.1 Authority Classes

Initial authority classes:

```text
HumanOwner
HumanMaintainer
HumanReviewer
LLMAgent
Automation
ReadOnlyObserver
Unknown
```

### 6.2 Operation Categories

Operation categories include:

- Read operations.
- Proposal operations.
- Evidence operations.
- Workflow transition operations.
- Human acceptance operations.
- Sprint and epic control operations.
- Policy and configuration operations.
- Destructive operations.

### 6.3 Permission Evaluation

Permission evaluation shall consider:

- Certified actor identity.
- Authority class.
- Execution project.
- Target project.
- Requested operation.
- Target entity state.
- Credential scope.
- Delegation policy.
- Workflow policy.

### 6.4 Deny by Default

If any required input cannot be certified, the operation shall be denied.

### 6.5 Confirmation Requirement

Some operations may return RequiresConfirmation rather than Allowed. Agile Cockpit may use this result to request explicit human confirmation.

---

## 7. Backend Adapter Design

### 7.1 Adapter Interface

The backend adapter interface shall expose canonical operations such as:

- createWorkItem.
- updateWorkItem.
- getWorkItem.
- queryWorkItems.
- createSprint.
- updateSprint.
- getSprint.
- createEpic.
- updateEpic.
- attachEvidence.
- recordAuditEvent.
- queryMetricsInputs.

### 7.2 Capability Model

Each adapter shall report capabilities, such as whether it supports:

- Native sprints.
- Native epics.
- Custom fields.
- Comments.
- Labels.
- Attachments.
- Workflow states.
- Historical state transitions.
- API writes.

### 7.3 GitHub Adapter Mapping

A GitHub adapter may map:

- Work items to GitHub Issues.
- Issues / Tasks to labeled GitHub Issues.
- Sprints to Milestones or Project iteration fields.
- Epics to issues or project fields.
- Evidence to comments.
- Audit events to comments, local log, or both.

### 7.4 Local Adapter Mapping

A local adapter may map canonical entities to Markdown files, SQLite records, or both for development and testing.

### 7.5 Backend Failure Strategy

Adapters shall return structured backend errors. Airframe Core shall not report failed backend writes as successful domain operations.

---

## 8. Metrics Design

### 8.1 Metric Inputs

Metric computation may use:

- Work item status.
- Estimates.
- Sprint membership.
- Epic membership.
- Workflow transition timestamps.
- Blocked status.
- Verification queue timestamps.
- Backend pull request or CI data where available.

### 8.2 Burndown Algorithm

Burndown shall compute remaining estimated work over the sprint interval. If estimates are unavailable, Airframe Core may compute count-based burndown.

### 8.3 Velocity Algorithm

Velocity shall compute completed estimate totals across completed sprints. If estimates are unavailable, Airframe Core may compute count-based velocity.

### 8.4 Verification Aging

Verification aging shall compute duration from Ready for Human Verification to Accepted, Rejected, or Closed.

### 8.5 Dashboard Summary

Dashboard summary shall combine recently completed work, active work, upcoming work, blocked work, verification queue, and project health indicators.

---

## 9. API Design

### 9.1 Read APIs

Representative read APIs:

```text
getWorkspaceSummary(context)
getProjectSummary(context, projectId)
getDashboardSummary(context, filters)
getWorkItem(context, workItemId)
queryWorkItems(context, query)
getTaskPacket(context, workItemId)
getMetrics(context, query)
queryAuditEvents(context, query)
```

### 9.2 Write APIs

Representative write APIs:

```text
proposeIssue(context, draft)
proposeER(context, draft)
proposeDR(context, draft)
proposeTask(context, draft)
attachEvidence(context, workItemId, evidence)
markReadyForVerification(context, workItemId)
acceptWork(context, workItemId)
rejectWork(context, workItemId, reason)
openSprint(context, sprintId)
closeSprint(context, sprintId)
openEpic(context, epicId)
closeEpic(context, epicId)
```

### 9.3 Evaluation APIs

Representative evaluation APIs:

```text
evaluateOperation(context, operation, target)
getAllowedOperations(context, target)
validateTransition(context, target, transition)
```

---

## 10. Error Handling Design

### 10.1 Error Categories

Airframe Core shall define structured error categories:

- AuthenticationFailure.
- AuthorizationFailure.
- ProjectScopeMismatch.
- InvalidWorkflowTransition.
- MissingRequiredField.
- BackendFailure.
- ConfigurationError.
- StaleStateConflict.
- UnsupportedBackendCapability.

### 10.2 Denial Reason Codes

Denied operations shall return reason codes suitable for UI display and CLI structured output.

### 10.3 Partial Update Strategy

Airframe Core shall avoid partial updates where practical. Where backend limitations prevent atomicity, Airframe Core shall report partial failure and create audit records where possible.

---

## 11. Verification Design

### 11.1 Unit Tests

Unit tests shall cover domain entities, validation, authority policy, workflow transitions, metrics, task packet assembly, and error classification.

### 11.2 Mock Backend Tests

Mock backend tests shall verify adapter interactions and failure handling.

### 11.3 Policy Tests

Policy tests shall verify actor authority, project context binding, human-only gates, and cross-project delegation behavior.

### 11.4 State Machine Tests

State machine tests shall verify allowed and denied transitions across all defined workflow states.

### 11.5 Metrics Tests

Metrics tests shall verify burndown, velocity, blocked work, recently completed work, upcoming work, and verification aging.

### 11.6 Security Boundary Tests

Security boundary tests shall verify that caller-provided actor type, role, or target project cannot spoof authority.

---

## 12. Open Design Decisions

- Implementation language selected: Swift.
- Package structure selected: standalone Swift package library; see `docs/architecture/CSCI_Project_Form_Trade_Study.md`.
- Initial backend strategy remains open.
- Final workflow state names remain open.
- Final policy configuration format remains open.
- Credential and identity mechanisms remain open.
