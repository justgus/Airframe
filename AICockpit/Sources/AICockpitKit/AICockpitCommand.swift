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
}
