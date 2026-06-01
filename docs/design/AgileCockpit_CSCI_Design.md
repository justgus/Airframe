# Agile Cockpit CSCI Design

**Document Type:** CSCI Design Description  
**CSCI:** Agile Cockpit  
**System:** Agile Airframe  
**Related CSCIs:** AI Cockpit, Airframe Core  
**Status:** Draft  

---

## 1. Design Overview

### 1.1 Purpose

This document describes the preliminary design of Agile Cockpit, the human-facing application for project oversight, verification, approval, sprint and epic control, and metrics display.

### 1.2 Design Goals

Agile Cockpit is designed to provide rapid situational awareness across one or more projects. It shall prioritize concise project status, low-click navigation, accessibility, and safe human-controlled management actions.

### 1.3 Major Design Constraints

- Agile Cockpit shall not directly access backend provider APIs for project-management operations.
- Agile Cockpit shall use Airframe Core for all domain operations, workflow decisions, authority checks, metrics, and backend access.
- Agile Cockpit shall not implement independent authorization or workflow logic.
- Agile Cockpit shall be backend-agnostic.

---

## 2. Architectural Context

Agile Cockpit is a peer client of AI Cockpit. Both communicate directly with Airframe Core.

```text
        ┌────────────────────┐        ┌────────────────────┐
        │  Agile Cockpit     │        │   AI Cockpit       │
        │  Human UI          │        │   Agent CLI        │
        └─────────┬──────────┘        └─────────┬──────────┘
                  │                             │
                  └──────────────┬──────────────┘
                                 │
                         ┌───────▼───────┐
                         │   Airframe Core    │
                         └───────┬───────┘
                                 │
                         ┌───────▼───────┐
                         │   Backends    │
                         └───────────────┘
```

---

## 3. Component Design

### 3.1 Application Shell

The Application Shell provides top-level navigation, project selection, user/session display, global status indicators, and access to dashboard views.

Responsibilities:

- Load workspace configuration through Airframe Core.
- Establish or request human session context.
- Display current identity and project context.
- Route to dashboard, project detail, verification, metrics, and audit views.

### 3.2 Dashboard View

The Dashboard View provides the primary one- or two-click status view.

Sections:

- Recently Done.
- Active Now.
- Ready for Human Verification.
- Blocked.
- Next Up.
- Upcoming.
- Sprint Health.
- Epic Progress.
- CI / backend status where available.

The Dashboard View consumes Airframe Core dashboard summary APIs.

### 3.3 Project Detail View

The Project Detail View displays detailed information for a selected project, including sprints, epics, active work, backlog, verification queue, and metrics.

### 3.4 Verification Review View

The Verification Review View displays work items ready for human verification. It presents acceptance criteria, verification gates, evidence records, related backend references, and available human actions.

Human actions include:

- Accept work.
- Reject work with reason.
- Request additional evidence.
- Return work to in-progress or proposed state, subject to Airframe Core workflow rules.

### 3.5 Sprint Management View

The Sprint Management View supports reviewing sprint status and requesting human-authorized sprint operations such as open sprint and close sprint.

### 3.6 Epic Management View

The Epic Management View supports reviewing epic status and requesting human-authorized epic operations such as open epic and close epic.

### 3.7 Metrics View

The Metrics View displays Airframe Core-computed metrics such as sprint progress, burndown, velocity, blocked work, recently completed work, upcoming work, and verification aging.

### 3.8 Audit View

The Audit View displays audit events returned by Airframe Core, including allowed and denied operations.

### 3.9 Operation Dispatcher

The Operation Dispatcher converts UI actions into Airframe Core domain operation requests. It shall not bypass Airframe Core authority or workflow checks.

### 3.10 Error Presentation Component

The Error Presentation Component displays Airframe Core errors including authentication failures, authorization failures, invalid workflow transitions, project scope mismatches, backend failures, and stale data warnings.

---

## 4. Interface Design

### 4.1 Airframe Core Read Interfaces

Agile Cockpit shall call Airframe Core read APIs for:

- Workspace summary.
- Project summary.
- Dashboard summary.
- Entity details.
- Sprint details.
- Epic details.
- Verification queues.
- Metrics.
- Audit events.

### 4.2 Airframe Core Write Interfaces

Agile Cockpit shall call Airframe Core write APIs for:

- Accept work.
- Reject work.
- Open sprint.
- Close sprint.
- Open epic.
- Close epic.
- Add human comment.
- Request additional evidence.

### 4.3 Identity and Context Interface

Agile Cockpit shall provide or obtain human session context and pass required context to Airframe Core. Airframe Core shall certify actor identity, actor type, and project authority.

### 4.4 Configuration Interface

Agile Cockpit shall use Airframe Core configuration APIs for workspace and project configuration.

---

## 5. Data Design

### 5.1 View Models

Agile Cockpit shall define presentation-oriented view models derived from Airframe Core canonical entities. View models shall not replace canonical Airframe Core state.

Primary view models:

- WorkspaceDashboardViewModel.
- ProjectSummaryViewModel.
- WorkItemSummaryViewModel.
- VerificationReviewViewModel.
- SprintHealthViewModel.
- EpicProgressViewModel.
- MetricSeriesViewModel.
- AuditEventViewModel.

### 5.2 Local UI State

Agile Cockpit may store local UI state such as selected project, active filters, column layouts, collapsed sections, and preferred dashboard views.

### 5.3 Cache Usage

Agile Cockpit may rely on Airframe Core-provided cache data. Agile Cockpit shall display freshness information where stale data is possible.

---

## 6. Security Design

### 6.1 Identity Boundary

Agile Cockpit shall not authenticate by assertion. It shall obtain session credentials or local identity context and submit them to Airframe Core for certification.

### 6.2 Human-Only Controls

Human-only controls shall be visible only when Airframe Core indicates the actor may request them, or disabled with explanatory status when useful.

### 6.3 Project Context Binding

Every operation request shall include or derive the target project. Airframe Core shall enforce project-context binding.

### 6.4 Sensitive Action Confirmation

Agile Cockpit shall require explicit confirmation before requesting sensitive operations from Airframe Core.

### 6.5 Denied Operation Handling

If Airframe Core denies an operation, Agile Cockpit shall display the reason code and explanation without retrying automatically.

---

## 7. Error and Failure Handling

### 7.1 Authentication Failure

Agile Cockpit shall notify the user that identity could not be certified.

### 7.2 Authorization Failure

Agile Cockpit shall display that the user lacks authority for the requested operation.

### 7.3 Workflow State Conflict

Agile Cockpit shall refresh the affected entity and display current state when workflow conflict occurs.

### 7.4 Project Scope Mismatch

Agile Cockpit shall display project scope mismatch details returned by Airframe Core.

### 7.5 Backend Failure

Agile Cockpit shall report backend failure and preserve local UI state where practical.

---

## 8. Verification Design

### 8.1 Unit Tests

Unit tests shall cover view-model transformation, operation dispatch construction, and error presentation.

### 8.2 Integration Tests

Integration tests shall use mock Airframe Core services to verify dashboard, verification, sprint, epic, metrics, and audit workflows.

### 8.3 Human Workflow Tests

Tests shall verify that authorized human actors can request appropriate operations and unauthorized actors cannot.

### 8.4 Accessibility Tests

Accessibility tests shall be defined according to the chosen UI platform.

---

## 9. Open Design Decisions

- Final UI platform remains open.
- Local authentication/session strategy remains open.
- Dashboard visual design remains open.
- Report/export formats remain open.
