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
@Test func agileCockpitAcceptsReadyIssueThroughLocalBackend() throws {
    let context = try AirframeConfigurationLoader().loadSampleContext()
    let storeURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitIssueVerificationStore")
        .appending(path: UUID().uuidString)
        .appending(path: "airframe-local-backend.json")
    let backend = AirframeLocalFilesystemBackend(storeURL: storeURL)
    try backend.createWorkRecord(
        AirframeLocalWorkRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("I-9100"),
                kind: .issue,
                title: "Resolved issue awaiting verification",
                status: .implementedNotVerified,
                githubIssue: 9100
            ),
            epicID: AirframeID("EP-017"),
            sprintID: AirframeID("SP-019"),
            priority: .high
        )
    )
    let model = try AgileCockpitDashboardModel(
        context: context,
        backend: backend,
        reviewerContext: reviewerContext(projectID: context.project.id)
    )

    model.selectedWorkItemID = AirframeID("I-9100")
    model.acceptSelectedWork()

    #expect(model.verifiedRecords.map(\.workItem.id).contains(AirframeID("I-9100")))
    #expect(model.auditRows.last?.action == "OP-HUMAN-ACCEPT-WORK")
    #expect(model.statusMessage.contains("I-9100 accepted"))
}

@MainActor
@Test func agileCockpitAppliesGitHubVerificationWithHumanReviewerContext() throws {
    let configURL = try temporaryLiveConfigurationURL(backendKind: "github-issues")
    let transport = RecordingGitHubIssueTransport(issues: [
        AirframeGitHubIssueRecord(
            number: 59,
            title: "[T-0059] Show live implemented-not-verified work",
            labels: ["airframe-task", "status-unverified", "epic-EP-011", "sprint-SP-011"],
            body: """
            Airframe Type: Task
            Airframe ID: T-0059
            Epic: EP-011
            Sprint: SP-011
            """
        )
    ])
    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:],
        githubIssueTransport: transport
    )

    model.selectedWorkItemID = AirframeID("T-0059")
    model.acceptSelectedWork()

    #expect(model.verifiedRecords.map(\.workItem.id).contains(AirframeID("T-0059")))
    #expect(transport.statusTransitions == [
        RecordingGitHubIssueTransport.StatusTransition(
            issueNumber: 59,
            removedLabels: ["status-unverified"],
            addedLabel: "status-verified"
        )
    ])
    #expect(model.auditRows.last?.action == "OP-HUMAN-ACCEPT-WORK")
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

    #expect(model.statusTiles.map(\.id) == ["epics", "sprints", "tasks", "issues"])
    #expect(model.statusTiles.first { $0.id == "epics" }?.rows.map(\.title) == ["Proposed", "Draft", "Backlog", "Active", "Complete", "Closed"])
    #expect(model.statusTiles.first { $0.id == "sprints" }?.rows.map(\.title) == ["Backlog", "Planning", "Active", "Review", "Closed"])
    #expect(model.statusTiles.first { $0.id == "tasks" }?.rows.map(\.title) == ["Backlog", "Active", "Implemented", "Verified", "Closed"])
    #expect(model.statusTiles.first { $0.id == "issues" }?.rows.first { $0.title == "Backlog" }?.count == 1)
    #expect(model.auditRows.first?.action == "OP-READ-DASHBOARD")
}

@MainActor
@Test func agileCockpitStatusDrillDownDoesNotPreselectWorkItem() throws {
    let model = try AgileCockpitDashboardModel.sample()
    let issueTile = try #require(model.statusTiles.first { $0.id == "issues" })
    let backlogRow = try #require(issueTile.rows.first { $0.title == "Backlog" })

    model.showStatusItems(tile: issueTile, row: backlogRow)

    #expect(model.selectedStatusSelection?.id == backlogRow.id)
    #expect(model.selectedStatusWorkItemID == nil)
    #expect(model.selectedStatusRecord == nil)
}

