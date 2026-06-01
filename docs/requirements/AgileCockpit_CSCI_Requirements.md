# Agile Cockpit CSCI Requirements

**Document Type:** CSCI Requirements Specification  
**CSCI:** Agile Cockpit  
**System:** Agile Airframe  
**Related CSCIs:** AI Cockpit, Airframe Core  
**Status:** Draft  

---

## 1. Introduction

### 1.1 Purpose

This document defines the requirements for the Agile Cockpit Computer Software Configuration Item (CSCI). Agile Cockpit is the human-facing application used to monitor, manage, verify, and approve work across one or more software projects managed through the Agile Airframe.

Agile Cockpit provides concise project visibility, supports human-controlled workflow gates, displays project health metrics, and allows authorized human users to perform management actions such as approving work, opening or closing sprints, and opening or closing epics.

### 1.2 Scope

Agile Cockpit shall provide a user interface for human project oversight. It shall interact with Airframe Core for identity certification, authority enforcement, workflow validation, canonical project data, metrics, audit events, and backend access.

Agile Cockpit shall not directly manipulate backend systems such as GitHub, Linear, Jira, Plane, Markdown stores, or SQLite stores except through Airframe Core-defined interfaces.

### 1.3 Definitions

- **Agile Cockpit:** Human-facing application for project visibility, management, verification, and approval.
- **AI Cockpit:** LLM/agent-facing command-line application.
- **Agile Airframe:** Overall system/suite for LLM-assisted agile governance.
- **Airframe Core:** Shared project-management core package/library.
- **Actor:** A human, LLM agent, automation account, or observer interacting with the system.
- **Actor Type:** Certified classification of an actor, such as HumanOwner, HumanReviewer, LLMAgent, Automation, or ReadOnlyObserver.
- **Project Context:** The project scope under which an actor session or credential is operating.
- **ER:** Enhancement Request.
- **DR:** Discrepancy Report.
- **Task Packet:** Compact work packet generated for an LLM or agent.
- **Verification Gate:** Required evidence or check that must be satisfied before work may be accepted.

### 1.4 References

- Airframe Core CSCI Requirements
- AI Cockpit CSCI Requirements
- Airframe Core CSCI Design
- Project repository workflow policies

---

## 2. CSCI Overview

### 2.1 Operational Concept

Agile Cockpit shall provide a dashboard-style interface for one or more software projects. The human user shall be able to quickly determine:

- What work was recently completed.
- What work is currently active.
- What work is blocked.
- What work is ready for human verification.
- What work is next.
- What work is upcoming.
- Current sprint and epic status.
- Project health, velocity, burndown, and related metrics.

The application shall serve as the primary human control surface for approvals and management actions that LLM agents are not permitted to perform.

### 2.2 Users and Actors

Agile Cockpit shall support the following actor types through Airframe Core-certified identity and authority mechanisms:

- HumanOwner
- HumanMaintainer
- HumanReviewer
- ReadOnlyObserver

Agile Cockpit shall not allow the caller to self-declare actor type. Actor identity and actor type shall be derived from authenticated credentials, session context, or other Airframe Core-supported identity mechanisms.

### 2.3 External Interfaces

Agile Cockpit shall interface with:

- Airframe Core public API.
- Local configuration files as defined by Airframe Core.
- Optional local cache or generated dashboard artifacts.
- Operating system authentication/session facilities, where supported.

Agile Cockpit shall not directly depend on a specific backend provider.

### 2.4 Assumptions and Constraints

- Airframe Core is the authoritative source for workflow, authority, canonical entities, metrics, and backend adapter access.
- Backends may include GitHub initially, with future support for Linear, Jira, Plane, Markdown, SQLite, or other systems.
- Human users retain authority for accepting completed work and closing sprints or epics.
- The UI shall be optimized for rapid situational awareness.

---

## 3. Functional Requirements

### AC-FR-001 Project Dashboard

Agile Cockpit shall display a consolidated dashboard for one or more configured projects.

### AC-FR-002 Recently Completed Work

Agile Cockpit shall display recently completed work items, including completed ERs, DRs, issues, tasks, merged pull requests, or backend-equivalent work records where available.

### AC-FR-003 Active Work

Agile Cockpit shall display currently active work items grouped by project, sprint, epic, status, or priority.

### AC-FR-004 Upcoming Work

Agile Cockpit shall display upcoming work items based on Airframe Core-provided priority, sprint, epic, backlog, or readiness information.

### AC-FR-005 Blocked Work

Agile Cockpit shall display blocked work items and associated blocked reasons where available.

### AC-FR-006 Ready for Human Verification

Agile Cockpit shall display work items that have been marked ready for human verification by an authorized actor.

### AC-FR-007 Verification Review

Agile Cockpit shall allow an authorized human actor to review verification evidence associated with a work item.

### AC-FR-008 Accept Work

Agile Cockpit shall allow an authorized human actor to accept completed work only after Airframe Core determines the operation is allowed by actor authority and workflow state.

### AC-FR-009 Reject Work

Agile Cockpit shall allow an authorized human actor to reject work and return it to an appropriate workflow state with a required reason or comment.

### AC-FR-010 Sprint Control

Agile Cockpit shall allow authorized human actors to open and close sprints, subject to Airframe Core workflow validation.

### AC-FR-011 Epic Control

Agile Cockpit shall allow authorized human actors to open and close epics, subject to Airframe Core workflow validation.

