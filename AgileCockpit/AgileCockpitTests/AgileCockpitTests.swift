import Testing
import AirframeCore
import Foundation
@testable import AgileCockpit

@Test func agileCockpitLinksAirframeCore() {
    #expect(AirframeCoreInfo.current.summary == "AirframeCore 0.1.0")
}

@MainActor
@Test func agileCockpitSampleDashboardContextIsAvailable() throws {
    let model = try AgileCockpitDashboardModel.sample()

    #expect(model.context.workspaceName == "Airframe")
    #expect(model.context.projectName == "Agile Airframe")
    #expect(model.context.project.activeSprintID == nil)
    #expect(model.context.project.activeEpicID == nil)
    #expect(model.projectStatusText.contains("justgus/Airframe"))
    #expect(model.backendStatusText.contains("github-fixture"))
    #expect(model.backendStatusText.contains("GitHub issue mapping on"))
    #expect(model.configurationDiagnostics.status == .ok)
    #expect(model.configurationStatusText == "Configuration ok | 1 project(s)")
}

@MainActor
@Test func agileCockpitConfiguredDashboardUsesLiveProjectContext() throws {
    let configURL = try temporaryLiveConfigurationURL()
    let storeURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitLiveStore")
        .appending(path: UUID().uuidString)
        .appending(path: "airframe-local-backend.json")
    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        storeURL: storeURL,
        environment: [:]
    )

    #expect(model.context.workspaceName == "Airframe Live Demo")
    #expect(model.context.project.activeSprintID == AirframeID("SP-011"))
    #expect(model.context.project.activeEpicID == AirframeID("EP-011"))
    #expect(model.projectStatusText.contains("justgus/Airframe"))
    #expect(model.backendStatusText.contains("github-fixture"))
    #expect(model.configurationDiagnostics.status == .ok)
    #expect(model.statusMessage == "Loaded github-fixture Airframe workspace.")
}

@MainActor
@Test func agileCockpitConfiguredDashboardUsesGitHubIssuesBackend() throws {
    let configURL = try temporaryLiveConfigurationURL(backendKind: "github-issues")
    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:],
        githubIssueTransport: StubGitHubIssueTransport(issues: liveGitHubIssues)
    )

    #expect(model.context.workspaceName == "Airframe Live Demo")
    #expect(model.context.project.activeSprintID == AirframeID("SP-011"))
    #expect(model.context.project.activeEpicID == AirframeID("EP-011"))
    #expect(model.projectStatusText.contains("justgus/Airframe"))
    #expect(model.backendStatusText.contains("github-issues"))
    #expect(model.statusMessage == "Loaded github-issues Airframe workspace.")
    #expect(model.summary.activeTaskCount == 1)
    #expect(model.summary.unverifiedTaskCount == 1)
    #expect(model.readyRecords.map(\.workItem.id) == [AirframeID("T-0059")])
    #expect(model.sprintRecords.map(\.workItem.id) == [AirframeID("T-0056"), AirframeID("T-0059")])
    #expect(model.epicRecords.map(\.workItem.id) == [AirframeID("T-0056"), AirframeID("T-0059")])
}

@MainActor
@Test func agileCockpitLiveFailurePreservesProjectIdentityWithoutSampleFallback() throws {
    let context = try AirframeConfigurationLoader().context(
        for: try AirframeConfigurationLoader().load(data: liveConfigurationData(backendKind: "github-issues"))
    )
    let model = AgileCockpitDashboardModel.unavailable(
        context: context,
        error: AirframeBackendError.githubAccessFailed("gh authentication required")
    )

    #expect(model.context.workspaceName == "Airframe Live Demo")
    #expect(model.projectStatusText.contains("justgus/Airframe"))
    #expect(model.backendStatusText.contains("github-issues"))
    #expect(model.statusMessage.contains("Live project load failed"))
    #expect(model.statusMessage.contains("gh authentication required"))
    #expect(model.records.isEmpty)
    #expect(model.summary.totalWorkItemCount == 0)
}

@MainActor
@Test func agileCockpitBuildsDashboardSectionsFromCoreBackend() throws {
    let model = try AgileCockpitDashboardModel.sample()

    #expect(model.summary.activeTaskCount == 1)
    #expect(model.summary.unverifiedTaskCount == 1)
    #expect(model.summary.verifiedTaskCount == 1)
    #expect(model.summary.nextTask?.id == AirframeID("T-0041"))
    #expect(model.readyRecords.map(\.workItem.id).contains(AirframeID("T-0042")))
    #expect(model.upcomingRecords.map(\.workItem.id).contains(AirframeID("T-0045")))
    #expect(model.statusMessage == "Loaded github-fixture Airframe workspace.")
}

@MainActor
@Test func agileCockpitExposesVerificationPacketEvidenceAndActions() throws {
    let model = try AgileCockpitDashboardModel.sample()

    model.selectedWorkItemID = AirframeID("T-0042")

    #expect(model.selectedPacket?.workItem.id == AirframeID("T-0042"))
    #expect(model.selectedPacket?.existingEvidence.first?.id == AirframeID("EV-0042-001"))

    model.requestMoreEvidenceForSelectedWork()

    #expect(model.summary.unverifiedTaskCount == 0)
    #expect(model.activeRecords.map(\.workItem.id).contains(AirframeID("T-0042")))
    #expect(model.auditRows.last?.action == "OP-HUMAN-REQUEST-EVIDENCE")
}

