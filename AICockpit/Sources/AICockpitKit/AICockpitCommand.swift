import AirframeCore
import Foundation

public struct AICockpitCommandResult: Equatable, Sendable {
    public let exitCode: Int32
    public let standardOutput: String
    public let standardError: String

    public init(exitCode: Int32, standardOutput: String = "", standardError: String = "") {
        self.exitCode = exitCode
        self.standardOutput = standardOutput
        self.standardError = standardError
    }
}

public enum AICockpitCommand {
    public static func main(arguments: [String]) -> Int32 {
        let result = response(arguments: arguments)

        if !result.standardOutput.isEmpty {
            print(result.standardOutput)
        }

        if !result.standardError.isEmpty {
            fputs(result.standardError, stderr)
        }

        return result.exitCode
    }

    public static func response(arguments: [String]) -> AICockpitCommandResult {
        let parsed = AICockpitArguments(arguments)
        let outputFormat = parsed.value(for: "--output").flatMap(AICockpitOutputFormat.init(rawValue:)) ?? .markdown

        if arguments.isEmpty || arguments.contains("--help") || arguments.contains("-h") {
            return AICockpitCommandResult(exitCode: 0, standardOutput: helpText())
        }

        if arguments == ["version"] || arguments == ["--version"] {
            return AICockpitCommandResult(exitCode: 0, standardOutput: AirframeCoreInfo.current.summary)
        }

        if arguments == ["context"] {
            do {
                let context = try AirframeConfigurationLoader().loadSampleContext()
                return AICockpitCommandResult(
                    exitCode: 0,
                    standardOutput: contextText(for: context)
                )
            } catch {
                return AICockpitCommandResult(
                    exitCode: 78,
                    standardError: "aicockpit: \(error)\n"
                )
            }
        }

        if arguments == ["authority", "demo-denied"] {
            do {
                let context = try AirframeConfigurationLoader().loadSampleContext()
                let certifiedContext = try sampleLLMContext(projectID: context.project.id)
                let operation = AirframeOperation(
                    id: AirframeID("OP-ACCEPT-WORK"),
                    category: .humanAcceptance
                )
                let decision = AirframeAuthorityEvaluator().evaluate(
                    context: certifiedContext,
                    operation: operation,
                    targetProjectID: context.project.id
                )

                return AICockpitCommandResult(
                    exitCode: decision.isAllowed ? 0 : 77,
                    standardOutput: deniedOperationText(
                        decision: decision,
                        operation: operation,
                        actorID: certifiedContext.actor.id,
                        projectID: context.project.id
                    )
                )
            } catch {
                return AICockpitCommandResult(
                    exitCode: 78,
                    standardError: "aicockpit: \(error)\n"
                )
            }
        }

        if parsed.positionals == ["project", "summary"] {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, _ in
                let summary = try backend.dashboardSummary()
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "projectSummary",
                        message: "Local project summary",
                        workItem: nil,
                        taskPacket: nil,
                        dashboardSummary: summary,
                        evidence: []
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals == ["task", "propose"] || parsed.positionals == ["issue", "propose"] {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, context in
                let kind: AirframeWorkItemKind = parsed.positionals[0] == "task" ? .task : .issue
                let operation = AirframeOperation(
                    id: AirframeID(kind == .task ? "OP-PROPOSE-TASK" : "OP-PROPOSE-ISSUE"),
                    category: .proposal
                )
                let decision = AirframeAuthorityEvaluator().evaluate(
                    context: context,
                    operation: operation,
                    targetProjectID: context.targetProjectID
                )
                guard decision.isAllowed else {
                    throw AICockpitCommandError.denied(decision, operation)
                }

                let id = AirframeID(try parsed.requiredValue(for: "--id"))
                let title = try parsed.requiredValue(for: "--title")
                let record = AirframeLocalWorkRecord(
                    workItem: AirframeWorkItem(
                        id: id,
                        kind: kind,
                        title: title,
                        status: .active,
                        githubIssue: parsed.value(for: "--github").flatMap(Int.init)
                    ),
                    epicID: parsed.value(for: "--epic").map(AirframeID.init) ?? AirframeID("EP-005"),
                    sprintID: parsed.value(for: "--sprint").map(AirframeID.init) ?? AirframeID("SP-005"),
                    priority: parsed.value(for: "--priority").flatMap(AirframeWorkPriority.init(rawValue:)) ?? .medium,
                    acceptanceCriteria: parsed.repeatedValues(for: "--acceptance"),
                    scope: parsed.repeatedValues(for: "--scope"),
                    constraints: parsed.repeatedValues(for: "--constraint"),
                    evidenceRequirements: parsed.repeatedValues(for: "--evidence-required"),
                    protectedPaths: parsed.repeatedValues(for: "--protected-path")
                )
                try backend.createWorkRecord(record)
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "\(kind.rawValue)Proposal",
                        message: "\(kind.rawValue.capitalized) proposed",
                        workItem: record.workItem,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: []
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals == ["task", "next"] {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, _ in
                let nextTask = try backend.dashboardSummary().nextTask
                return try render(
                    AICockpitCommandEnvelope(
                        status: nextTask == nil ? "empty" : "ok",
                        kind: "nextTask",
                        message: nextTask == nil ? "No active task is available" : "Next active task",
                        workItem: nextTask,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: []
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3 && parsed.positionals[0] == "task" && parsed.positionals[1] == "packet" {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, _ in
                let packet = try backend.taskPacket(for: AirframeID(parsed.positionals[2]))
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "taskPacket",
                        message: "Task packet generated",
                        workItem: packet.workItem,
                        taskPacket: packet,
                        dashboardSummary: nil,
                        evidence: packet.existingEvidence
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3 && parsed.positionals[0] == "evidence" && parsed.positionals[1] == "attach" {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, context in
                let operation = AirframeOperation(id: AirframeID("OP-ATTACH-EVIDENCE"), category: .evidence)
                let decision = AirframeAuthorityEvaluator().evaluate(
                    context: context,
                    operation: operation,
                    targetProjectID: context.targetProjectID
                )
                guard decision.isAllowed else {
                    throw AICockpitCommandError.denied(decision, operation)
                }

                let evidence = AirframeEvidence(
                    id: AirframeID(try parsed.requiredValue(for: "--id")),
                    summary: try parsed.requiredValue(for: "--summary"),
                    artifact: try parsed.requiredValue(for: "--artifact")
                )
                try backend.attachEvidence(evidence, to: AirframeID(parsed.positionals[2]))
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "evidenceAttachment",
                        message: "Evidence attached",
                        workItem: try backend.workRecord(id: AirframeID(parsed.positionals[2]))?.workItem,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: [evidence]
                    ),
                    as: outputFormat
                )
            }
        }

        if parsed.positionals.count == 3 && parsed.positionals[0] == "work" && parsed.positionals[1] == "ready" {
            return executeBackendCommand(outputFormat: outputFormat, parsed: parsed) { backend, context in
                let workItemID = AirframeID(parsed.positionals[2])
                try backend.transitionWorkItem(
                    id: workItemID,
                    to: .implementedNotVerified,
                    context: context,
                    targetProjectID: context.targetProjectID
                )
                let workItem = try backend.workRecord(id: workItemID)?.workItem
                return try render(
                    AICockpitCommandEnvelope(
                        status: "ok",
                        kind: "readyForVerification",
                        message: "Work marked ready for human verification",
                        workItem: workItem,
                        taskPacket: nil,
                        dashboardSummary: nil,
                        evidence: try backend.evidence(for: workItemID)
                    ),
                    as: outputFormat
                )
            }
        }

        return AICockpitCommandResult(
            exitCode: 64,
            standardError: "aicockpit: unknown command\n\n\(helpText())\n"
        )
    }

    public static func helpText() -> String {
        """
        aicockpit

        Agent-facing command interface for Agile Airframe.

        Usage:
          aicockpit --help
          aicockpit version
          aicockpit context
          aicockpit authority demo-denied
          aicockpit project summary [--store path] [--output markdown|json]
          aicockpit task propose --id T-XXXX --title title [--store path]
          aicockpit issue propose --id I-XXXX --title title [--store path]
          aicockpit task next [--store path] [--output markdown|json]
          aicockpit task packet T-XXXX [--store path] [--output markdown|json]
          aicockpit evidence attach T-XXXX --id EV-XXXX --summary text --artifact path [--store path]
          aicockpit work ready T-XXXX [--store path]

        Linked Core:
          \(AirframeCoreInfo.current.summary)
        """
    }

    public static func contextText(for context: AirframeProjectContext) -> String {
        """
        Airframe Context
        \(context.summaryLines.joined(separator: "\n"))
        """
    }

    public static func deniedOperationText(
        decision: AirframeAuthorityDecision,
        operation: AirframeOperation,
        actorID: AirframeID,
        projectID: AirframeID
    ) -> String {
        """
        Airframe Authority Decision
        status: \(decision.isAllowed ? "allowed" : "denied")
        reason: \(decision.reason.rawValue)
        operation: \(operation.id.rawValue)
        category: \(operation.category.rawValue)
        actor: \(actorID.rawValue)
        project: \(projectID.rawValue)
        """
    }

    private static func sampleLLMContext(projectID: AirframeID) throws -> AirframeCertifiedContext {
        let actor = AirframeActor(
            id: AirframeID("ACTOR-LLM"),
            displayName: "AICockpit Agent",
            authorityClass: .llmAgent,
            credentialSource: .cliEnvironment
        )
        let credential = AirframeCredentialContext(
            credentialID: AirframeID("CRED-AICOCKPIT-CLI"),
            actorID: actor.id,
            credentialSource: .cliEnvironment,
            executionProjectID: projectID,
            allowedProjectIDs: [projectID]
        )

        return try AirframeCertifiedContext(
            actor: actor,
            credential: credential,
            targetProjectID: projectID
        )
    }

    private static func executeBackendCommand(
        outputFormat: AICockpitOutputFormat,
        parsed: AICockpitArguments,
        body: (AirframeLocalFilesystemBackend, AirframeCertifiedContext) throws -> String
    ) -> AICockpitCommandResult {
        do {
            let context = try AirframeConfigurationLoader().loadSampleContext()
            let certifiedContext = try sampleLLMContext(projectID: context.project.id)
            let backend = AirframeLocalFilesystemBackend(storeURL: parsed.storeURL)
            return AICockpitCommandResult(
                exitCode: 0,
                standardOutput: try body(backend, certifiedContext)
            )
        } catch AICockpitCommandError.denied(let decision, let operation) {
            return AICockpitCommandResult(
                exitCode: 77,
                standardOutput: deniedOperationText(
                    decision: decision,
                    operation: operation,
                    actorID: AirframeID("ACTOR-LLM"),
                    projectID: AirframeID("PRJ-AIRFRAME")
                )
            )
        } catch AICockpitCommandError.invalidArguments(let message) {
            return AICockpitCommandResult(
                exitCode: 64,
                standardError: "aicockpit: \(message)\n"
            )
        } catch {
            return AICockpitCommandResult(
                exitCode: 78,
                standardError: "aicockpit: \(error)\n"
            )
        }
    }

    private static func render(
        _ envelope: AICockpitCommandEnvelope,
        as outputFormat: AICockpitOutputFormat
    ) throws -> String {
        switch outputFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return String(decoding: try encoder.encode(envelope), as: UTF8.self)
        case .markdown:
            return envelope.markdown
        }
    }
}

private enum AICockpitOutputFormat: String {
    case markdown
    case json
}

private enum AICockpitCommandError: Error, Equatable {
    case invalidArguments(String)
    case denied(AirframeAuthorityDecision, AirframeOperation)
}

private struct AICockpitArguments {
    let positionals: [String]
    private let options: [String: [String]]

    init(_ arguments: [String]) {
        var positionals: [String] = []
        var options: [String: [String]] = [:]
        var index = 0
        while index < arguments.count {
            let argument = arguments[index]
            if argument.hasPrefix("--") {
                if index + 1 < arguments.count && !arguments[index + 1].hasPrefix("--") {
                    options[argument, default: []].append(arguments[index + 1])
                    index += 2
                } else {
                    options[argument, default: []].append("true")
                    index += 1
                }
            } else {
                positionals.append(argument)
                index += 1
            }
        }

        self.positionals = positionals
        self.options = options
    }

    var storeURL: URL {
        if let path = value(for: "--store") {
            return URL(filePath: path)
        }
        return URL(filePath: ".airframe/airframe-local-backend.json")
    }

    func value(for option: String) -> String? {
        options[option]?.last
    }

    func repeatedValues(for option: String) -> [String] {
        options[option] ?? []
    }

    func requiredValue(for option: String) throws -> String {
        guard let value = value(for: option), !value.isEmpty else {
            throw AICockpitCommandError.invalidArguments("missing required option \(option)")
        }
        return value
    }
}

private struct AICockpitCommandEnvelope: Codable, Equatable {
    let status: String
    let kind: String
    let message: String
    let workItem: AirframeWorkItem?
    let taskPacket: AirframeTaskPacket?
    let dashboardSummary: AirframeDashboardSummary?
    let evidence: [AirframeEvidence]

    var markdown: String {
        var lines = [
            "# Airframe Command",
            "",
            "- status: \(status)",
            "- kind: \(kind)",
            "- message: \(message)"
        ]

        if let workItem {
            lines.append(contentsOf: [
                "",
                "## Work Item",
                "- id: \(workItem.id.rawValue)",
                "- kind: \(workItem.kind.rawValue)",
                "- title: \(workItem.title)",
                "- status: \(workItem.status.description)"
            ])
        }

        if let dashboardSummary {
            lines.append(contentsOf: [
                "",
                "## Project Summary",
                "- totalWorkItems: \(dashboardSummary.totalWorkItemCount)",
                "- activeTasks: \(dashboardSummary.activeTaskCount)",
                "- unverifiedTasks: \(dashboardSummary.unverifiedTaskCount)",
                "- verifiedTasks: \(dashboardSummary.verifiedTaskCount)",
                "- issues: \(dashboardSummary.issueCount)",
                "- evidence: \(dashboardSummary.recentEvidenceCount)",
                "- nextTask: \(dashboardSummary.nextTask?.id.rawValue ?? "None")"
            ])
        }

        if let taskPacket {
            lines.append(contentsOf: [
                "",
                "## Task Packet",
                "- objective: \(taskPacket.objective)",
                "",
                "### Scope"
            ])
            lines.append(contentsOf: taskPacket.scope.map { "- \($0)" })
            lines.append("")
            lines.append("### Acceptance Criteria")
            lines.append(contentsOf: taskPacket.acceptanceCriteria.map { "- \($0)" })
            lines.append("")
            lines.append("### Constraints")
            lines.append(contentsOf: taskPacket.constraints.map { "- \($0)" })
            lines.append("")
            lines.append("### Evidence Requirements")
            lines.append(contentsOf: taskPacket.evidenceRequirements.map { "- \($0)" })
            lines.append("")
            lines.append("### Protected Paths")
            lines.append(contentsOf: taskPacket.protectedPaths.isEmpty ? ["- None"] : taskPacket.protectedPaths.map { "- \($0)" })
            lines.append("")
            lines.append("### Report Format")
            lines.append(taskPacket.reportFormat)
        }

        if !evidence.isEmpty {
            lines.append(contentsOf: ["", "## Evidence"])
            lines.append(contentsOf: evidence.map { "- \($0.id.rawValue): \($0.summary) (\($0.artifact))" })
        }

        return lines.joined(separator: "\n")
    }
}
