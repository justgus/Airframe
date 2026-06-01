# AI Cockpit CSCI Requirements

**Document Type:** CSCI Requirements Specification  
**CSCI:** AI Cockpit  
**System:** Agile Airframe  
**Related CSCIs:** Agile Cockpit, Airframe Core  
**Status:** Draft  

---

## 1. Introduction

### 1.1 Purpose

This document defines the requirements for the AI Cockpit Computer Software Configuration Item (CSCI). AI Cockpit is the LLM/agent-facing command-line application used to create or propose project-management artifacts, retrieve compact task packets, attach implementation evidence, and request workflow transitions that are safe for LLM agents.

AI Cockpit exists to reduce token churn, control LLM scope, support verification gates, and provide deterministic project-management interactions for coding agents such as Codex, Claude, or future agent systems.

### 1.2 Scope

AI Cockpit shall provide command-line and structured-output interfaces for LLM agents and automation clients. It shall interact with Airframe Core for identity certification, project-context binding, authority enforcement, workflow validation, canonical entity access, metrics, audit events, and backend persistence.

AI Cockpit shall not directly manipulate backend systems except through Airframe Core-defined interfaces.

### 1.3 Definitions

- **AI Cockpit:** LLM/agent-facing command-line application.
- **Agile Cockpit:** Human-facing project oversight application.
- **Agile Airframe:** Overall system/suite for LLM-assisted agile governance.
- **Airframe Core:** Shared project-management core package/library.
- **LLM Agent:** A certified non-human actor that may propose or update limited project artifacts.
- **Execution Project:** The project context under which an agent session or credential is running.
- **Target Project:** The project containing the entity that an operation would modify.
- **Project Scope Mismatch:** Condition where execution project and target project do not match and no explicit delegation exists.
- **Task Packet:** Compact, deterministic packet containing exactly the information an LLM needs to perform a work item.

### 1.4 References

- Airframe Core CSCI Requirements
- Agile Cockpit CSCI Requirements
- Airframe Core CSCI Design
- Project workflow policy documents

---

## 2. CSCI Overview

### 2.1 Operational Concept

AI Cockpit shall serve as a controlled command interface between LLM agents and the project-management system. It shall support agent workflows such as:

- Proposing ERs, DRs, issues, and tasks.
- Retrieving the next available task within project scope.
- Generating a compact LLM task packet.
- Attaching implementation evidence.
- Marking work ready for human verification.
- Requesting summaries of project status.

AI Cockpit shall deny human-only operations such as accepting work, closing work, opening or closing sprints, opening or closing epics, and changing workflow rules.

### 2.2 Users and Actors

AI Cockpit shall support the following actor types as certified by Airframe Core:

- LLMAgent
- Automation
- ReadOnlyObserver, where appropriate

AI Cockpit shall not permit the caller to self-declare actor type or project authority.

### 2.3 External Interfaces

AI Cockpit shall interface with:

- Airframe Core public API.
- Local project configuration.
- Operating system shell.
- LLM agent runtime environments.
- Optional JSON, Markdown, or plain-text structured output consumers.

### 2.4 Assumptions and Constraints

- AI Cockpit commands may be executed by LLM agents with limited credentials.
- Actor type and project scope shall be derived from credentials/session context, not command-line assertions.
- Project context shall be treated as a security boundary.
- AI Cockpit shall prefer compact, deterministic output suitable for LLM consumption.

---

## 3. Functional Requirements

### AIC-FR-001 Command-Line Interface

AI Cockpit shall provide a command-line interface for project-management operations.

### AIC-FR-002 Project Context Discovery

AI Cockpit shall determine the execution project from Airframe Core-certified context, configuration, or credential scope.

### AIC-FR-003 Propose Issue

AI Cockpit shall allow authorized LLM agents to propose issues within their certified project context.

### AIC-FR-004 Propose ER

AI Cockpit shall allow authorized LLM agents to propose Enhancement Requests within their certified project context.

### AIC-FR-005 Propose DR

AI Cockpit shall allow authorized LLM agents to propose Discrepancy Reports within their certified project context.

### AIC-FR-006 Propose Task

AI Cockpit shall allow authorized LLM agents to propose tasks within their certified project context.

### AIC-FR-007 Retrieve Next Task

AI Cockpit shall support retrieval of the next task appropriate to the agent's execution project and authority.

### AIC-FR-008 Generate Task Packet

AI Cockpit shall generate compact task packets containing:

- Project name.
- Work item identifier.
- Objective.
- Scope.
- Out-of-scope constraints.
- Acceptance criteria.
- Verification requirements.
- Relevant files, when available.
- Protected paths or no-touch areas.
- Required final report format.

### AIC-FR-009 Attach Evidence

AI Cockpit shall allow authorized agents to attach evidence to a work item, including command output summaries, test results, changed files, or implementation notes.

### AIC-FR-010 Mark Ready for Human Verification

AI Cockpit shall allow authorized agents to request transition of a work item to Ready for Human Verification when Airframe Core permits the transition.

### AIC-FR-011 Project Summary

