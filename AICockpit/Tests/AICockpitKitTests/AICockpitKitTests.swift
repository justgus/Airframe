import Testing
import AICockpitKit
import Foundation

@Test func helpTextIncludesCommandNameAndCoreIdentity() {
    let help = AICockpitCommand.helpText()

    #expect(help.contains("aicockpit"))
    #expect(help.contains("AirframeCore 0.1.0"))
    #expect(help.contains("aicockpit context"))
    #expect(help.contains("aicockpit task propose"))
    #expect(help.contains("aicockpit work ready"))
    #expect(help.contains("--backend local-fixture|github-fixture"))
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
    #expect(result.standardOutput.contains("Active Sprint: SP-008"))
}

@Test func deniedAuthorityCommandReturnsReasonCode() {
    let result = AICockpitCommand.response(arguments: ["authority", "demo-denied"])

    #expect(result.exitCode == 77)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("status: denied"))
    #expect(result.standardOutput.contains("reason: authorityClassNotPermitted"))
    #expect(result.standardOutput.contains("operation: OP-ACCEPT-WORK"))
}

@Test func taskProposeCreatesLocalTaskAndMarkdownOutput() {
    let store = temporaryStorePath()

    let result = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--store", store,
        "--id", "T-9001",
        "--title", "Implement command parser",
        "--acceptance", "Parser tests pass",
        "--scope", "AICockpitKit",
        "--constraint", "Keep executable target thin",
        "--evidence-required", "swift test --package-path AICockpit",
        "--protected-path", "docs/Tasks/Verified"
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("kind: taskProposal"))
    #expect(result.standardOutput.contains("id: T-9001"))
    #expect(result.standardOutput.contains("status: Active"))
}

@Test func issueProposeSupportsJSONOutput() {
    let store = temporaryStorePath()

    let result = AICockpitCommand.response(arguments: [
        "issue", "propose",
        "--store", store,
        "--id", "I-9001",
        "--title", "Unexpected local backend failure",
        "--output", "json"
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"kind\" : \"issueProposal\""))
    #expect(result.standardOutput.contains("\"rawValue\" : \"I-9001\""))
}

@Test func taskNextReturnsFirstActiveTask() {
    let store = temporaryStorePath()
    _ = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--store", store,
        "--id", "T-9002",
        "--title", "Implement next task command"
    ])

    let result = AICockpitCommand.response(arguments: [
        "task", "next",
        "--store", store
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("kind: nextTask"))
    #expect(result.standardOutput.contains("id: T-9002"))
}

@Test func taskPacketIncludesRequiredSections() {
    let store = temporaryStorePath()
    _ = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--store", store,
        "--id", "T-9003",
        "--title", "Implement task packet command",
        "--acceptance", "Task packet includes acceptance criteria",
        "--scope", "AICockpitKit",
        "--constraint", "Use AirframeCore packet data",
        "--evidence-required", "AICockpit tests pass"
    ])

    let result = AICockpitCommand.response(arguments: [
        "task", "packet", "T-9003",
        "--store", store
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("## Task Packet"))
    #expect(result.standardOutput.contains("### Acceptance Criteria"))
    #expect(result.standardOutput.contains("Task packet includes acceptance criteria"))
    #expect(result.standardOutput.contains("Use AirframeCore packet data"))
}

@Test func evidenceAttachAndWorkReadyUpdateLocalTask() {
    let store = temporaryStorePath()
    _ = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--store", store,
        "--id", "T-9004",
        "--title", "Implement evidence command"
    ])

    let evidence = AICockpitCommand.response(arguments: [
        "evidence", "attach", "T-9004",
        "--store", store,
        "--id", "EV-9004-001",
        "--summary", "AICockpit tests passed",
        "--artifact", "swift test --package-path AICockpit"
    ])
    let ready = AICockpitCommand.response(arguments: [
        "work", "ready", "T-9004",
        "--store", store,
        "--output", "json"
    ])

    #expect(evidence.exitCode == 0)
    #expect(evidence.standardOutput.contains("Evidence attached"))
    #expect(ready.exitCode == 0)
    #expect(ready.standardOutput.contains("\"kind\" : \"readyForVerification\""))
    #expect(ready.standardOutput.contains("\"status\" : \"implementedNotVerified\""))
    #expect(ready.standardOutput.contains("EV-9004-001"))
}

@Test func githubFixtureBackendWorksThroughCanonicalCommands() {
    let store = temporaryStorePath()
    let proposed = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--backend", "github-fixture",
        "--store", store,
        "--id", "T-9039",
        "--title", "Integrate GitHub backend with AICockpit",
        "--github", "39"
    ])
    let summary = AICockpitCommand.response(arguments: [
        "project", "summary",
        "--backend", "github-fixture",
        "--store", store,
        "--output", "json"
    ])

    #expect(proposed.exitCode == 0)
    #expect(proposed.standardOutput.contains("backend: github-fixture"))
    #expect(proposed.standardOutput.contains("githubIssues: supported"))
    #expect(summary.exitCode == 0)
    #expect(summary.standardOutput.contains("\"backendKind\" : \"github-fixture\""))
    #expect(summary.standardOutput.contains("\"supportsGitHubIssues\" : true"))
    #expect(summary.standardOutput.contains("\"rawValue\" : \"T-9039\""))
}

@Test func missingRequiredOptionReturnsUsageError() {
    let result = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--store", temporaryStorePath(),
        "--id", "T-9005"
    ])

    #expect(result.exitCode == 64)
    #expect(result.standardError.contains("missing required option --title"))
}

private func temporaryStorePath() -> String {
    FileManager.default.temporaryDirectory
        .appending(path: "AICockpitKitTests")
        .appending(path: UUID().uuidString)
        .appending(path: "airframe-local-backend.json")
        .path
}