@MainActor
@Test func agileCockpitStatusDetailShowsFullLocalArtifactFileContents() throws {
    let context = try AirframeConfigurationLoader().loadSampleContext()
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitDetailDocs")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Epics"),
        withIntermediateDirectories: true
    )
    try """
    # Active Epics

    ## EP-017: Workflow Status Dashboard and Mutation Authority

    **Status:** Active
    **Goal:**
    Show the full file contents in the detail pane.

    **Rationale:**
    The detail pane should expose the whole local artifact text.
    """.write(to: rootURL.appending(path: "docs/Epics/Epic-active.md"), atomically: true, encoding: .utf8)

    let backend = AirframeLocalFilesystemBackend(
        storeURL: rootURL.appending(path: "airframe-local-backend.json")
    )
    let model = try AgileCockpitDashboardModel(
        context: context,
        backend: backend,
        reviewerContext: reviewerContext(projectID: context.project.id),
        artifactRootURL: rootURL
    )
    let epicTile = try #require(model.statusTiles.first { $0.id == "epics" })
    let activeRow = try #require(epicTile.rows.first { $0.title == "Active" })

    model.showStatusItems(tile: epicTile, row: activeRow)
    model.selectedStatusWorkItemID = try #require(activeRow.workItems.first?.id)

    #expect(model.selectedStatusDetailText == """
    # Active Epics

    ## EP-017: Workflow Status Dashboard and Mutation Authority

    **Status:** Active
    **Goal:**
    Show the full file contents in the detail pane.

    **Rationale:**
    The detail pane should expose the whole local artifact text.
    """)
}

@MainActor
@Test func agileCockpitStatusDetailUsesIssueArtifactSection() throws {
    let context = try AirframeConfigurationLoader().loadSampleContext()
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitIssueDetailDocs")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Issues"),
        withIntermediateDirectories: true
    )
    try """
    # Active Issues

    ## I-0002: Status drill-down detail pane omits full work product text

    **Status:** Resolved - Not Verified
    **GitHub Issue:** #102
    **Severity:** Medium
    **Epic:** EP-017
    **Sprint:** SP-017

    **Root Cause Analysis:**
    The detail pane was built from a partial field summary.

    **Verification:**
    Confirm the detail pane shows the complete issue section.

    ## I-0003: Status drill-down detail pane uses incomplete fallback text

    **Status:** In Progress
    **GitHub Issue:** #103
    **Severity:** High
    **Epic:** EP-017
    **Sprint:** SP-017

    **Description:**
    This issue should not be included in the I-0002 detail text.
    """.write(to: rootURL.appending(path: "docs/Issues/Issue-active.md"), atomically: true, encoding: .utf8)

    let backend = AirframeLocalFilesystemBackend(
        storeURL: rootURL.appending(path: "airframe-local-backend.json")
    )
    let model = try AgileCockpitDashboardModel(
        context: context,
        backend: backend,
        reviewerContext: reviewerContext(projectID: context.project.id),
        artifactRootURL: rootURL
    )
    let issueTile = try #require(model.statusTiles.first { $0.id == "issues" })
    let resolvedRow = try #require(issueTile.rows.first { $0.title == "Resolved" })

    model.showStatusItems(tile: issueTile, row: resolvedRow)
    model.selectedStatusWorkItemID = AirframeID("I-0002")

    let detailText = try #require(model.selectedStatusDetailText)
    #expect(detailText.contains("## I-0002: Status drill-down detail pane omits full work product text"))
    #expect(detailText.contains("**Root Cause Analysis:**"))
    #expect(detailText.contains("**Verification:**"))
    #expect(!detailText.contains("## I-0003:"))
}

@MainActor
@Test func agileCockpitStatusDetailUsesTaskArtifactSection() throws {
    let context = try AirframeConfigurationLoader().loadSampleContext()
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitTaskDetailDocs")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Tasks"),
        withIntermediateDirectories: true
    )
    try """
    # Task Backlog

    ## T-0091: Define AICockpit work item mutation command contract

    **Status:** Backlog
    **GitHub Issue:** #91
    **Priority:** High
    **Epic:** EP-017
    **Sprint Assigned:** SP-018

    **Acceptance Criteria:**
    1. Commands are defined for creating and updating work items.

    **Evidence:**
    - TBD

    ## T-0092: Implement AICockpit local work item mutation support

    **Status:** Backlog
    **GitHub Issue:** #92
    **Priority:** High
    **Epic:** EP-017
    **Sprint Assigned:** SP-018

    **Acceptance Criteria:**
    1. Local mutation support is implemented.
    """.write(to: rootURL.appending(path: "docs/Tasks/Task-backlog.md"), atomically: true, encoding: .utf8)

    let backend = AirframeLocalFilesystemBackend(
        storeURL: rootURL.appending(path: "airframe-local-backend.json")
    )
    let model = try AgileCockpitDashboardModel(
        context: context,
        backend: backend,
        reviewerContext: reviewerContext(projectID: context.project.id),
        artifactRootURL: rootURL
    )
    let taskTile = try #require(model.statusTiles.first { $0.id == "tasks" })
    let backlogRow = try #require(taskTile.rows.first { $0.title == "Backlog" })

    model.showStatusItems(tile: taskTile, row: backlogRow)
    model.selectedStatusWorkItemID = AirframeID("T-0091")

    let detailText = try #require(model.selectedStatusDetailText)
    #expect(detailText.contains("## T-0091: Define AICockpit work item mutation command contract"))
    #expect(detailText.contains("**Acceptance Criteria:**"))
    #expect(detailText.contains("**Evidence:**"))
    #expect(!detailText.contains("## T-0092:"))
}

@MainActor
@Test func agileCockpitStatusDetailUsesVerifiedTaskBatchArtifact() throws {
    let context = try AirframeConfigurationLoader().loadSampleContext()
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitVerifiedTaskDetailDocs")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Tasks/Verified"),
        withIntermediateDirectories: true
    )
    try """
    # T-0081 through T-0085: SP-016 Refresh Synchronization

    **Status:** Implemented - Verified
    **Sprint:** SP-016
    **Epic:** EP-016

    | Task | GitHub Issue | Title | Status |
    | ---- | ------------ | ----- | ------ |
    | T-0081 | #81 | Define refresh synchronization contract | Implemented - Verified |
    | T-0082 | #82 | Add shared refresh notification primitive | Implemented - Verified |

    ## Verification Evidence

    - Focused tests passed.
    """.write(to: rootURL.appending(path: "docs/Tasks/Verified/Task-verified-0081-0085.md"), atomically: true, encoding: .utf8)

    let backend = AirframeLocalFilesystemBackend(
        storeURL: rootURL.appending(path: "airframe-local-backend.json")
    )
    let model = try AgileCockpitDashboardModel(
        context: context,
        backend: backend,
        reviewerContext: reviewerContext(projectID: context.project.id),
        artifactRootURL: rootURL
    )
    let taskTile = try #require(model.statusTiles.first { $0.id == "tasks" })
    let verifiedRow = try #require(taskTile.rows.first { $0.title == "Verified" })

    model.showStatusItems(tile: taskTile, row: verifiedRow)
    model.selectedStatusWorkItemID = AirframeID("T-0081")

    let detailText = try #require(model.selectedStatusDetailText)
    #expect(verifiedRow.workItems.map(\.id).contains(AirframeID("T-0081")))
    #expect(detailText.contains("# T-0081 through T-0085: SP-016 Refresh Synchronization"))
    #expect(detailText.contains("## Verification Evidence"))
}

@MainActor
@Test func agileCockpitStatusTilesIncludeLocalEpicAndSprintArtifacts() throws {
    let context = try AirframeConfigurationLoader().loadSampleContext()
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitArtifactDocs")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Epics"),
        withIntermediateDirectories: true
    )
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Sprints"),
        withIntermediateDirectories: true
    )
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Epics/Closed"),
        withIntermediateDirectories: true
    )
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Sprints/Closed"),
        withIntermediateDirectories: true
    )
    try """
    # Active Epics

    ## EP-017: Workflow Status Dashboard and Mutation Authority

    **Status:** Active
    """.write(to: rootURL.appending(path: "docs/Epics/Epic-active.md"), atomically: true, encoding: .utf8)
    try """
    # Sprint Backlog

    ## SP-018: AICockpit Work Item Mutation Support

    **Status:** Backlog
    **Epic:** EP-017: Workflow Status Dashboard and Mutation Authority

    ## SP-019: AgileCockpit Human Verification Mutations

    **Status:** Backlog
    **Epic:** EP-017: Workflow Status Dashboard and Mutation Authority
    """.write(to: rootURL.appending(path: "docs/Sprints/Sprint-backlog.md"), atomically: true, encoding: .utf8)
    try """
    # Active Sprint

    ## SP-017: Workflow Status Dashboard

    **Status:** Active
    **Epic:** EP-017: Workflow Status Dashboard and Mutation Authority
    """.write(to: rootURL.appending(path: "docs/Sprints/Sprint-active.md"), atomically: true, encoding: .utf8)
    try """
    # EP-016: Refresh Synchronization

    **Status:** Closed
    """.write(to: rootURL.appending(path: "docs/Epics/Closed/Epic-EP-016.md"), atomically: true, encoding: .utf8)
    try """
    # SP-016: Refresh Synchronization

    **Status:** Closed
    **Epic:** EP-016: Refresh Synchronization
    """.write(to: rootURL.appending(path: "docs/Sprints/Closed/Sprint-SP-016.md"), atomically: true, encoding: .utf8)

    let backend = AirframeLocalFilesystemBackend(
        storeURL: rootURL.appending(path: "airframe-local-backend.json")
    )
    let model = try AgileCockpitDashboardModel(
        context: context,
        backend: backend,
        reviewerContext: reviewerContext(projectID: context.project.id),
        artifactRootURL: rootURL
    )

    #expect(model.statusTiles.first { $0.id == "epics" }?.rows.first { $0.title == "Active" }?.count == 1)
    #expect(model.statusTiles.first { $0.id == "epics" }?.rows.first { $0.title == "Closed" }?.count == 1)
    #expect(model.statusTiles.first { $0.id == "sprints" }?.rows.first { $0.title == "Active" }?.count == 1)
    #expect(model.statusTiles.first { $0.id == "sprints" }?.rows.first { $0.title == "Backlog" }?.count == 2)
    #expect(model.statusTiles.first { $0.id == "sprints" }?.rows.first { $0.title == "Closed" }?.count == 1)
}

@MainActor
@Test func agileCockpitLoadsEpicAcceptanceCriteriaAndCloseEligibilityFromLocalArtifacts() throws {
    let configURL = try temporaryLiveConfigurationURL(
        activeSprintID: "SP-020",
        activeEpicID: "EP-018",
        backendKind: "local-fixture"
    )
    let rootURL = configURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Epics"),
        withIntermediateDirectories: true
    )
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Sprints"),
        withIntermediateDirectories: true
    )
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Tasks"),
        withIntermediateDirectories: true
    )
    try """
    # Active Epics

    ## EP-018: AgileCockpit Sprint and Epic Status Controls

    **Status:** Active

    **Acceptance Criteria:**
    1. [x] AgileCockpit shows Epic acceptance criteria in a dedicated panel.
    2. [ ] A Sprint close action is enabled only after all Sprint Tasks and Issues are verified.
    3. An Epic complete or close action is enabled only after all Epic acceptance criteria are verified.
    """.write(to: rootURL.appending(path: "docs/Epics/Epic-active.md"), atomically: true, encoding: .utf8)
    try """
    # Active Sprint

    ## SP-020: Epic Acceptance-Criteria Model and Eligibility

    **Status:** Active
    **Epic:** EP-018: AgileCockpit Sprint and Epic Status Controls
    """.write(to: rootURL.appending(path: "docs/Sprints/Sprint-active.md"), atomically: true, encoding: .utf8)
    try """
    # Active Tasks

    ## T-0101: Define Epic acceptance criteria verification model

    **Status:** Active
    **GitHub Issue:** #105
    **Priority:** High
    **Epic:** EP-018
    **Sprint Assigned:** SP-020

    **Acceptance Criteria:**
    1. The model can represent Epic acceptance criteria as individual verifiable items.

    ## T-0102: Extend planning model for Epic and Sprint close eligibility

    **Status:** Implemented - Verified
    **GitHub Issue:** #106
    **Priority:** High
    **Epic:** EP-018
    **Sprint Assigned:** SP-020
    """.write(to: rootURL.appending(path: "docs/Tasks/Task-active.md"), atomically: true, encoding: .utf8)

    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:]
    )
    let criteriaSummary = try #require(model.epicAcceptanceCriteriaSummary)
    let sprintEligibility = try #require(model.sprintCloseEligibility)
    let epicEligibility = try #require(model.epicCloseEligibility)

    #expect(criteriaSummary.totalCount == 3)
    #expect(criteriaSummary.verifiedCount == 1)
    #expect(criteriaSummary.criteria.map(\.text).first == "AgileCockpit shows Epic acceptance criteria in a dedicated panel.")
    #expect(model.sprintRecords.map(\.workItem.id) == [AirframeID("T-0101"), AirframeID("T-0102")])
    #expect(!sprintEligibility.eligibility.isEligible)
    #expect(sprintEligibility.blockingWorkItems.map(\.id) == [AirframeID("T-0101")])
    #expect(!epicEligibility.eligibility.isEligible)
    #expect(epicEligibility.eligibility.blockingReasons.contains("EP-018-AC-02 is not verified."))
}

private func temporaryLiveConfigurationURL(backendKind: String = "github-fixture") throws -> URL {
    try temporaryLiveConfigurationURL(
        activeSprintID: "SP-011",
        activeEpicID: "EP-011",
        backendKind: backendKind
    )
}

private func temporaryLiveConfigurationURL(
    activeSprintID: String,
    activeEpicID: String,
    backendKind: String = "github-fixture"
) throws -> URL {
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitLiveConfig")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    let configURL = rootURL.appending(path: "airframe-workspace.json")
    try liveConfigurationData(
        activeSprintID: activeSprintID,
        activeEpicID: activeEpicID,
        backendKind: backendKind
    ).write(to: configURL)
    return configURL
}

private func liveConfigurationData(backendKind: String) -> Data {
    liveConfigurationData(activeSprintID: "SP-011", activeEpicID: "EP-011", backendKind: backendKind)
}

private func liveConfigurationData(
    activeSprintID: String,
    activeEpicID: String,
    backendKind: String
) -> Data {
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
              "activeSprintID": { "rawValue": "\(activeSprintID)" },
              "activeEpicID": { "rawValue": "\(activeEpicID)" }
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

private final class RecordingGitHubIssueTransport: @unchecked Sendable, AirframeGitHubIssueTransport {
    struct StatusTransition: Equatable {
        let issueNumber: Int
        let removedLabels: [String]
        let addedLabel: String
    }

    private var issues: [AirframeGitHubIssueRecord]
    private(set) var statusTransitions: [StatusTransition] = []

    init(issues: [AirframeGitHubIssueRecord]) {
        self.issues = issues
    }

    func listIssues(configuration: AirframeGitHubBackendConfiguration) throws -> [AirframeGitHubIssueRecord] {
        issues
    }

    func issue(number: Int, configuration: AirframeGitHubBackendConfiguration) throws -> AirframeGitHubIssueRecord {
        guard let issue = issues.first(where: { $0.number == number }) else {
            throw AirframeBackendError.githubAccessFailed("missing stub issue #\(number)")
        }
        return issue
    }

    func replaceStatusLabel(
        issueNumber: Int,
        removing oldStatusLabels: [String],
        adding newStatusLabel: String,
        configuration: AirframeGitHubBackendConfiguration
    ) throws {
        statusTransitions.append(
            StatusTransition(
                issueNumber: issueNumber,
                removedLabels: oldStatusLabels,
                addedLabel: newStatusLabel
            )
        )
        guard let index = issues.firstIndex(where: { $0.number == issueNumber }) else {
            throw AirframeBackendError.githubAccessFailed("missing stub issue #\(issueNumber)")
        }
        let issue = issues[index]
        let labels = issue.labels.filter { !oldStatusLabels.contains($0) } + [newStatusLabel]
        issues[index] = AirframeGitHubIssueRecord(
            number: issue.number,
            title: issue.title,
            state: issue.state,
            labels: labels,
            body: issue.body
        )
    }
}
