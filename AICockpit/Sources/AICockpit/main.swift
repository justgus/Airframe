import AICockpitKit
import Foundation

let exitCode = AICockpitCommand.main(arguments: Array(CommandLine.arguments.dropFirst()))
Foundation.exit(exitCode)
