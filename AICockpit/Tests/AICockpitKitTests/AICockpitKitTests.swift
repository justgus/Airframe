import Testing
import AICockpitKit
import Foundation

@Test func helpTextIncludesCommandNameAndCoreIdentity() {
    let help = AICockpitCommand.helpText()

    #expect(help.contains("aicockpit"))
    #expect(help.contains("AirframeCore 0.1.0"))
    #expect(help.contains("aicockpit context"))
    #expect(help.contains("aicockpit config diagnose"))
    #expect(help.contains("aicockpit task propose"))
    #expect(help.contains("aicockpit work ready"))
    #expect(help.contains("--backend local-fixture|github-fixture|github-issues"))
}

@Test func configDiagnoseReturnsStableMarkdownContract() {
    let result = AICockpitCommand.response(arguments: ["config", "diagnose"])

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("kind: configurationDiagnostics"))
    #expect(result.standardOutput.contains("## Configuration Diagnostics"))
    #expect(result.standardOutput.contains("status: ok"))
    #expect(result.standardOutput.contains("backend: github-fixture at justgus/Airframe"))
    #expect(result.standardOutput.contains("issues: None"))
}

@Test func configDiagnoseReturnsStableJSONContract() {
    let result = AICockpitCommand.response(arguments: ["config", "diagnose", "--output", "json"])

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"kind\" : \"configurationDiagnostics\""))
    #expect(result.standardOutput.contains("\"configurationDiagnostics\""))
    #expect(result.standardOutput.contains("\"backendKind\" : \"github-fixture\""))
    #expect(result.standardOutput.contains("\"status\" : \"ok\""))
}

@Test func helpCommandReturnsSuccess() {
    #expect(AICockpitCommand.main(arguments: ["--help"]) == 0)
}

@Test func unknownCommandReturnsUsageError() {
    #expect(AICockpitCommand.main(arguments: ["unknown"]) == 64)
}

@Test func unknownCommandReturnsJSONErrorEnvelope() {
    let result = AICockpitCommand.response(arguments: ["unknown", "--output", "json"])

    #expect(result.exitCode == 64)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"status\" : \"error\""))
    #expect(result.standardOutput.contains("\"code\" : \"unknownCommand\""))
    #expect(result.standardOutput.contains("\"message\" : \"unknown command\""))
}

@Test func contextCommandReturnsCurrentProjectContext() {
    let result = AICockpitCommand.response(arguments: ["context"])

    #expect(result.exitCode == 0)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("Airframe Context"))
    #expect(result.standardOutput.contains("Workspace: Airframe (WS-AIRFRAME)"))
    #expect(result.standardOutput.contains("Project: Agile Airframe (PRJ-AIRFRAME)"))
    #expect(result.standardOutput.contains("Active Sprint: None"))
}

@Test func contextCommandSupportsExplicitRuntimeConfiguration() throws {
    let config = try temporaryLiveConfigurationPath()

    let result = AICockpitCommand.response(arguments: [
        "context",
        "--config", config
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("Workspace: Airframe Live Demo (WS-AIRFRAME-LIVE)"))
    #expect(result.standardOutput.contains("Project: Agile Airframe (PRJ-AIRFRAME)"))
    #expect(result.standardOutput.contains("Repository: justgus/Airframe"))
    #expect(result.standardOutput.contains("Active Epic: EP-009"))
    #expect(result.standardOutput.contains("Active Sprint: SP-009"))
}

@Test func configDiagnoseSupportsExplicitRuntimeConfiguration() throws {
    let config = try temporaryLiveConfigurationPath()

    let result = AICockpitCommand.response(arguments: [
        "config", "diagnose",
        "--config", config,
        "--output", "json"
    ])

    #expect(result.exitCode == 0)
    #expect(result.standardOutput.contains("\"workspaceID\" : {"))
    #expect(result.standardOutput.contains("\"rawValue\" : \"WS-AIRFRAME-LIVE\""))
    #expect(result.standardOutput.contains("\"backendKind\" : \"github-fixture\""))
    #expect(result.standardOutput.contains("\"backendLocation\" : \"justgus\\/Airframe\""))
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

@Test func githubIssuesBackendRejectsMutatingCommandsThroughAICockpit() {
    let result = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--backend", "github-issues",
        "--id", "T-9054",
        "--title", "Attempt read-only mutation",
        "--output", "json"
    ])

    #expect(result.exitCode == 78)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"code\" : \"backendCommandFailed\""))
    #expect(result.standardOutput.contains("read-only"))
    #expect(result.standardOutput.contains("work item creation"))
}

@Test func taskProposalUsesRuntimeConfigSprintEpicDefaultsAndStore() throws {
    let config = try temporaryLiveConfigurationPath()
    let store = temporaryStorePath()
    let proposed = AICockpitCommand.response(arguments: [
        "task", "propose",
        "--config", config,
        "--store", store,
        "--id", "T-9047",
        "--title", "Use runtime config defaults"
    ])
    let packet = AICockpitCommand.response(arguments: [
        "task", "packet", "T-9047",
        "--config", config,
        "--store", store
    ])

    #expect(proposed.exitCode == 0)
    #expect(packet.exitCode == 0)
    #expect(packet.standardOutput.contains("Use runtime config defaults"))
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

@Test func invalidBackendReturnsJSONErrorEnvelope() {
    let result = AICockpitCommand.response(arguments: [
        "project", "summary",
        "--backend", "unknown-backend",
        "--output", "json"
    ])

    #expect(result.exitCode == 64)
    #expect(result.standardError.isEmpty)
    #expect(result.standardOutput.contains("\"status\" : \"error\""))
    #expect(result.standardOutput.contains("\"code\" : \"invalidArguments\""))
    #expect(result.standardOutput.contains("unsupported backend unknown-backend"))
}

private func temporaryStorePath() -> String {
    FileManager.default.temporaryDirectory
        .appending(path: "AICockpitKitTests")
        .appending(path: UUID().uuidString)
        .appending(path: "airframe-local-backend.json")
        .path
}

private func temporaryLiveConfigurationPath() throws -> String {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AICockpitLiveConfig")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    let configURL = rootURL.appending(path: "airframe-workspace.json")
    try Data(
        """
        {
          "schemaVersion": 1,
          "workspace": {
            "id": { "rawValue": "WS-AIRFRAME-LIVE" },
            "name": "Airframe Live Demo",
            "rootPath": "."
          },
          "projects": [
            {
              "id": { "rawValue": "PRJ-AIRFRAME" },
              "name": "Agile Airframe",
              "repository": "justgus/Airframe",
              "activeSprintID": { "rawValue": "SP-009" },
              "activeEpicID": { "rawValue": "EP-009" }
            }
          ],
          "defaultProjectID": { "rawValue": "PRJ-AIRFRAME" },
          "backend": {
            "kind": "github-fixture",
            "location": "justgus/Airframe"
          }
        }
        """.utf8
    ).write(to: configURL)
    return configURL.path
}
