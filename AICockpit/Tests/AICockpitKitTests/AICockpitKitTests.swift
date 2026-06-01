import Testing
import AICockpitKit

@Test func helpTextIncludesCommandNameAndCoreIdentity() {
    let help = AICockpitCommand.helpText()

    #expect(help.contains("aicockpit"))
    #expect(help.contains("AirframeCore 0.1.0"))
    #expect(help.contains("aicockpit context"))
}

@Test func helpCommandReturnsSuccess() {
    #expect(AICockpitCommand.main(arguments: ["--help"]) == 0)
}

@Test func unknownCommandReturnsUsageError() {
    #expect(AICockpitCommand.main(arguments: ["unknown"]) == 64)
}

@Test func contextCommandReturnsCurrentProjectContext() {
    let result = AICockpitCommand.response(arguments: ["context"])

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("Airframe Context"))
    #expect(result.standardOutput.contains("Workspace: Airframe (WS-AIRFRAME)"))
    #expect(result.standardOutput.contains("Project: Agile Airframe (PRJ-AIRFRAME)"))
    #expect(result.standardOutput.contains("Active Sprint: SP-002"))
}
