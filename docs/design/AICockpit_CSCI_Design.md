# AI Cockpit CSCI Design

**Document Type:** CSCI Design Description  
**CSCI:** AI Cockpit  
**System:** Agile Airframe  
**Related CSCIs:** Agile Cockpit, Airframe Core  
**Status:** Draft  

---

## 1. Design Overview

### 1.1 Purpose

This document describes the preliminary design of AI Cockpit, the LLM/agent-facing command-line application for safe, compact, deterministic interaction with the project-management system.

### 1.2 Design Goals

AI Cockpit is designed to reduce token churn and control agent behavior by providing compact task packets, limited domain operations, structured output, evidence attachment, and strict enforcement of Airframe Core authority and workflow rules.

### 1.3 Major Design Constraints

- AI Cockpit shall not access backend systems directly.
- AI Cockpit shall not implement independent authority or workflow decisions.
- AI Cockpit shall not allow actor type or project authority to be spoofed through command-line arguments.
- AI Cockpit shall be optimized for LLM/agent consumption rather than human visual browsing.

---

## 2. Architectural Context

AI Cockpit is a peer client of Agile Cockpit. Both communicate directly with Airframe Core.

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

### 3.1 CLI Entry Point

The CLI Entry Point parses command-line arguments, initializes configuration, obtains credential or session context, and dispatches commands.

### 3.2 Command Parser

The Command Parser maps shell commands to domain command requests.

Example command families:

```text
ai-cockpit project summary
ai-cockpit task next
ai-cockpit task packet <id>
ai-cockpit issue propose
ai-cockpit er propose
ai-cockpit dr propose
ai-cockpit task propose
ai-cockpit evidence attach <id>
ai-cockpit work ready-for-verification <id>
```

Final command names remain open.

### 3.3 Context Resolver

The Context Resolver determines execution project and credential context. It shall not allow arbitrary project switching unless Airframe Core certifies that the credential supports the requested project scope.

### 3.4 Airframe Core Client

The Airframe Core Client invokes Airframe Core APIs for command execution, task packet retrieval, evidence attachment, and workflow transitions.

### 3.5 Output Formatter

The Output Formatter renders Airframe Core responses in supported formats:

- Compact Markdown.
- JSON.
- Plain text.
- Diagnostic verbose output.

Default output should be compact and deterministic.

### 3.6 Error Formatter

The Error Formatter renders denied operations, invalid transitions, authentication failures, project scope mismatches, backend failures, and malformed command input.

### 3.7 Input Template Processor

For proposal commands, AI Cockpit may accept structured input from files, stdin, or command-line flags. Input shall be validated before submission to Airframe Core.

---

## 4. Interface Design

### 4.1 Airframe Core Read Interfaces

AI Cockpit shall call Airframe Core read APIs for:

- Project summary.
- Next task.
- Task packet.
- Work item details.
- Verification status.
- Audit references.

### 4.2 Airframe Core Write Interfaces

AI Cockpit shall call Airframe Core write APIs for:

- Propose issue.
- Propose task.
- Attach evidence.
- Mark ready for human verification.

### 4.3 Identity and Context Interface

AI Cockpit shall provide execution environment and credential context to Airframe Core. Airframe Core shall certify actor identity, actor type, execution project, target project, and authority.

### 4.4 Output Interface

AI Cockpit shall support explicit output selection:

```text
--format markdown
--format json
--format text
```

### 4.5 Dry-Run Interface

AI Cockpit should support dry-run execution for commands that would otherwise write state.

---

## 5. Data Design

### 5.1 Command Models

AI Cockpit shall define internal command request models corresponding to supported domain operations.

Primary command models:

- ProjectSummaryCommand.
- NextTaskCommand.
- TaskPacketCommand.
- ProposeIssueCommand.
- ProposeERCommand.
- ProposeDRCommand.
- ProposeTaskCommand.
- AttachEvidenceCommand.
- ReadyForVerificationCommand.

### 5.2 Output Models

AI Cockpit shall define output models independent of final text rendering.

Primary output models:

- TaskPacketOutput.
- ProjectSummaryOutput.
- ProposalResultOutput.
- EvidenceResultOutput.
- DenialOutput.
- ErrorOutput.

### 5.3 Input Data

Proposal and evidence commands may receive structured input from:

- stdin.
- file path.
- command-line flags.
- generated templates.

### 5.4 No Independent Canonical State

AI Cockpit shall not maintain independent canonical project state. Canonical state belongs to Airframe Core and backend systems.

---

## 6. Security Design

### 6.1 No Self-Declared Actor Type

AI Cockpit shall not accept command-line input that grants actor type, authority class, or human status.

### 6.2 Execution Project Binding

AI Cockpit shall resolve execution project through trusted configuration or credential context and submit it to Airframe Core for certification.

### 6.3 Target Project Validation

If a command includes an explicit target project, AI Cockpit shall submit it to Airframe Core for validation. Airframe Core shall deny unauthorized cross-project mutation.

### 6.4 Human-Only Operations

AI Cockpit shall not expose normal commands for human-only operations. If such operations are attempted, Airframe Core denial shall be rendered clearly.

### 6.5 Credential Handling

AI Cockpit shall avoid storing long-lived credentials in generated output. Credential discovery and storage strategy shall be defined by project implementation policy.

### 6.6 Audit Reporting

AI Cockpit shall report audit event identifiers or summaries for write operations where available.

---

## 7. Error and Failure Handling

### 7.1 Authentication Failure

AI Cockpit shall return a structured error indicating actor identity could not be certified.

### 7.2 Authorization Failure

AI Cockpit shall return a structured denial indicating actor lacks permission.

### 7.3 Project Scope Mismatch

AI Cockpit shall return a structured denial including execution project, target project, and reason code when available.

### 7.4 Invalid Workflow Transition

AI Cockpit shall return current state, requested transition, and allowed next operations where available.

### 7.5 Backend Failure

AI Cockpit shall return backend failure classification and avoid representing failed operations as successful.

### 7.6 Malformed Input

AI Cockpit shall validate required fields and return concise error messages suitable for correction by an LLM agent.

---

## 8. Verification Design

### 8.1 Unit Tests

Unit tests shall cover command parsing, context resolution, output formatting, and error formatting.

### 8.2 Airframe Core Mock Tests

AI Cockpit shall be tested against mock Airframe Core responses for allowed operations, denied operations, backend failures, and project scope mismatches.

### 8.3 Task Packet Tests

Tests shall verify compact and complete rendering of task packets.

### 8.4 Security Tests

Tests shall verify that command-line arguments cannot spoof actor type or bypass project context.

### 8.5 Output Format Tests

Tests shall verify Markdown, JSON, and text output formats.

---

## 9. Open Design Decisions

- Final command names remain open.
- Implementation language selected: Swift.
- Product form selected: standalone Swift package executable with reusable command library target; see `docs/architecture/CSCI_Project_Form_Trade_Study.md`.
- Credential discovery strategy remains open.
- JSON schema for machine-readable output remains open.
