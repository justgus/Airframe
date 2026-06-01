# Airframe Core CSCI Requirements

**Document Type:** CSCI Requirements Specification  
**CSCI:** Airframe Core  
**System:** Agile Airframe  
**Related CSCIs:** Agile Cockpit, AI Cockpit  
**Status:** Draft  

---

## 1. Introduction

### 1.1 Purpose

This document defines the requirements for the Airframe Core Computer Software Configuration Item (CSCI). Airframe Core is the shared project-management core package/library used by Agile Cockpit and AI Cockpit.

Airframe Core provides the canonical domain model, identity and context certification, authority enforcement, workflow validation, project-scoped permissions, backend abstraction, metrics, audit event generation, and task packet assembly required by the Agile Airframe.

### 1.2 Scope

Airframe Core shall provide reusable APIs and services that allow client CSCIs to interact with project-management data in a backend-agnostic and policy-controlled manner. Airframe Core shall mediate all project-management read and write operations requested by Agile Cockpit and AI Cockpit.

Airframe Core shall support an initial backend adapter for GitHub or a local development backend, while preserving the ability to support future systems such as Linear, Jira, Plane, Markdown-based repositories, SQLite stores, or other CLI/API-accessible tools.

### 1.3 Definitions

- **Agile Airframe:** Overall system/suite for LLM-assisted agile governance.
- **Airframe Core:** Shared project-management core package/library.
- **Agile Cockpit:** Human-facing UI CSCI.
- **AI Cockpit:** LLM/agent-facing CLI CSCI.
- **Actor:** Entity requesting an operation.
- **Credential Context:** Verified information derived from credentials, sessions, tokens, or execution environment.
- **Execution Project:** Project context under which an actor session or credential is operating.
- **Target Project:** Project containing the entity to be read or modified.
- **Authority Class:** Certified permission category such as HumanOwner, HumanMaintainer, HumanReviewer, LLMAgent, Automation, ReadOnlyObserver, or Unknown.
- **Workflow Transition:** Change from one domain state to another.
- **Backend Adapter:** Component that maps Airframe Core canonical operations to backend-specific operations.
- **Audit Event:** Immutable record of an attempted or completed operation.

### 1.4 References

- Agile Cockpit CSCI Requirements
- AI Cockpit CSCI Requirements
- Agile Cockpit CSCI Design
- AI Cockpit CSCI Design
- Project-specific workflow policy documents

---

## 2. CSCI Overview

### 2.1 Operational Concept

Airframe Core shall act as the shared policy, workflow, data, and backend-access layer for the Agile Airframe. Agile Cockpit and AI Cockpit shall request domain operations from Airframe Core. Airframe Core shall authenticate or certify actor context, determine authority, validate project context, validate workflow transitions, perform canonical operations, communicate with backend adapters, compute metrics, and generate audit events.

### 2.2 Supported Client CSCIs

Airframe Core shall support at minimum:

- Agile Cockpit.
- AI Cockpit.

Airframe Core may support future clients such as automated reporting tools, CI integrations, local dashboards, or migration utilities.

### 2.3 External Backend Systems

Airframe Core shall be capable of supporting multiple backend systems through adapters. Backend systems may include:

- GitHub Issues, Projects, Pull Requests, Actions, and Milestones.
- Linear.
- Jira.
- Plane.
- Markdown files.
- SQLite.
- Other systems with CLI or API interfaces.

### 2.4 Assumptions and Constraints

- Airframe Core is not a user-facing application.
- Airframe Core shall not assume GitHub as the only backend.
- Airframe Core shall deny unsafe or uncertified operations by default.
- Airframe Core shall treat project context as part of the security boundary.
- Airframe Core shall centralize workflow and authority logic so client CSCIs cannot bypass it.

---

## 3. Functional Requirements

### AF-FR-001 Canonical Project Model

Airframe Core shall define canonical representations for projects, repositories, epics, sprints, issues, ERs, DRs, tasks, verification gates, evidence, actors, credentials, authority classes, workflow states, metrics, backend references, and audit events.

### AF-FR-002 Actor Identity Certification

Airframe Core shall certify actor identity from trusted credential context, session information, or configured identity providers.

### AF-FR-003 Actor Type Certification

Airframe Core shall derive actor type or authority class from certified identity and policy. Airframe Core shall not accept actor type as a trusted caller-provided assertion.

### AF-FR-004 Project Context Binding

Airframe Core shall bind each operation to an execution project and target project and shall enforce project-scope rules.

### AF-FR-005 Project Scope Mismatch Denial

Airframe Core shall deny mutation operations when execution project and target project do not match and no explicit cross-project delegation exists.

### AF-FR-006 Authority Model

