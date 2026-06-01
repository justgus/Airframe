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
}