### AC-FR-012 ER / DR / Issue / Task Review

Agile Cockpit shall display ERs, DRs, issues, and tasks using canonical Airframe Core entity data independent of backend-specific storage.

### AC-FR-013 Metrics Display

Agile Cockpit shall display Airframe Core-provided metrics including, at minimum:

- Sprint progress.
- Burndown.
- Velocity.
- Blocked work count.
- Recently completed work count.
- Work ready for verification.
- Aging of verification items.

### AC-FR-014 Audit Visibility

Agile Cockpit shall provide access to audit events associated with project-management actions, including allowed and denied operations.

### AC-FR-015 Multi-Project View

Agile Cockpit shall support viewing multiple projects in a consolidated dashboard.

### AC-FR-016 Project-Specific View

Agile Cockpit shall support drilling into a single project for detailed review.

### AC-FR-017 Backend-Agnostic Operation Display

Agile Cockpit shall present operations and entities using Airframe Core domain terms rather than backend-specific terminology where practical.

### AC-FR-018 Denied Operation Reporting

When Airframe Core denies an operation, Agile Cockpit shall display the denial reason in human-readable form.

---

## 4. Security and Authority Requirements

### AC-SR-001 Certified Actor Identity

Agile Cockpit shall rely on Airframe Core to certify actor identity and actor type before any write operation is requested.

### AC-SR-002 No Self-Declared Authority

Agile Cockpit shall not allow a user or client process to self-declare an actor type for the purpose of obtaining authority.

### AC-SR-003 Human-Only Operations

Agile Cockpit shall expose human-only operations only to authenticated and authorized human actor types as determined by Airframe Core.

### AC-SR-004 Project Context Binding

Agile Cockpit shall include project context in all operation requests. Airframe Core shall determine whether the actor may operate on the target project.

### AC-SR-005 Sensitive Operation Confirmation

Agile Cockpit shall require explicit human confirmation before requesting sensitive operations such as closing a sprint, closing an epic, bulk status changes, or configuration changes.

### AC-SR-006 Audit Event Generation

Agile Cockpit write operations shall result in Airframe Core-generated audit events.

---

## 5. Data Requirements

### AC-DR-001 Dashboard Data

Agile Cockpit shall consume dashboard summary data from Airframe Core.

### AC-DR-002 Entity Data

Agile Cockpit shall consume canonical entity records from Airframe Core for projects, epics, sprints, ERs, DRs, issues, tasks, verification gates, evidence, and audit events.

### AC-DR-003 Metrics Data

Agile Cockpit shall consume metric records computed by Airframe Core.

### AC-DR-004 Local Presentation State

Agile Cockpit may maintain local presentation state such as user-selected filters, collapsed sections, and dashboard preferences. Such state shall not override authoritative Airframe Core workflow state.

---

## 6. Interface Requirements

### AC-IR-001 Airframe Core API

Agile Cockpit shall use Airframe Core APIs for all project-management reads and writes.

### AC-IR-002 Configuration Interface

Agile Cockpit shall load project and workspace configuration through Airframe Core-defined configuration interfaces.

### AC-IR-003 Export Interface

Agile Cockpit should support exporting dashboard summaries or reports in Markdown, HTML, JSON, or other formats defined by project needs.

### AC-IR-004 Accessibility Interface

Agile Cockpit shall provide accessible navigation, readable status indicators, keyboard access where applicable, and concise views suitable for low-click interaction.

---

## 7. Non-Functional Requirements

### AC-NFR-001 Usability

Agile Cockpit shall prioritize one- or two-click access to current status, recently completed work, active work, upcoming work, blocked work, and verification queues.

### AC-NFR-002 Accessibility

Agile Cockpit shall be designed with accessibility as a primary concern.

### AC-NFR-003 Performance

Agile Cockpit shall load dashboard summaries for configured projects without requiring full backend ingestion during routine use, where cached or summarized data is available.

### AC-NFR-004 Reliability

Agile Cockpit shall clearly report stale data, backend failures, authorization failures, and synchronization errors.

### AC-NFR-005 Backend Independence

Agile Cockpit shall not hard-code assumptions specific to GitHub or any other backend provider.

### AC-NFR-006 Maintainability

Agile Cockpit shall keep UI logic separate from Airframe Core workflow and authority logic.

---

## 8. Verification Requirements

### AC-VR-001 Dashboard Verification

Tests shall verify that Agile Cockpit displays project summaries, active work, upcoming work, blocked work, and recently completed work from Airframe Core-provided data.

### AC-VR-002 Authority Verification

Tests shall verify that human-only operations are not presented or are disabled for unauthorized actor types.

### AC-VR-003 Workflow Verification

Tests shall verify that Agile Cockpit properly handles allowed and denied Airframe Core workflow operations.

### AC-VR-004 Metrics Verification

Tests shall verify correct display of Airframe Core-provided burndown, velocity, and sprint progress metrics.

### AC-VR-005 Accessibility Verification

Agile Cockpit shall undergo accessibility checks appropriate to the selected UI platform.

---

## 9. Open Issues

- Final UI platform selection remains open: local web application, static generated dashboard, native macOS/iPadOS application, or hybrid approach.
- The initial authentication mechanism for local human use remains to be selected.
- The first backend adapter is expected to be GitHub, but Agile Cockpit shall remain backend-agnostic.