AI Cockpit shall support compact project summary output for the execution project.

### AIC-FR-012 Multi-Project Summary Restrictions

AI Cockpit shall not allow an LLM agent to retrieve or mutate multi-project data unless the actor has explicit authority or read-only aggregation permission.

### AIC-FR-013 Deny Human-Only Operations

AI Cockpit shall deny attempts by LLM agents to accept work, reject work as final, close issues, open or close sprints, open or close epics, approve architecture decisions, or change workflow rules.

### AIC-FR-014 Project Scope Mismatch Detection

AI Cockpit shall detect and report project scope mismatches returned by Airframe Core.

### AIC-FR-015 Structured Output

AI Cockpit shall support structured output formats suitable for LLM consumption, including Markdown and JSON.

### AIC-FR-016 Dry-Run Mode

AI Cockpit should support a dry-run mode that validates an operation without committing backend changes.

### AIC-FR-017 Audit Display

AI Cockpit shall display or return audit identifiers for write operations where available.

---

## 4. Security and Authority Requirements

### AIC-SR-001 Certified Agent Identity

AI Cockpit shall rely on Airframe Core to authenticate and certify the actor identity and actor type.

### AIC-SR-002 No Actor Spoofing

AI Cockpit shall not accept command-line flags or input fields that grant or override actor type, role, or authority.

### AIC-SR-003 Project-Scoped Authority

AI Cockpit shall enforce Airframe Core's project-scoped authority decisions. An agent running under project X shall not mutate project Z unless explicit cross-project delegation exists.

### AIC-SR-004 Credential Scope Validation

AI Cockpit shall provide credential context to Airframe Core when required to validate operation scope.

### AIC-SR-005 Deny by Default

AI Cockpit shall deny operations when identity, actor type, project context, target project, or workflow state cannot be certified.

### AIC-SR-006 Human-Only Gate Protection

AI Cockpit shall not provide bypass mechanisms for human-only workflow gates.

### AIC-SR-007 Auditability

All AI Cockpit write operations shall result in Airframe Core-generated audit events.

---

## 5. Data Requirements

### AIC-DR-001 Task Packet Data

AI Cockpit shall consume task packet data generated or assembled by Airframe Core.

### AIC-DR-002 Entity Proposal Data

AI Cockpit shall provide proposal data for issues, ERs, DRs, and tasks using Airframe Core canonical fields.

### AIC-DR-003 Evidence Data

AI Cockpit shall support evidence records containing summary, source, timestamp, command results, file references, and optional backend references.

### AIC-DR-004 Output Data Minimization

AI Cockpit shall minimize output to the data required for the requested operation unless verbose output is explicitly requested.

---

## 6. Interface Requirements

### AIC-IR-001 Airframe Core API

AI Cockpit shall use Airframe Core APIs for all project-management operations.

### AIC-IR-002 CLI Command Model

AI Cockpit commands shall use domain terms such as issue, ER, DR, task, evidence, verification, sprint, and epic rather than backend-specific names.

### AIC-IR-003 Machine-Readable Output

AI Cockpit shall provide machine-readable output suitable for LLM or automation consumption.

### AIC-IR-004 Error Output

AI Cockpit shall provide concise, structured error output including reason codes for denied operations.

### AIC-IR-005 Configuration Interface

AI Cockpit shall load project and actor context using Airframe Core-defined configuration mechanisms.

---

## 7. Non-Functional Requirements

### AIC-NFR-001 Token Efficiency

AI Cockpit shall be optimized to reduce LLM token consumption by returning compact, relevant, task-specific information.

### AIC-NFR-002 Deterministic Output

AI Cockpit output shall be deterministic for a given request and system state, excluding timestamps or backend-generated identifiers.

### AIC-NFR-003 Portability

AI Cockpit shall operate in local development environments used by coding agents and automation workflows.

### AIC-NFR-004 Reliability

AI Cockpit shall clearly distinguish backend failures, authentication failures, authorization failures, invalid workflow transitions, and project scope mismatches.

### AIC-NFR-005 Maintainability

AI Cockpit shall keep command parsing and output formatting separate from Airframe Core authority and workflow logic.

---

## 8. Verification Requirements

### AIC-VR-001 Command Tests

Tests shall verify AI Cockpit command parsing and output formatting.

### AIC-VR-002 Authority Denial Tests

Tests shall verify that LLM agents cannot perform human-only operations.

### AIC-VR-003 Project Scope Tests

Tests shall verify that an agent operating under one project context cannot mutate another project without explicit delegation.

### AIC-VR-004 Task Packet Tests

Tests shall verify that task packets contain required sections and omit unrelated context.

### AIC-VR-005 Evidence Tests

Tests shall verify that evidence can be attached only to authorized target work items.

### AIC-VR-006 Output Format Tests

Tests shall verify Markdown and JSON output formats.

---

## 9. Open Issues

- Final CLI command names remain to be selected.
- Initial credential strategy for local LLM agents remains to be selected.
- Initial backend adapter is expected to be GitHub, but AI Cockpit shall remain backend-agnostic through Airframe Core.
