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
    #expect(model.appStatusText == "Agile Cockpit | Airframe")
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
    #expect(model.appStatusText == "Agile Cockpit | Airframe Live Demo")
    #expect(model.backendStatusText.contains("github-fixture"))
    #expect(model.configurationDiagnostics.status == .ok)
    #expect(model.statusMessage == "Loaded github-fixture Airframe workspace.")
}

@MainActor
@Test func agileCockpitPlanningNavigationIncludesDedicatedEpicCriteriaTab() throws {
    let configURL = try temporaryLiveConfigurationURL()
    let storeURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitPlanningTabs")
        .appending(path: UUID().uuidString)
        .appending(path: "airframe-local-backend.json")
    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        storeURL: storeURL,
        environment: [:]
    )

    #expect(AgileCockpitPlanningTab.allCases.map(\.rawValue) == ["Sprint Work", "Epic Criteria", "Epic Work"])
    #expect(AgileCockpitPlanningTab.epicCriteria.accessibilityID == "epic-criteria")
    #expect(model.selectedPlanningTab == .sprintWork)

    model.selectedPlanningTab = .epicCriteria

    #expect(model.selectedPlanningTab == .epicCriteria)
}

@MainActor
@Test func agileCockpitMarksEpicCriterionVerifiedInMarkdownChecklist() throws {
    let contents = """
    # Active Epics

    ## EP-018: AgileCockpit Sprint and Epic Status Controls

    **Status:** Active

    **Acceptance Criteria:**
    1. [x] Existing verified criterion.
    2. [ ] Criterion to verify.
    3. Criterion without checkbox.
    """

    let updated = try AgileCockpitDashboardModel.markEpicAcceptanceCriterionVerified(
        AirframeID("EP-018-AC-02"),
        epicID: AirframeID("EP-018"),
        in: contents
    )

    #expect(updated.contains("2. [x] Criterion to verify."))
    #expect(updated.contains("1. [x] Existing verified criterion."))
}

@MainActor
@Test func agileCockpitVerifiesSelectedEpicCriterionThroughCanonicalState() throws {
    let configURL = try temporaryLiveConfigurationURL(
        activeSprintID: "SP-021",
        activeEpicID: "EP-018",
        backendKind: "local-fixture"
    )
    let rootURL = configURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Epics"),
        withIntermediateDirectories: true
    )
    try """
    # Active Epics

    ## EP-018: AgileCockpit Sprint and Epic Status Controls

    **Status:** Active

    **Acceptance Criteria:**
    1. [ ] AgileCockpit shows Epic acceptance criteria in a dedicated tab.
    2. [ ] A human can mark Epic acceptance criteria verified in the UI.
    """.write(to: rootURL.appending(path: "docs/Epics/Epic-active.md"), atomically: true, encoding: .utf8)
    try importMarkdownFixturesIntoCanonicalState(rootURL: rootURL, configURL: configURL)

    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:]
    )
    let criterion = try #require(model.epicAcceptanceCriteriaSummary?.criteria.first)

    model.selectEpicAcceptanceCriterion(criterion)
    model.verifySelectedEpicAcceptanceCriterion()

    let state = try AirframeCanonicalStoreRepository(rootURL: rootURL).loadState()
    #expect(state.acceptanceCriteria.first?.isVerified == true)
    #expect(model.epicAcceptanceCriteriaSummary?.verifiedCount == 1)
    #expect(model.auditRows.last?.action == "OP-HUMAN-VERIFY-EPIC-CRITERION")
    #expect(model.statusMessage == "EP-018-AC-01 verified.")
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
    #expect(model.appStatusText == "Agile Cockpit | Airframe Live Demo")
    #expect(model.backendStatusText.contains("github-issues"))
    #expect(model.statusMessage == "Loaded github-issues Airframe workspace.")
    #expect(model.summary.activeTaskCount == 1)
    #expect(model.summary.unverifiedTaskCount == 1)
    #expect(model.readyRecords.map(\.workItem.id) == [AirframeID("T-0059")])
    #expect(model.sprintRecords.map(\.workItem.id) == [AirframeID("T-0056"), AirframeID("T-0059")])
    #expect(model.epicRecords.map(\.workItem.id) == [AirframeID("T-0056"), AirframeID("T-0059")])
}

