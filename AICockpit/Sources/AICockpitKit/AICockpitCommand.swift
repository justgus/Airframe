import AirframeCore
import Foundation

public enum AICockpitCommand {
    public static func main(arguments: [String]) -> Int32 {
        if arguments.isEmpty || arguments.contains("--help") || arguments.contains("-h") {
            print(helpText())
            return 0
        }

        if arguments == ["version"] || arguments == ["--version"] {
            print(AirframeCoreInfo.current.summary)
            return 0
        }

        fputs("aicockpit: unknown command\n\n\(helpText())\n", stderr)
        return 64
    }

    public static func helpText() -> String {
        """
        aicockpit

        Agent-facing command interface for Agile Airframe.

        Usage:
          aicockpit --help
          aicockpit version

        Linked Core:
          \(AirframeCoreInfo.current.summary)
        """
    }
}