Airframe Core shall define and enforce operation permissions by actor type, project context, target entity, credential scope, and workflow state.

### AF-FR-007 Workflow State Model

Airframe Core shall define workflow states for project entities and shall validate all requested state transitions.

### AF-FR-008 Human-Only Gates

Airframe Core shall enforce human-only gates for accepting work, closing work, opening or closing sprints, opening or closing epics, approving architecture decisions, and changing workflow policies.

### AF-FR-009 LLM-Allowed Operations

Airframe Core shall support LLM-allowed operations including proposing issues, proposing ERs, proposing DRs, proposing tasks, attaching evidence, and marking work ready for human verification.

### AF-FR-010 Entity Creation

Airframe Core shall support creation of canonical project entities subject to authority and workflow constraints.

### AF-FR-011 Entity Update

Airframe Core shall support updates to canonical project entities subject to authority and workflow constraints.

### AF-FR-012 Entity Query

Airframe Core shall support queries for projects, epics, sprints, ERs, DRs, issues, tasks, evidence, verification gates, metrics, and audit events.

### AF-FR-013 Sprint Model

Airframe Core shall model sprints, including status, date range, contained work, progress, completion state, and closure criteria.

### AF-FR-014 Epic Model

Airframe Core shall model epics, including contained work, progress, status, and closure criteria.

### AF-FR-015 Verification Model

Airframe Core shall model verification gates, evidence records, acceptance criteria, and human verification outcomes.

### AF-FR-016 Task Packet Generation

Airframe Core shall generate compact task packets for AI Cockpit containing only relevant task context, constraints, acceptance criteria, verification commands, protected paths, and required reporting information.

### AF-FR-017 Metrics Computation

Airframe Core shall compute project metrics including sprint progress, burndown, velocity, blocked work, recently completed work, upcoming work, active work, and verification aging.

### AF-FR-018 Audit Event Generation

Airframe Core shall generate audit events for allowed and denied write operations.

### AF-FR-019 Backend Adapter Interface

Airframe Core shall define backend adapter interfaces for reading and writing canonical entities to external backends.

### AF-FR-020 Backend Capability Model

Airframe Core shall support a capability model describing what each backend adapter can and cannot represent natively.

### AF-FR-021 Backend Mapping

Airframe Core shall map canonical entities and operations to backend-specific representations through adapters.

### AF-FR-022 Local Cache

Airframe Core may maintain a local cache for performance, metrics, offline inspection, or dashboard generation. The cache shall not silently override authoritative backend state.

### AF-FR-023 Configuration Model

Airframe Core shall define configuration for projects, backend adapters, actor policies, workflow rules, protected paths, verification commands, and cross-project delegations.

---

## 4. Security Requirements

### AF-SR-001 Deny by Default

Airframe Core shall deny operations when actor identity, actor type, project context, target project, operation permission, or workflow state cannot be certified.

### AF-SR-002 Credential Scope Validation

Airframe Core shall validate credential scope before permitting write operations.

### AF-SR-003 No Self-Declared Authority

Airframe Core shall not trust caller-provided authority class, actor type, or project scope unless derived from trusted credential context or configuration.

### AF-SR-004 Project-Scoped Mutation

Airframe Core shall only allow mutation of entities belonging to the actor's certified execution project unless explicit cross-project delegation exists.

### AF-SR-005 Cross-Project Delegation

Airframe Core shall support explicit, narrow, auditable cross-project delegation policies.

### AF-SR-006 Human-Only Operation Enforcement

Airframe Core shall prevent non-human actors from performing human-only operations.

### AF-SR-007 Sensitive Operation Policy

Airframe Core shall support policy requirements for confirmation or additional checks before sensitive operations.

### AF-SR-008 Audit Trail Integrity

Airframe Core shall generate audit events that identify actor, actor type, execution project, target project, operation, result, reason code, target entity, backend reference, and timestamp where available.

---

## 5. Data Requirements

### AF-DR-001 Entity Identifiers

Airframe Core shall define stable canonical identifiers and backend reference mappings for all managed entities.

### AF-DR-002 Required Entity Fields

Airframe Core shall define required fields for projects, epics, sprints, ERs, DRs, issues, tasks, verification gates, evidence, actors, policies, and audit events.

### AF-DR-003 Workflow State Records

Airframe Core shall maintain or reconstruct workflow state records for managed entities.

### AF-DR-004 Evidence Records

Airframe Core shall support evidence records associated with verification gates or work items.

### AF-DR-005 Metrics Records

Airframe Core shall expose computed metrics in canonical format independent of backend provider.

### AF-DR-006 Backend Mapping Records

Airframe Core shall maintain mappings between canonical entity identifiers and backend-specific identifiers.

---

