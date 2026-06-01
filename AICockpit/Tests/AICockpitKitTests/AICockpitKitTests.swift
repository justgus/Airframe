import Testing
import AICockpitKit

@Test func helpTextIncludesCommandNameAndCoreIdentity() {
    let help = AICockpitCommand.helpText()

    #expect(help.contains("aicockpit"))
    #expect(help.contains("AirframeCore 0.1.0"))
}

@Test func helpCommandReturnsSuccess() {
    #expect(AICockpitCommand.main(arguments: ["--help"]) == 0)
}

@Test func unknownCommandReturnsUsageError() {
    #expect(AICockpitCommand.main(arguments: ["unknown"]) == 64)
}