@MainActor
@Test func agileCockpitSP028DashboardAndPlanningUseCanonicalGitHubState() throws {
    let configURL = try temporaryLiveConfigurationURL(
        activeSprintID: "SP-028",
        activeEpicID: "EP-020",
        backendKind: "github-issues"
    )
    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:],
        githubIssueTransport: StubGitHubIssueTransport(issues: sp028GitHubIssues)
    )

    #expect(model.summary.activeTaskCount == 4)
    #expect(model.summary.nextTask?.id == AirframeID("T-0128"))
    #expect(model.activeRecords.map(\.workItem.id) == [
        AirframeID("T-0128"),
        AirframeID("T-0129"),
        AirframeID("T-0130"),
        AirframeID("T-0131")
    ])
    #expect(model.sprintRecords.map(\.workItem.id) == [
        AirframeID("T-0128"),
        AirframeID("T-0129"),
        AirframeID("T-0130"),
        AirframeID("T-0131")
    ])
    #expect(model.epicRecords.map(\.workItem.id) == [
        AirframeID("T-0128"),
        AirframeID("T-0129"),
        AirframeID("T-0130"),
        AirframeID("T-0131")
    ])
    #expect(model.statusTiles.first { $0.id == "tasks" }?.rows.first { $0.title == "Active" }?.count == 4)
}

@MainActor
@Test func agileCockpitShowsCanonicalDataHealthDiagnosticsForMissingPlanningRecords() throws {
    let configURL = try temporaryLiveConfigurationURL(
        activeSprintID: "SP-028",
        activeEpicID: "EP-020",
        backendKind: "github-issues"
    )
    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:],
        githubIssueTransport: StubGitHubIssueTransport(issues: sp028GitHubIssues)
    )

    #expect(model.canonicalDiagnostics.status == .blocking)
    #expect(model.diagnosticRows.map(\.reason).contains("activeEpicMissing"))
    #expect(model.diagnosticRows.map(\.reason).contains("activeSprintMissing"))
    #expect(model.diagnosticRows.map(\.reason).contains("taskEpicMissing"))
    #expect(model.diagnosticRows.map(\.reason).contains("taskSprintMissing"))
    #expect(model.dataHealthStatusText.contains("blocking"))
    #expect(model.repairPreviewRows.map(\.action).contains(.clearActiveEpicID))
    #expect(model.repairPreviewRows.map(\.action).contains(.clearActiveSprintID))
    #expect(model.repairPreviewRows.allSatisfy { $0.requiresHumanApproval })
}

@MainActor
@Test func agileCockpitCanonicalDataHealthUsesLocalPlanningArtifactsWhenAvailable() throws {
    let configURL = try temporaryLiveConfigurationURL(
        activeSprintID: "SP-028",
        activeEpicID: "EP-020",
        backendKind: "github-issues"
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
    try """
    # Active Epics

    ## EP-020: Canonical Airframe Workflow State

    **Status:** Active
    """.write(to: rootURL.appending(path: "docs/Epics/Epic-active.md"), atomically: true, encoding: .utf8)
    try """
    # Active Sprint

    ## SP-028: AgileCockpit Canonical State Integration

    **Status:** Active
    **Epic:** EP-020: Canonical Airframe Workflow State
    """.write(to: rootURL.appending(path: "docs/Sprints/Sprint-active.md"), atomically: true, encoding: .utf8)

    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:],
        githubIssueTransport: StubGitHubIssueTransport(issues: sp028GitHubIssues)
    )

    #expect(!model.diagnosticRows.map(\.reason).contains("activeEpicMissing"))
    #expect(!model.diagnosticRows.map(\.reason).contains("activeSprintMissing"))
    #expect(model.activeEpicRecord?.workItem.id == AirframeID("EP-020"))
    #expect(model.activeSprintRecord?.workItem.id == AirframeID("SP-028"))
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
@Test func agileCockpitExposesVerificationPacketEvidenceAndActions() async throws {
    let model = try AgileCockpitDashboardModel.sample()

    model.selectVerificationWorkItem(AirframeID("T-0042"))
    try await waitForVerificationDetailLoaded(model)

    #expect(model.selectedPacket?.workItem.id == AirframeID("T-0042"))
    #expect(model.selectedPacket?.existingEvidence.first?.id == AirframeID("EV-0042-001"))

    model.requestMoreEvidenceForSelectedWork()

    #expect(model.isVerificationActionPending)
    try await waitForVerificationActionCompleted(model)
    #expect(model.summary.unverifiedTaskCount == 0)
    #expect(model.activeRecords.map(\.workItem.id).contains(AirframeID("T-0042")))
    #expect(model.auditRows.last?.action == "OP-HUMAN-REQUEST-EVIDENCE")
}