## 6. Interface Requirements

### AF-IR-001 Public API

Airframe Core shall expose a public API for client CSCIs to perform domain operations.

### AF-IR-002 Read APIs

Airframe Core shall provide read APIs for dashboard summaries, project status, entity queries, metrics, task packets, and audit events.

### AF-IR-003 Write APIs

Airframe Core shall provide write APIs for entity creation, entity update, workflow transitions, evidence attachment, sprint operations, epic operations, and verification operations.

### AF-IR-004 Authority APIs

Airframe Core shall expose APIs for evaluating whether an operation is allowed, denied, or requires additional confirmation.

### AF-IR-005 Backend Adapter API

Airframe Core shall define a backend adapter interface to be implemented by provider-specific adapters.

### AF-IR-006 Configuration API

Airframe Core shall define loading, validation, and querying of project and workflow configuration.

### AF-IR-007 Audit API

Airframe Core shall expose audit event recording and query interfaces.

---

## 7. Backend Requirements

### AF-BR-001 Backend Independence

Airframe Core shall preserve backend independence by using canonical entities and operations above the adapter layer.

### AF-BR-002 Initial Backend

Airframe Core shall support at least one initial backend adapter suitable for development and verification.

### AF-BR-003 GitHub Backend

Airframe Core should support a GitHub backend adapter mapping canonical entities to GitHub Issues, Projects, Milestones, Pull Requests, Actions, labels, comments, and related data where practical.

### AF-BR-004 Local Backend

Airframe Core should support a local Markdown or SQLite backend for testing, offline workflows, or development without external service dependency.

### AF-BR-005 Backend Failure Handling

Airframe Core shall report backend failures with clear error classifications and shall avoid partial silent updates.

---

## 8. Metrics Requirements

### AF-MR-001 Sprint Progress

Airframe Core shall compute sprint progress based on sprint contents and work item status.

### AF-MR-002 Burndown

Airframe Core shall compute burndown data where estimates and sprint date ranges are available.

### AF-MR-003 Velocity

Airframe Core shall compute velocity across completed sprints where historical estimates are available.

### AF-MR-004 Blocked Work

Airframe Core shall identify blocked work and blocked reasons.

### AF-MR-005 Recently Completed Work

Airframe Core shall identify recently completed work based on workflow transition history or backend state.

### AF-MR-006 Upcoming Work

Airframe Core shall identify upcoming work from priority, sprint, epic, and readiness data.

### AF-MR-007 Verification Aging

Airframe Core shall compute age of items waiting for human verification.

---

## 9. Non-Functional Requirements

### AF-NFR-001 Portability

Airframe Core shall be designed as a reusable package or library usable by both UI and CLI clients.

### AF-NFR-002 Maintainability

Airframe Core shall separate domain model, workflow policy, authority evaluation, backend adapters, metrics, audit, and configuration concerns.

### AF-NFR-003 Testability

Airframe Core shall support unit tests, mock backend tests, policy tests, workflow transition tests, and metrics tests.

### AF-NFR-004 Performance

Airframe Core shall support efficient dashboard and task-packet generation without requiring unnecessary full-project context loading.

### AF-NFR-005 Reliability

Airframe Core shall handle backend errors, stale data, invalid transitions, authorization failures, and configuration errors predictably.

### AF-NFR-006 Extensibility

Airframe Core shall support adding backend adapters, entity types, metrics, and policy rules without requiring changes to client CSCIs.

### AF-NFR-007 Token Efficiency

Airframe Core shall support generation of compact summaries and task packets to reduce LLM token usage.

---

## 10. Verification Requirements

### AF-VR-001 Domain Model Tests

Tests shall verify canonical entity creation, validation, serialization, and mapping.

### AF-VR-002 Identity Tests

Tests shall verify identity certification and actor type derivation.

### AF-VR-003 Authority Tests

Tests shall verify permission evaluation for all defined actor types.

### AF-VR-004 Project Scope Tests

Tests shall verify that project context binding prevents unauthorized cross-project mutation.

### AF-VR-005 Workflow Tests

Tests shall verify allowed and denied state transitions.

### AF-VR-006 Backend Adapter Tests

Tests shall verify adapter mappings using mock or local backends.

### AF-VR-007 Metrics Tests

Tests shall verify burndown, velocity, sprint progress, blocked work, recently completed work, and verification aging calculations.

### AF-VR-008 Audit Tests

Tests shall verify audit event creation for allowed and denied write operations.

---

## 11. Open Issues

- Implementation language and packaging strategy remain to be selected.
- Initial backend adapter selection remains open between GitHub-first and local-backend-first.
- Final canonical workflow states remain to be finalized.
- Credential and identity-provider mechanisms remain to be selected.