@MainActor
@Test func agileCockpitAcceptsReadyWorkThroughCoreBackend() throws {
    let model = try AgileCockpitDashboardModel.sample()

    model.selectedWorkItemID = AirframeID("T-0042")
    model.acceptSelectedWork()

    #expect(model.verifiedRecords.map(\.workItem.id).contains(AirframeID("T-0042")))
    #expect(model.summary.verifiedTaskCount == 2)
    #expect(model.statusMessage.contains("T-0042 accepted"))
}

@MainActor
@Test func agileCockpitRefreshesFromBackendSourceOfTruth() throws {
    let context = try AirframeConfigurationLoader().context(
        for: try AirframeConfigurationLoader().load(data: liveConfigurationData(backendKind: "local-fixture"))
    )
    let storeURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitRefreshStore")
        .appending(path: UUID().uuidString)
        .appending(path: "airframe-local-backend.json")
    let backend = AirframeLocalFilesystemBackend(storeURL: storeURL)
    let firstRecord = localTaskRecord(id: "T-9100", title: "Initial refresh task")
    try backend.createWorkRecord(firstRecord)

    let model = try AgileCockpitDashboardModel(
        context: context,
        backend: backend,
        reviewerContext: reviewerContext(projectID: context.project.id)
    )

    #expect(model.activeRecords.map(\.workItem.id) == [AirframeID("T-9100")])

    try backend.createWorkRecord(localTaskRecord(id: "T-9101", title: "External refresh task"))
    model.refreshFromExternalChange()

    #expect(model.activeRecords.map(\.workItem.id) == [AirframeID("T-9100"), AirframeID("T-9101")])
    #expect(model.statusMessage == "Refreshed from Airframe state.")
}

@MainActor
@Test func agileCockpitShowsSprintEpicMetricsAndAuditRows() throws {
    let model = try AgileCockpitDashboardModel.sample()

    #expect(model.sprintRecords.count == 0)
    #expect(model.epicRecords.count == 0)
    #expect(model.metrics.map(\.id) == ["active", "ready", "verified", "issues", "evidence"])
    #expect(model.auditRows.first?.action == "OP-READ-DASHBOARD")
}

private func temporaryLiveConfigurationURL(backendKind: String = "github-fixture") throws -> URL {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitLiveConfig")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    let configURL = rootURL.appending(path: "airframe-workspace.json")
    try liveConfigurationData(backendKind: backendKind).write(to: configURL)
    return configURL
}

private func liveConfigurationData(backendKind: String) -> Data {
    Data(
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
              "activeSprintID": { "rawValue": "SP-011" },
              "activeEpicID": { "rawValue": "EP-011" }
            }
          ],
          "defaultProjectID": { "rawValue": "PRJ-AIRFRAME" },
          "backend": {
            "kind": "\(backendKind)",
            "location": "justgus/Airframe"
          }
        }
        """.utf8
    )
}

private func reviewerContext(projectID: AirframeID) throws -> AirframeCertifiedContext {
    let actor = AirframeActor(
        id: AirframeID("ACTOR-REFRESH-TESTER"),
        displayName: "Refresh Tester",
        authorityClass: .humanReviewer,
        credentialSource: .xcodeSession
    )
    let credential = AirframeCredentialContext(
        credentialID: AirframeID("CRED-REFRESH-TESTER"),
        actorID: actor.id,
        credentialSource: .xcodeSession,
        executionProjectID: projectID,
        allowedProjectIDs: [projectID]
    )
    return try AirframeCertifiedContext(actor: actor, credential: credential, targetProjectID: projectID)
}

private func localTaskRecord(id: String, title: String) -> AirframeLocalWorkRecord {
    AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID(id),
            kind: .task,
            title: title,
            status: .active,
            githubIssue: Int(id.dropFirst(2))
        ),
        epicID: AirframeID("EP-016"),
        sprintID: AirframeID("SP-016"),
        priority: .high,
        acceptanceCriteria: ["Refresh state is loaded from the backend."],
        scope: ["AgileCockpit"],
        constraints: ["Do not trust notification payloads as state."],
        evidenceRequirements: ["AgileCockpit refresh test passes."]
    )
}

private let liveGitHubIssues = [
    AirframeGitHubIssueRecord(
        number: 56,
        title: "[T-0056] Wire AgileCockpit live backend configuration",
        labels: ["airframe-task", "status-active", "epic-EP-011", "sprint-SP-011"],
        body: """
        Airframe Type: Task
        Airframe ID: T-0056
        Epic: EP-011
        Sprint: SP-011

        ## Acceptance Criteria
        - AgileCockpit launched in live mode displays repository justgus/Airframe.
        """
    ),
    AirframeGitHubIssueRecord(
        number: 59,
        title: "[T-0059] Show live implemented-not-verified work",
        labels: ["airframe-task", "status-unverified", "epic-EP-011", "sprint-SP-011"],
        body: """
        Airframe Type: Task
        Airframe ID: T-0059
        Epic: EP-011
        Sprint: SP-011

        ## Acceptance Criteria
        - Live implemented-not-verified mapped work appears in the verification view when present.
        """
    ),
    AirframeGitHubIssueRecord(
        number: 99,
        title: "Unmapped GitHub issue",
        labels: [],
        body: ""
    )
]

private struct StubGitHubIssueTransport: AirframeGitHubIssueTransport {
    let issues: [AirframeGitHubIssueRecord]

    func listIssues(configuration: AirframeGitHubBackendConfiguration) throws -> [AirframeGitHubIssueRecord] {
        issues
    }

    func issue(number: Int, configuration: AirframeGitHubBackendConfiguration) throws -> AirframeGitHubIssueRecord {
        guard let issue = issues.first(where: { $0.number == number }) else {
            throw AirframeBackendError.githubAccessFailed("missing stub issue #\(number)")
        }
        return issue
    }
}