@MainActor
@Test func agileCockpitAcceptsReadyWorkThroughCoreBackend() async throws {
    let model = try AgileCockpitDashboardModel.sample()

    model.selectVerificationWorkItem(AirframeID("T-0042"))
    model.acceptSelectedWork()

    #expect(model.isVerificationActionPending)
    try await waitForVerificationActionCompleted(model)
    #expect(model.verifiedRecords.map(\.workItem.id).contains(AirframeID("T-0042")))
    #expect(model.summary.verifiedTaskCount == 2)
    #expect(model.statusMessage.contains("T-0042 accepted"))
}

@MainActor
@Test func agileCockpitAcceptsReadyIssueThroughLocalBackend() async throws {
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

    model.selectVerificationWorkItem(AirframeID("I-9100"))
    model.acceptSelectedWork()

    #expect(model.isVerificationActionPending)
    try await waitForVerificationActionCompleted(model)
    #expect(model.verifiedRecords.map(\.workItem.id).contains(AirframeID("I-9100")))
    #expect(model.auditRows.last?.action == "OP-HUMAN-ACCEPT-WORK")
    #expect(model.statusMessage.contains("I-9100 accepted"))
}

@MainActor
@Test func agileCockpitAppliesGitHubVerificationWithHumanReviewerContext() async throws {
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

    model.selectVerificationWorkItem(AirframeID("T-0059"))
    model.acceptSelectedWork()

    #expect(model.isVerificationActionPending)
    try await waitForVerificationActionCompleted(model)
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
@Test func agileCockpitRequestMoreEvidenceAttachesReviewerComment() async throws {
    let context = try AirframeConfigurationLoader().loadSampleContext()
    let storeURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitReviewerCommentStore")
        .appending(path: UUID().uuidString)
        .appending(path: "airframe-local-backend.json")
    let backend = AirframeLocalFilesystemBackend(storeURL: storeURL)
    try backend.createWorkRecord(
        AirframeLocalWorkRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("T-9200"),
                kind: .task,
                title: "Ready task needing more evidence",
                status: .implementedNotVerified,
                githubIssue: 9200
            ),
            epicID: AirframeID("EP-020"),
            sprintID: AirframeID("SP-028"),
            priority: .high
        )
    )
    let model = try AgileCockpitDashboardModel(
        context: context,
        backend: backend,
        reviewerContext: reviewerContext(projectID: context.project.id)
    )

    model.selectVerificationWorkItem(AirframeID("T-9200"))
    model.verificationCommentText = "Please attach a screenshot of the loading state."
    model.requestMoreEvidenceForSelectedWork()

    #expect(model.isVerificationActionPending)
    try await waitForVerificationActionCompleted(model)

    let evidence = try backend.evidence(for: AirframeID("T-9200"))
    #expect(evidence.first?.summary.contains("Please attach a screenshot") == true)
    #expect(model.statusMessage.contains("T-9200 sent back for more evidence"))
}

@MainActor
@Test func agileCockpitVerificationDetailLoadFailureIsVisibleAndReloadable() async throws {
    let context = try AirframeConfigurationLoader().loadSampleContext()
    let backend = FailingVerificationBackend()
    let model = try AgileCockpitDashboardModel(
        context: context,
        backend: backend,
        reviewerContext: reviewerContext(projectID: context.project.id)
    )

    model.selectVerificationWorkItem(AirframeID("T-9300"))
    try await waitForVerificationDetailFailed(model)

    if case .failed(let id, let message) = model.verificationDetailState {
        #expect(id == AirframeID("T-9300"))
        #expect(message.contains("simulated packet load failure"))
    } else {
        Issue.record("Expected failed verification detail state.")
    }
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
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Sprints/Review"),
        withIntermediateDirectories: true
    )
    try """
    # Active Epics

    ## EP-017: Workflow Status Dashboard and Mutation Authority

    **Status:** Active
    """.write(to: rootURL.appending(path: "docs/Epics/Epic-active.md"), atomically: true, encoding: .utf8)
    try """
    # Sprint Backlog

    ## SP-020: AgileCockpit Verification Mutations

    **Status:** Backlog
    **Epic:** EP-017: Workflow Status Dashboard and Mutation Authority

    ## SP-021: AgileCockpit Close Controls

    **Status:** Backlog
    **Epic:** EP-017: Workflow Status Dashboard and Mutation Authority
    """.write(to: rootURL.appending(path: "docs/Sprints/Sprint-backlog.md"), atomically: true, encoding: .utf8)
    try """
    # Active Sprint

    ## SP-019: AgileCockpit Human Verification Mutations

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
    try """
    # SP-017: Workflow Status Dashboard

    **Status:** Review
    **Epic:** EP-017: Workflow Status Dashboard and Mutation Authority
    """.write(to: rootURL.appending(path: "docs/Sprints/Review/Sprint-SP-017.md"), atomically: true, encoding: .utf8)
    try """
    # SP-018: AICockpit Work Item Mutation Support

    **Status:** Review
    **Epic:** EP-017: Workflow Status Dashboard and Mutation Authority
    """.write(to: rootURL.appending(path: "docs/Sprints/Review/Sprint-SP-018.md"), atomically: true, encoding: .utf8)

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
    #expect(model.statusTiles.first { $0.id == "sprints" }?.rows.first { $0.title == "Review" }?.count == 2)
    #expect(model.statusTiles.first { $0.id == "sprints" }?.rows.first { $0.title == "Closed" }?.count == 1)
}

@MainActor
@Test func agileCockpitDataHealthReportsCanonicalBackendDrift() throws {
    let context = try AirframeConfigurationLoader().loadSampleContext()
    let rootURL = FileManager.default.temporaryDirectory
        .appending(path: "AgileCockpitBackendDrift")
        .appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Tasks"),
        withIntermediateDirectories: true
    )
    let backend = AirframeLocalFilesystemBackend(
        storeURL: rootURL.appending(path: "airframe-local-backend.json")
    )
    try backend.createWorkRecord(
        AirframeLocalWorkRecord(
            workItem: AirframeWorkItem(
                id: AirframeID("T-0091"),
                kind: .task,
                title: "Add local create command support",
                status: .active
            ),
            epicID: AirframeID("EP-017"),
            sprintID: AirframeID("SP-017")
        )
    )
    try """
    # Implemented Tasks

    ## T-0091: Add local create command support

    **Status:** Implemented - Not Verified
    **Priority:** High
    **Epic:** EP-017
    **Sprint Assigned:** SP-018
    """.write(to: rootURL.appending(path: "docs/Tasks/Task-unverified.md"), atomically: true, encoding: .utf8)

    let model = try AgileCockpitDashboardModel(
        context: context,
        backend: backend,
        reviewerContext: reviewerContext(projectID: context.project.id),
        artifactRootURL: rootURL
    )

    let taskRecord = try #require(model.dashboardRecords.first { $0.workItem.id == AirframeID("T-0091") })
    #expect(taskRecord.workItem.status == .implementedNotVerified)
    #expect(taskRecord.sprintID == AirframeID("SP-018"))
    #expect(model.diagnosticRows.map(\.reason).contains("backendStatusDrift"))
    #expect(model.repairPreviewRows.map(\.action).contains(.applyBackendStatusLabels))
    let repairRow = try #require(model.repairPreviewRows.first { $0.action == .applyBackendStatusLabels })
    #expect(repairRow.requiresHumanApproval == false)

    model.applyRepair(repairRow)

    let repairedRecord = try #require(try backend.workRecord(id: AirframeID("T-0091")))
    #expect(repairedRecord.workItem.status == .implementedNotVerified)
    #expect(repairedRecord.sprintID == AirframeID("SP-018"))
    #expect(model.statusMessage == "Applied 1 repair(s).")
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

@MainActor
@Test func agileCockpitRejectsSprintCloseUntilAssignedTasksAndIssuesAreVerified() throws {
    let configURL = try temporaryLiveConfigurationURL(
        activeSprintID: "SP-022",
        activeEpicID: "EP-018",
        backendKind: "local-fixture"
    )
    let rootURL = configURL.deletingLastPathComponent()
    try writeCloseActionWorkspace(
        rootURL: rootURL,
        sprintTaskStatus: "Implemented - Not Verified",
        sprintIssueStatus: "Resolved - Verified",
        epicCriteria: ["[x] Criterion is verified."]
    )

    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:]
    )

    #expect(model.sprintCloseEligibility?.eligibility.isEligible == false)

    model.closeActiveSprint()

    let sprintContents = try String(contentsOf: rootURL.appending(path: "docs/Sprints/Sprint-active.md"), encoding: .utf8)
    #expect(sprintContents.contains("**Status:** Active"))
    #expect(model.statusMessage.contains("Sprint SP-022 cannot close"))
    #expect(model.statusMessage.contains("T-0107"))
}

@MainActor
@Test func agileCockpitClosesSprintToReviewWhenAssignedTasksAndIssuesAreVerified() throws {
    let configURL = try temporaryLiveConfigurationURL(
        activeSprintID: "SP-022",
        activeEpicID: "EP-018",
        backendKind: "local-fixture"
    )
    let rootURL = configURL.deletingLastPathComponent()
    try writeCloseActionWorkspace(
        rootURL: rootURL,
        sprintTaskStatus: "Implemented - Verified",
        sprintIssueStatus: "Resolved - Verified",
        epicCriteria: ["[x] Criterion is verified."]
    )
    try importMarkdownFixturesIntoCanonicalState(rootURL: rootURL, configURL: configURL)
    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:]
    )

    model.closeActiveSprint()

    let sprintRecord = try AirframeCanonicalStoreRepository(rootURL: rootURL)
        .snapshot(project: model.context.project)
        .sprints
        .first { $0.workItem.id == AirframeID("SP-022") }
    #expect(sprintRecord?.workItem.status == .review)
    #expect(model.activeSprintRecord?.workItem.status == .review)
    #expect(model.auditRows.last?.action == "OP-HUMAN-REVIEW-SPRINT")
    #expect(model.statusMessage == "Sprint SP-022 close accepted: moved to Review.")
}

@MainActor
@Test func agileCockpitClosesReviewedSprintAndClearsActiveSprint() throws {
    let configURL = try temporaryLiveConfigurationURL(
        activeSprintID: "SP-022",
        activeEpicID: "EP-018",
        backendKind: "local-fixture"
    )
    let rootURL = configURL.deletingLastPathComponent()
    try writeCloseActionWorkspace(
        rootURL: rootURL,
        sprintStatus: "Review",
        sprintTaskStatus: "Implemented - Verified",
        sprintIssueStatus: "Resolved - Verified",
        epicCriteria: ["[x] Criterion is verified."]
    )
    try importMarkdownFixturesIntoCanonicalState(rootURL: rootURL, configURL: configURL)
    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:]
    )

    #expect(model.canonicalDiagnostics.isValid)

    model.closeActiveSprint()

    let snapshot = try AirframeCanonicalStoreRepository(rootURL: rootURL)
        .snapshot(project: model.context.project)
    let sprintRecord = snapshot.sprints.first { $0.workItem.id == AirframeID("SP-022") }
    #expect(sprintRecord?.workItem.status == .closed)
    #expect(snapshot.project.activeSprintID == nil)
    #expect(model.canonicalSnapshot.project.activeSprintID == nil)
    #expect(model.activeSprintRecord == nil)
    #expect(model.auditRows.last?.action == "OP-HUMAN-CLOSE-SPRINT")
    #expect(model.statusMessage == "Sprint SP-022 closed.")

    let archivedSprint = try String(
        contentsOf: rootURL.appending(path: "docs/Sprints/Closed/Sprint-SP-022.md"),
        encoding: .utf8
    )
    let activeSprint = try String(
        contentsOf: rootURL.appending(path: "docs/Sprints/Sprint-active.md"),
        encoding: .utf8
    )
    let sprintIndex = try String(
        contentsOf: rootURL.appending(path: "docs/Sprints/Sprint-Documentation.md"),
        encoding: .utf8
    )
    #expect(archivedSprint.contains("# SP-022: Close Eligibility"))
    #expect(archivedSprint.contains("**Status:** Closed"))
    #expect(!activeSprint.contains("SP-022"))
    #expect(sprintIndex.contains("| SP-022 | Close Eligibility | EP-018 | T-0107 | I-0007 | Closed |"))
}

@MainActor
@Test func agileCockpitClosesReviewedSprintUsingLocalCanonicalStateOnly() throws {
    let configURL = try temporaryLiveConfigurationURL(
        activeSprintID: "SP-022",
        activeEpicID: "EP-018",
        backendKind: "local-fixture"
    )
    let rootURL = configURL.deletingLastPathComponent()
    try writeCloseActionWorkspace(
        rootURL: rootURL,
        sprintStatus: "Review",
        sprintTaskStatus: "Implemented - Verified",
        sprintIssueStatus: "Resolved - Verified",
        epicCriteria: ["[x] Criterion is verified."]
    )
    try importMarkdownFixturesIntoCanonicalState(rootURL: rootURL, configURL: configURL)

    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:]
    )

    #expect(model.backendStatusText.contains("local-fixture"))

    model.closeActiveSprint()

    let snapshot = try AirframeCanonicalStoreRepository(rootURL: rootURL)
        .snapshot(project: model.context.project)
    let sprintRecord = snapshot.sprints.first { $0.workItem.id == AirframeID("SP-022") }
    #expect(sprintRecord?.workItem.status == .closed)
    #expect(snapshot.project.activeSprintID == nil)
    #expect(FileManager.default.fileExists(atPath: rootURL.appending(path: "docs/Sprints/Closed/Sprint-SP-022.md").path))
    #expect(model.auditRows.last?.action == "OP-HUMAN-CLOSE-SPRINT")
    #expect(model.auditRows.last?.workItemID == "SP-022")
    #expect(model.statusMessage == "Sprint SP-022 closed.")
}

@MainActor
@Test func agileCockpitGatesEpicCloseOnVerifiedAcceptanceCriteria() throws {
    let configURL = try temporaryLiveConfigurationURL(
        activeSprintID: "SP-022",
        activeEpicID: "EP-018",
        backendKind: "local-fixture"
    )
    let rootURL = configURL.deletingLastPathComponent()
    try writeCloseActionWorkspace(
        rootURL: rootURL,
        sprintTaskStatus: "Implemented - Verified",
        sprintIssueStatus: "Resolved - Verified",
        epicCriteria: ["[x] Verified criterion.", "[ ] Unverified criterion."]
    )
    try importMarkdownFixturesIntoCanonicalState(rootURL: rootURL, configURL: configURL)
    let blockedModel = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:]
    )

    blockedModel.closeActiveEpic()

    let epicContents = try String(contentsOf: rootURL.appending(path: "docs/Epics/Epic-active.md"), encoding: .utf8)
    #expect(epicContents.contains("**Status:** Active"))
    #expect(blockedModel.statusMessage.contains("Epic EP-018 cannot close"))
    #expect(blockedModel.statusMessage.contains("EP-018-AC-02"))

    try writeCloseActionWorkspace(
        rootURL: rootURL,
        sprintStatus: "Active",
        sprintTaskStatus: "Implemented - Verified",
        sprintIssueStatus: "Resolved - Verified",
        epicCriteria: ["[x] Verified criterion.", "[x] Now verified criterion."]
    )
    try importMarkdownFixturesIntoCanonicalState(rootURL: rootURL, configURL: configURL)
    let openSprintModel = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:]
    )

    openSprintModel.closeActiveEpic()

    #expect(openSprintModel.statusMessage.contains("Epic EP-018 cannot close"))
    #expect(openSprintModel.statusMessage.contains("SP-022 is Active."))

    try writeCloseActionWorkspace(
        rootURL: rootURL,
        sprintStatus: "Closed",
        sprintTaskStatus: "Implemented - Verified",
        sprintIssueStatus: "Resolved - Verified",
        epicCriteria: ["[x] Verified criterion.", "[x] Now verified criterion."]
    )
    try importMarkdownFixturesIntoCanonicalState(rootURL: rootURL, configURL: configURL)
    let eligibleModel = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:]
    )
    eligibleModel.closeActiveEpic()

    let closedSnapshot = try AirframeCanonicalStoreRepository(rootURL: rootURL)
        .snapshot(project: eligibleModel.context.project)
    let epicRecord = closedSnapshot
        .epics
        .first { $0.workItem.id == AirframeID("EP-018") }
    #expect(epicRecord?.workItem.status == .closed)
    #expect(closedSnapshot.project.activeEpicID == nil)
    #expect(eligibleModel.canonicalSnapshot.project.activeEpicID == nil)
    #expect(eligibleModel.activeEpicText == "None")
    #expect(eligibleModel.activeEpicRecord == nil)

    let archivedEpic = try String(
        contentsOf: rootURL.appending(path: "docs/Epics/Closed/Epic-EP-018.md"),
        encoding: .utf8
    )
    let activeEpic = try String(
        contentsOf: rootURL.appending(path: "docs/Epics/Epic-active.md"),
        encoding: .utf8
    )
    let epicIndex = try String(
        contentsOf: rootURL.appending(path: "docs/Epics/Epic-Documentation.md"),
        encoding: .utf8
    )
    #expect(archivedEpic.contains("# EP-018: AgileCockpit Sprint and Epic Status Controls"))
    #expect(archivedEpic.contains("**Status:** Closed"))
    #expect(!activeEpic.contains("EP-018"))
    #expect(epicIndex.contains("| EP-018 | AgileCockpit Sprint and Epic Status Controls | Closed |"))
    #expect(eligibleModel.auditRows.last?.action == "OP-HUMAN-CLOSE-EPIC")
    #expect(eligibleModel.statusMessage == "Epic EP-018 closed.")
}

@MainActor
@Test func agileCockpitRecordsEpicCloseWithHumanReviewerAuthority() throws {
    let configURL = try temporaryLiveConfigurationURL(
        activeSprintID: "SP-022",
        activeEpicID: "EP-018",
        backendKind: "local-fixture"
    )
    let rootURL = configURL.deletingLastPathComponent()
    try writeCloseActionWorkspace(
        rootURL: rootURL,
        sprintStatus: "Closed",
        sprintTaskStatus: "Implemented - Verified",
        sprintIssueStatus: "Resolved - Verified",
        epicCriteria: ["[x] Verified criterion."]
    )
    try importMarkdownFixturesIntoCanonicalState(rootURL: rootURL, configURL: configURL)
    let model = try AgileCockpitDashboardModel.configured(
        configurationURL: configURL,
        environment: [:]
    )

    model.closeActiveEpic()

    let closeAudit = try #require(model.auditRows.last)
    #expect(closeAudit.action == "OP-HUMAN-CLOSE-EPIC")
    #expect(closeAudit.workItemID == "EP-018")
    #expect(closeAudit.reason == "allowed")
    #expect(model.statusMessage == "Epic EP-018 closed.")
}

@MainActor
@Test func agileCockpitReplacesArtifactStatusInsideMatchingSectionOnly() throws {
    let contents = """
    # Active Epics

    ## EP-017: Earlier Epic

    **Status:** Active

    ## EP-018: Target Epic

    **Status:** Complete
    """

    let updated = try AgileCockpitDashboardModel.replacingArtifactStatus(
        for: AirframeID("EP-018"),
        kind: .epic,
        with: .closed,
        in: contents
    )

    #expect(updated.contains("## EP-017: Earlier Epic\n\n**Status:** Active"))
    #expect(updated.contains("## EP-018: Target Epic\n\n**Status:** Closed"))
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

private func writeCloseActionWorkspace(
    rootURL: URL,
    sprintStatus: String = "Active",
    sprintTaskStatus: String,
    sprintIssueStatus: String,
    epicCriteria: [String]
) throws {
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
    try FileManager.default.createDirectory(
        at: rootURL.appending(path: "docs/Issues"),
        withIntermediateDirectories: true
    )

    let criteriaLines = epicCriteria.enumerated()
        .map { index, criterion in "\(index + 1). \(criterion)" }
        .joined(separator: "\n")
    try """
    # Active Epics

    ## EP-018: AgileCockpit Sprint and Epic Status Controls

    **Status:** Active

    **Acceptance Criteria:**
    \(criteriaLines)
    """.write(to: rootURL.appending(path: "docs/Epics/Epic-active.md"), atomically: true, encoding: .utf8)
    try """
    # Active Sprint

    ## SP-022: Close Eligibility

    **Status:** \(sprintStatus)
    **Epic:** EP-018: AgileCockpit Sprint and Epic Status Controls
    """.write(to: rootURL.appending(path: "docs/Sprints/Sprint-active.md"), atomically: true, encoding: .utf8)
    try """
    # Active Tasks

    ## T-0107: Gate Sprint close

    **Status:** \(sprintTaskStatus)
    **GitHub Issue:** #113
    **Priority:** High
    **Epic:** EP-018
    **Sprint Assigned:** SP-022
    """.write(to: rootURL.appending(path: "docs/Tasks/Task-active.md"), atomically: true, encoding: .utf8)
    try """
    # Active Issues

    ## I-0007: Close feedback

    **Status:** \(sprintIssueStatus)
    **Severity:** Medium
    **Epic:** EP-018
    **Sprint Assigned:** SP-022
    """.write(to: rootURL.appending(path: "docs/Issues/Issue-active.md"), atomically: true, encoding: .utf8)
}

private func importMarkdownFixturesIntoCanonicalState(rootURL: URL, configURL: URL) throws {
    let context = try AirframeRuntimeConfigurationResolver().loadContext(explicitPath: configURL.path)
    let fileManager = FileManager.default
    let paths = [
        "docs/Epics/Epic-active.md",
        "docs/Sprints/Sprint-active.md",
        "docs/Tasks/Task-active.md",
        "docs/Issues/Issue-active.md"
    ]
    let documents = try paths.compactMap { path -> AirframeMarkdownDocument? in
        let url = rootURL.appending(path: path)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return AirframeMarkdownDocument(
            sourcePath: path,
            markdown: try String(contentsOf: url, encoding: .utf8)
        )
    }
    let result = AirframeMarkdownArtifactImporter().importDocuments(documents)
    try AirframeCanonicalStoreRepository(rootURL: rootURL).saveImportedState(
        result,
        context: context
    )
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

@MainActor
private func waitForVerificationDetailLoaded(
    _ model: AgileCockpitDashboardModel,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
) async throws {
    try await waitForCondition(
        { if case .loaded = model.verificationDetailState { true } else { false } },
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
    )
}

@MainActor
private func waitForVerificationDetailFailed(
    _ model: AgileCockpitDashboardModel,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
) async throws {
    try await waitForCondition(
        { if case .failed = model.verificationDetailState { true } else { false } },
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
    )
}

@MainActor
private func waitForVerificationActionCompleted(
    _ model: AgileCockpitDashboardModel,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
) async throws {
    try await waitForCondition(
        { if case .completed = model.verificationActionState { true } else { false } },
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
    )
}

@MainActor
private func waitForCondition(
    _ condition: @escaping @MainActor () -> Bool,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
) async throws {
    for _ in 0..<50 {
        if condition() {
            return
        }
        try await Task.sleep(nanoseconds: 10_000_000)
    }
    #expect(Bool(false), sourceLocation: SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column))
}

private final class FailingVerificationBackend: @unchecked Sendable, AirframeBackend {
    let capabilities = AirframeBackendCapabilities.localFilesystem

    private let record = AirframeLocalWorkRecord(
        workItem: AirframeWorkItem(
            id: AirframeID("T-9300"),
            kind: .task,
            title: "Ready work with failing packet load",
            status: .implementedNotVerified,
            githubIssue: 9300
        ),
        epicID: AirframeID("EP-020"),
        sprintID: AirframeID("SP-028"),
        priority: .high
    )

    func listWorkRecords() throws -> [AirframeLocalWorkRecord] {
        [record]
    }

    func workRecord(id: AirframeID) throws -> AirframeLocalWorkRecord? {
        id == record.workItem.id ? record : nil
    }

    func createWorkRecord(_ record: AirframeLocalWorkRecord) throws {}

    func updateWorkRecord(_ record: AirframeLocalWorkRecord) throws {}

    func updateWorkItem(_ workItem: AirframeWorkItem) throws {}

    func transitionWorkItem(
        id: AirframeID,
        to status: AirframeWorkStatus,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws {}

    func attachEvidence(_ evidence: AirframeEvidence, to workItemID: AirframeID) throws {}

    func evidence(for workItemID: AirframeID) throws -> [AirframeEvidence] {
        []
    }

    func taskPacket(for workItemID: AirframeID) throws -> AirframeTaskPacket {
        throw AirframeBackendError.githubAccessFailed("simulated packet load failure")
    }

    func applyHumanVerification(
        action: AirframeHumanVerificationAction,
        to workItemID: AirframeID,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeHumanVerificationResult {
        throw AirframeBackendError.githubAccessFailed("simulated verification failure")
    }

    func dashboardSummary() throws -> AirframeDashboardSummary {
        AirframeDashboardSummary(
            totalWorkItemCount: 1,
            activeTaskCount: 0,
            unverifiedTaskCount: 1,
            verifiedTaskCount: 0,
            issueCount: 0,
            nextTask: nil,
            recentEvidenceCount: 0
        )
    }
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

private let sp028GitHubIssues = [
    AirframeGitHubIssueRecord(
        number: 128,
        title: "[T-0128] Move AgileCockpit dashboard and planning views to canonical records",
        labels: ["airframe-task", "status-active", "epic-EP-020", "sprint-SP-028", "priority-high"],
        body: """
        Airframe Type: Task
        Airframe ID: T-0128
        Epic: EP-020
        Sprint: SP-028

        ## Acceptance Criteria
        - AgileCockpit dashboard status tiles read canonical records.
        - Sprint and Epic planning views read canonical records.
        """
    ),
    AirframeGitHubIssueRecord(
        number: 129,
        title: "[T-0129] Add AgileCockpit data health diagnostics surface",
        labels: ["airframe-task", "status-active", "epic-EP-020", "sprint-SP-028", "priority-high"],
        body: """
        Airframe Type: Task
        Airframe ID: T-0129
        Epic: EP-020
        Sprint: SP-028

        ## Acceptance Criteria
        - AgileCockpit shows AirframeCore diagnostics with severity, affected IDs, and explanations.
        """
    ),
    AirframeGitHubIssueRecord(
        number: 130,
        title: "[T-0130] Add AgileCockpit repair preview flow for canonical diagnostics",
        labels: ["airframe-task", "status-active", "epic-EP-020", "sprint-SP-028", "priority-high"],
        body: """
        Airframe Type: Task
        Airframe ID: T-0130
        Epic: EP-020
        Sprint: SP-028

        ## Acceptance Criteria
        - Repair previews show affected records and fields before mutation.
        """
    ),
    AirframeGitHubIssueRecord(
        number: 131,
        title: "[T-0131] Verify end-to-end canonical workflow state behavior",
        labels: ["airframe-task", "status-active", "epic-EP-020", "sprint-SP-028", "priority-high"],
        body: """
        Airframe Type: Task
        Airframe ID: T-0131
        Epic: EP-020
        Sprint: SP-028

        ## Acceptance Criteria
        - Tests prove human-only operations remain protected.
        """
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
