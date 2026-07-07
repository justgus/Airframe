import AirframeCore
import Combine
import Foundation
import SwiftUI
#if os(macOS)
import Darwin
#endif

enum AgileCockpitSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case verification = "Verification"
    case planning = "Sprint & Epic"
    case requirements = "Requirements"
    case tests = "Tests"
    case metrics = "Metrics & Audit"

    var id: String { rawValue }

    var accessibilityID: String {
        switch self {
        case .dashboard:
            "dashboard"
        case .verification:
            "verification"
        case .planning:
            "planning"
        case .requirements:
            "requirements"
        case .tests:
            "tests"
        case .metrics:
            "metrics"
        }
    }
}

enum AgileCockpitPlanningTab: String, CaseIterable, Identifiable {
    case sprintWork = "Sprint Work"
    case epicCriteria = "Epic Criteria"
    case epicWork = "Epic Work"

    var id: String { rawValue }

    var accessibilityID: String {
        switch self {
        case .sprintWork:
            "sprint-work"
        case .epicCriteria:
            "epic-criteria"
        case .epicWork:
            "epic-work"
        }
    }
}

struct AgileCockpitMetric: Equatable, Identifiable {
    let id: String
    let title: String
    let value: String
}

struct AgileCockpitStatusSelection: Equatable, Identifiable {
    let tile: AirframeDashboardStatusTile
    let row: AirframeDashboardStatusRow

    var id: String { row.id }
}

struct AgileCockpitAuditRow: Codable, Equatable, Identifiable {
    let id: String
    let action: String
    let workItemID: String
    let reason: String
}

struct AgileCockpitDiagnosticRow: Codable, Equatable, Identifiable {
    let id: String
    let severity: String
    let reason: String
    let message: String
    let affectedIDs: String
}

struct AgileCockpitRepairPreviewRow: Equatable, Identifiable {
    let id: String
    let action: AirframeCanonicalRepairAction
    let title: String
    let affectedIDs: [AirframeID]
    let requiresHumanApproval: Bool

    var actionText: String {
        action.rawValue
    }

    var affectedIDsText: String {
        affectedIDs.map(\.rawValue).joined(separator: ", ")
    }
}

struct AgileCockpitRequirementTraceRow: Codable, Equatable, Identifiable {
    let requirementID: String
    let title: String
    let statement: String
    let status: String
    let acceptanceCriteria: String

    var id: String { requirementID }
}

struct AgileCockpitRequirementGapRow: Codable, Equatable, Identifiable {
    let requirementID: String
    let kind: String
    let message: String

    var id: String { "\(requirementID)-\(kind)" }
}

struct AgileCockpitTestRow: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let objective: String
    let kind: String
    let status: String
    let requirementIDs: String
    let acceptanceCriterionIDs: String
    let workItemIDs: String
}

struct AgileCockpitTestCoverageRow: Codable, Equatable, Identifiable {
    let requirementID: String
    let title: String
    let status: String
    let acceptanceCriteria: String
    let tests: String

    var id: String { requirementID }
}

struct AgileCockpitTestGapRow: Codable, Equatable, Identifiable {
    let requirementID: String
    let kind: String
    let message: String

    var id: String { "\(requirementID)-\(kind)" }
}

enum AgileCockpitVerificationQueueState: Equatable {
    case loading
    case loaded
    case failed(String)
}

enum AgileCockpitVerificationDetailState: Equatable {
    case empty
    case loading(AirframeID)
    case loaded(AirframeTaskPacket)
    case failed(AirframeID, String)
}

enum AgileCockpitVerificationActionState: Equatable {
    case idle
    case pending(AirframeID, String)
    case failed(AirframeID, String)
    case completed(String)
}

@MainActor
final class AgileCockpitDashboardModel: ObservableObject {
    nonisolated fileprivate struct LaunchData: @unchecked Sendable {
        let coreInfo: AirframeCoreInfo
        let context: AirframeProjectContext
        let configurationDiagnostics: AirframeConfigurationDiagnostics
        let backend: any AirframeBackend
        let repairBackend: any AirframeBackend
        let reviewerContext: AirframeCertifiedContext
        let artifactRootURL: URL?
        let canonicalRepository: AirframeCanonicalStoreRepository?
        let canonicalState: AirframeCanonicalStoreState?
        let records: [AirframeLocalWorkRecord]
        let dashboardRecords: [AirframeLocalWorkRecord]
        let dashboardDetailTextByID: [AirframeID: String]
        let canonicalSnapshot: AirframeCanonicalStateSnapshot
        let canonicalDiagnostics: AirframeCanonicalDiagnostics
        let summary: AirframeDashboardSummary
        let auditRows: [AgileCockpitAuditRow]
        let requirementCoverageSummary: AirframeRequirementCoverageSummary
        let requirementGateSummary: AirframeRequirementReleaseGateSummary
        let requirementTraceRows: [AgileCockpitRequirementTraceRow]
        let requirementGapRows: [AgileCockpitRequirementGapRow]
        let testCoverageRows: [AgileCockpitTestCoverageRow]
        let testGapRows: [AgileCockpitTestGapRow]
        let observedURLs: [URL]

        init(
            coreInfo: AirframeCoreInfo,
            context: AirframeProjectContext,
            configurationDiagnostics: AirframeConfigurationDiagnostics,
            backend: any AirframeBackend,
            repairBackend: any AirframeBackend,
            reviewerContext: AirframeCertifiedContext,
            artifactRootURL: URL?,
            canonicalRepository: AirframeCanonicalStoreRepository?,
            canonicalState: AirframeCanonicalStoreState?,
            records: [AirframeLocalWorkRecord],
            dashboardRecords: [AirframeLocalWorkRecord],
            dashboardDetailTextByID: [AirframeID: String],
            canonicalSnapshot: AirframeCanonicalStateSnapshot,
            canonicalDiagnostics: AirframeCanonicalDiagnostics,
            summary: AirframeDashboardSummary,
            auditRows: [AgileCockpitAuditRow],
            requirementCoverageSummary: AirframeRequirementCoverageSummary,
            requirementGateSummary: AirframeRequirementReleaseGateSummary,
            requirementTraceRows: [AgileCockpitRequirementTraceRow],
            requirementGapRows: [AgileCockpitRequirementGapRow],
            testCoverageRows: [AgileCockpitTestCoverageRow],
            testGapRows: [AgileCockpitTestGapRow],
            observedURLs: [URL]
        ) {
            self.coreInfo = coreInfo
            self.context = context
            self.configurationDiagnostics = configurationDiagnostics
            self.backend = backend
            self.repairBackend = repairBackend
            self.reviewerContext = reviewerContext
            self.artifactRootURL = artifactRootURL
            self.canonicalRepository = canonicalRepository
            self.canonicalState = canonicalState
            self.records = records
            self.dashboardRecords = dashboardRecords
            self.dashboardDetailTextByID = dashboardDetailTextByID
            self.canonicalSnapshot = canonicalSnapshot
            self.canonicalDiagnostics = canonicalDiagnostics
            self.summary = summary
            self.auditRows = auditRows
            self.requirementCoverageSummary = requirementCoverageSummary
            self.requirementGateSummary = requirementGateSummary
            self.requirementTraceRows = requirementTraceRows
            self.requirementGapRows = requirementGapRows
            self.testCoverageRows = testCoverageRows
            self.testGapRows = testGapRows
            self.observedURLs = observedURLs
        }

        init(
            launchPayload payload: LaunchCachePayload,
            backend: any AirframeBackend,
            repairBackend: any AirframeBackend,
            reviewerContext: AirframeCertifiedContext,
            canonicalRepository: AirframeCanonicalStoreRepository?,
            canonicalState: AirframeCanonicalStoreState?
        ) {
            self.init(
                coreInfo: .current,
                context: AirframeProjectContext(
                    configuration: payload.configuration,
                    project: payload.project
                ),
                configurationDiagnostics: payload.configurationDiagnostics,
                backend: backend,
                repairBackend: repairBackend,
                reviewerContext: reviewerContext,
                artifactRootURL: payload.artifactRootPath.map { URL(fileURLWithPath: $0) },
                canonicalRepository: canonicalRepository,
                canonicalState: canonicalState ?? payload.canonicalState.map(AgileCockpitDashboardModel.cachedState(from:)),
                records: payload.records,
                dashboardRecords: payload.dashboardRecords,
                dashboardDetailTextByID: Dictionary(
                    uniqueKeysWithValues: payload.dashboardDetailTextByID.map { (AirframeID($0.key), $0.value) }
                ),
                canonicalSnapshot: AgileCockpitDashboardModel.cachedSnapshot(from: payload.canonicalSnapshot),
                canonicalDiagnostics: payload.canonicalDiagnostics,
                summary: payload.summary,
                auditRows: payload.auditRows,
                requirementCoverageSummary: payload.requirementCoverageSummary,
                requirementGateSummary: payload.requirementGateSummary,
                requirementTraceRows: payload.requirementTraceRows,
                requirementGapRows: payload.requirementGapRows,
                testCoverageRows: payload.testCoverageRows,
                testGapRows: payload.testGapRows,
                observedURLs: payload.observedURLs
            )
        }
    }

    nonisolated fileprivate struct LaunchCacheEntry: Codable, Sendable {
        let fingerprint: String
        let payload: LaunchCachePayload
    }

    nonisolated fileprivate struct LaunchCachePayload: Codable, Sendable {
        nonisolated struct CachedCanonicalState: Codable, Sendable {
            let workspaces: [AirframeCanonicalWorkspaceRecord]
            let projects: [AirframeCanonicalProjectRecord]
            let epics: [AirframeCanonicalEpicRecord]
            let sprints: [AirframeCanonicalSprintRecord]
            let tasks: [AirframeCanonicalTaskRecord]
            let issues: [AirframeCanonicalIssueRecord]
            let requirements: [AirframeCanonicalRequirementRecord]
            let requirementRevisions: [AirframeCanonicalRequirementRevisionRecord]
            let acceptanceCriteria: [AirframeCanonicalAcceptanceCriterionRecord]
            let tests: [AirframeCanonicalTestRecord]
            let testSuites: [AirframeCanonicalTestSuiteRecord]
            let testRuns: [AirframeCanonicalTestRunRecord]
            let evidence: [AirframeCanonicalEvidenceSummaryRecord]
        }

        nonisolated struct CachedCanonicalSnapshot: Codable, Sendable {
            let project: AirframeCanonicalProjectRecord
            let epics: [AirframeCanonicalEpicRecord]
            let sprints: [AirframeCanonicalSprintRecord]
            let tasks: [AirframeCanonicalTaskRecord]
            let issues: [AirframeCanonicalIssueRecord]
            let requirements: [AirframeCanonicalRequirementRecord]
            let acceptanceCriteria: [AirframeCanonicalAcceptanceCriterionRecord]
            let tests: [AirframeCanonicalTestRecord]
            let testSuites: [AirframeCanonicalTestSuiteRecord]
            let testRuns: [AirframeCanonicalTestRunRecord]
        }

        let configuration: AirframeWorkspaceConfiguration
        let project: AirframeProject
        let configurationDiagnostics: AirframeConfigurationDiagnostics
        let artifactRootPath: String?
        let observedURLs: [URL]
        let records: [AirframeLocalWorkRecord]
        let dashboardRecords: [AirframeLocalWorkRecord]
        let dashboardDetailTextByID: [String: String]
        let canonicalState: CachedCanonicalState?
        let canonicalSnapshot: CachedCanonicalSnapshot
        let canonicalDiagnostics: AirframeCanonicalDiagnostics
        let summary: AirframeDashboardSummary
        let auditRows: [AgileCockpitAuditRow]
        let requirementCoverageSummary: AirframeRequirementCoverageSummary
        let requirementGateSummary: AirframeRequirementReleaseGateSummary
        let requirementTraceRows: [AgileCockpitRequirementTraceRow]
        let requirementGapRows: [AgileCockpitRequirementGapRow]
        let testCoverageRows: [AgileCockpitTestCoverageRow]
        let testGapRows: [AgileCockpitTestGapRow]
    }

    nonisolated fileprivate struct TraceabilityCacheEntry: Codable, Sendable {
        let fingerprint: String
        let payload: TraceabilityCachePayload
    }

    nonisolated fileprivate struct TraceabilityCachePayload: Codable, Sendable {
        let requirementCoverageSummary: AirframeRequirementCoverageSummary
        let requirementGateSummary: AirframeRequirementReleaseGateSummary
        let requirementTraceRows: [AgileCockpitRequirementTraceRow]
        let requirementGapRows: [AgileCockpitRequirementGapRow]
        let testCoverageRows: [AgileCockpitTestCoverageRow]
        let testGapRows: [AgileCockpitTestGapRow]
    }

    let coreInfo: AirframeCoreInfo
    let context: AirframeProjectContext
    let configurationDiagnostics: AirframeConfigurationDiagnostics

    @Published private(set) var records: [AirframeLocalWorkRecord]
    @Published private(set) var dashboardRecords: [AirframeLocalWorkRecord]
    @Published private(set) var dashboardDetailTextByID: [AirframeID: String]
    @Published private(set) var summary: AirframeDashboardSummary
    @Published private(set) var canonicalSnapshot: AirframeCanonicalStateSnapshot
    @Published private(set) var canonicalDiagnostics: AirframeCanonicalDiagnostics
    @Published private(set) var auditRows: [AgileCockpitAuditRow]
    @Published private(set) var requirementCoverageSummary: AirframeRequirementCoverageSummary
    @Published private(set) var requirementGateSummary: AirframeRequirementReleaseGateSummary
    @Published private(set) var requirementTraceRows: [AgileCockpitRequirementTraceRow]
    @Published private(set) var requirementGapRows: [AgileCockpitRequirementGapRow]
    @Published private(set) var testCoverageRows: [AgileCockpitTestCoverageRow]
    @Published private(set) var testGapRows: [AgileCockpitTestGapRow]
    @Published var selectedTestID: AirframeID?
    @Published private(set) var verificationQueueState: AgileCockpitVerificationQueueState
    @Published private(set) var verificationDetailState: AgileCockpitVerificationDetailState
    @Published private(set) var verificationActionState: AgileCockpitVerificationActionState
    @Published var selectedSection: AgileCockpitSection
    @Published var selectedWorkItemID: AirframeID?
    @Published var selectedStatusSelection: AgileCockpitStatusSelection?
    @Published var selectedStatusWorkItemID: AirframeID?
    @Published var selectedPlanningTab: AgileCockpitPlanningTab
    @Published var selectedReviewSprintID: AirframeID?
    @Published var selectedEpicCriterionID: AirframeID?
    @Published var verificationCommentText: String
    @Published var statusMessage: String

    private let backend: any AirframeBackend
    private let repairBackend: any AirframeBackend
    private let reviewerContext: AirframeCertifiedContext
    private let artifactRootURL: URL?
    private let canonicalRepository: AirframeCanonicalStoreRepository?
    private let canonicalState: AirframeCanonicalStoreState?
    private var auditStore: AirframeAuditEventStore
    private var refreshObserver: NSObjectProtocol?
    private var fileWatchSources: [DispatchSourceFileSystemObject] = []
    private var pendingRefreshWorkItem: DispatchWorkItem?

    fileprivate init(launchData: LaunchData) {
        self.coreInfo = launchData.coreInfo
        self.context = launchData.context
        self.configurationDiagnostics = launchData.configurationDiagnostics
        self.backend = launchData.backend
        self.repairBackend = launchData.repairBackend
        self.reviewerContext = launchData.reviewerContext
        self.artifactRootURL = launchData.artifactRootURL
        self.canonicalRepository = launchData.canonicalRepository
        self.canonicalState = launchData.canonicalState
        self.auditStore = AirframeAuditEventStore()
        self.selectedSection = .dashboard
        self.records = launchData.records
        self.dashboardRecords = launchData.dashboardRecords
        self.dashboardDetailTextByID = launchData.dashboardDetailTextByID
        self.canonicalSnapshot = launchData.canonicalSnapshot
        self.canonicalDiagnostics = launchData.canonicalDiagnostics
        self.summary = launchData.summary
        self.auditRows = launchData.auditRows
        self.requirementCoverageSummary = launchData.requirementCoverageSummary
        self.requirementGateSummary = launchData.requirementGateSummary
        self.requirementTraceRows = launchData.requirementTraceRows
        self.requirementGapRows = launchData.requirementGapRows
        self.testCoverageRows = launchData.testCoverageRows
        self.testGapRows = launchData.testGapRows
        self.selectedTestID = launchData.canonicalSnapshot.tests.first?.id
        self.verificationQueueState = .loaded
        self.verificationDetailState = .empty
        self.verificationActionState = .idle
        self.selectedWorkItemID = launchData.records.first { $0.workItem.status == .implementedNotVerified }?.workItem.id
        self.selectedStatusSelection = nil
        self.selectedStatusWorkItemID = nil
        self.selectedPlanningTab = .sprintWork
        self.selectedReviewSprintID = nil
        self.selectedEpicCriterionID = nil
        self.verificationCommentText = ""
        self.statusMessage = "Loaded \(launchData.backend.capabilities.backendKind) Airframe workspace."
        loadSelectedVerificationDetail()
        startRefreshObservation(observedURLs: launchData.observedURLs)
    }

    init(
        coreInfo: AirframeCoreInfo = .current,
        context: AirframeProjectContext,
        backend: any AirframeBackend,
        repairBackend: (any AirframeBackend)? = nil,
        reviewerContext: AirframeCertifiedContext,
        auditStore: AirframeAuditEventStore = AirframeAuditEventStore(),
        selectedSection: AgileCockpitSection = .dashboard,
        observedURLs: [URL] = [],
        artifactRootURL: URL? = nil
    ) throws {
        self.coreInfo = coreInfo
        self.context = context
        self.configurationDiagnostics = AirframeConfigurationLoader().diagnostics(for: context.configuration)
        self.backend = backend
        self.repairBackend = repairBackend ?? backend
        self.reviewerContext = reviewerContext
        self.artifactRootURL = artifactRootURL
        if let artifactRootURL,
           FileManager.default.fileExists(atPath: artifactRootURL.appending(path: ".airframe/state").path) {
            let repository = AirframeCanonicalStoreRepository(rootURL: artifactRootURL)
            self.canonicalRepository = repository
            self.canonicalState = try? repository.loadState()
        } else {
            self.canonicalRepository = nil
            self.canonicalState = nil
        }
        self.auditStore = auditStore
        self.selectedSection = selectedSection
        let loadedRecords = try backend.listWorkRecords()
        self.records = loadedRecords
        let dashboardData = Self.dashboardData(
            backendRecords: loadedRecords,
            artifactRootURL: artifactRootURL,
            preferBackendRecords: self.canonicalRepository != nil
        )
        self.dashboardRecords = dashboardData.records
        self.dashboardDetailTextByID = dashboardData.detailTextByID
        let canonicalSnapshot = try Self.canonicalSnapshot(
            context: context,
            records: dashboardData.records,
            canonicalRepository: canonicalRepository
        )
        self.canonicalSnapshot = canonicalSnapshot
        let canonicalDiagnostics = Self.canonicalDiagnostics(
            snapshot: canonicalSnapshot,
            canonicalRecords: dashboardData.records,
            backendRecords: loadedRecords
        )
        self.canonicalDiagnostics = canonicalDiagnostics
        self.summary = Self.canonicalSummary(records: dashboardData.records)
        self.auditRows = auditStore.events.map(Self.auditRow)
        let requirementState = Self.requirementState(
            canonicalState: self.canonicalState,
            canonicalSnapshot: canonicalSnapshot
        )
        let testState = Self.testState(
            canonicalSnapshot: canonicalSnapshot,
            canonicalDiagnostics: canonicalDiagnostics
        )
        self.requirementCoverageSummary = requirementState.coverage
        self.requirementGateSummary = requirementState.gate
        self.requirementTraceRows = requirementState.traceRows
        self.requirementGapRows = requirementState.gapRows
        self.testCoverageRows = testState.coverageRows
        self.testGapRows = testState.gapRows
        self.selectedTestID = canonicalSnapshot.tests.first?.id
        self.verificationQueueState = .loaded
        self.verificationDetailState = .empty
        self.verificationActionState = .idle
        self.selectedWorkItemID = loadedRecords.first { $0.workItem.status == .implementedNotVerified }?.workItem.id
        self.selectedStatusSelection = nil
        self.selectedStatusWorkItemID = nil
        self.selectedPlanningTab = .sprintWork
        self.selectedReviewSprintID = nil
        self.selectedEpicCriterionID = nil
        self.verificationCommentText = ""
        self.statusMessage = "Loaded \(backend.capabilities.backendKind) Airframe workspace."
        loadSelectedVerificationDetail()
        startRefreshObservation(observedURLs: observedURLs)
    }

    fileprivate init(
        launchPayload payload: LaunchCachePayload,
        backend: any AirframeBackend,
        repairBackend: any AirframeBackend,
        reviewerContext: AirframeCertifiedContext,
        canonicalRepository: AirframeCanonicalStoreRepository?,
        canonicalState: AirframeCanonicalStoreState?
    ) {
        self.coreInfo = .current
        self.context = AirframeProjectContext(
            configuration: payload.configuration,
            project: payload.project
        )
        self.configurationDiagnostics = payload.configurationDiagnostics
        self.backend = backend
        self.repairBackend = repairBackend
        self.reviewerContext = reviewerContext
        self.artifactRootURL = payload.artifactRootPath.map { URL(fileURLWithPath: $0) }
        self.canonicalRepository = canonicalRepository
        self.canonicalState = canonicalState ?? payload.canonicalState.map(Self.cachedState(from:))
        self.auditStore = AirframeAuditEventStore()
        self.selectedSection = .dashboard
        self.records = payload.records
        self.dashboardRecords = payload.dashboardRecords
        self.dashboardDetailTextByID = Dictionary(
            uniqueKeysWithValues: payload.dashboardDetailTextByID.map { (AirframeID($0.key), $0.value) }
        )
        self.canonicalSnapshot = Self.cachedSnapshot(from: payload.canonicalSnapshot)
        self.canonicalDiagnostics = payload.canonicalDiagnostics
        self.summary = payload.summary
        self.auditRows = payload.auditRows
        self.requirementCoverageSummary = payload.requirementCoverageSummary
        self.requirementGateSummary = payload.requirementGateSummary
        self.requirementTraceRows = payload.requirementTraceRows
        self.requirementGapRows = payload.requirementGapRows
        self.testCoverageRows = payload.testCoverageRows
        self.testGapRows = payload.testGapRows
        self.selectedTestID = payload.canonicalSnapshot.tests.first?.id
        self.verificationQueueState = .loaded
        self.verificationDetailState = .empty
        self.verificationActionState = .idle
        self.selectedWorkItemID = payload.records.first { $0.workItem.status == .implementedNotVerified }?.workItem.id
        self.selectedStatusSelection = nil
        self.selectedStatusWorkItemID = nil
        self.selectedPlanningTab = .sprintWork
        self.selectedReviewSprintID = nil
        self.selectedEpicCriterionID = nil
        self.verificationCommentText = ""
        self.statusMessage = "Loaded \(backend.capabilities.backendKind) Airframe workspace."
        loadSelectedVerificationDetail()
        startRefreshObservation(observedURLs: payload.observedURLs)
    }

    deinit {
        refreshObserver.map { DistributedNotificationCenter.default().removeObserver($0) }
        fileWatchSources.forEach { $0.cancel() }
        pendingRefreshWorkItem?.cancel()
    }

    static func sample() throws -> AgileCockpitDashboardModel {
        let context = try AirframeConfigurationLoader().loadSampleContext()
        let storeURL = FileManager.default.temporaryDirectory
            .appending(path: "AgileCockpitSample")
            .appending(path: UUID().uuidString)
            .appending(path: "airframe-local-backend.json")
        let backend = AirframeGitHubFixtureBackend(
            storeURL: storeURL,
            configuration: AirframeGitHubBackendConfiguration(repositorySlug: context.project.repository)
        )

        for record in sampleRecords {
            try backend.createWorkRecord(record)
        }
        try backend.attachEvidence(
            AirframeEvidence(
                id: AirframeID("EV-0042-001"),
                summary: "CLI output contract hardening notes are ready for review.",
                artifact: "docs/CLI-Output-Contracts.md"
            ),
            to: AirframeID("T-0042")
        )

        var auditStore = AirframeAuditEventStore()
        let reviewer = try humanReviewerContext(projectID: context.project.id)
        auditStore.record(
            id: AirframeID("AUD-AGILE-0001"),
            context: reviewer,
            action: "OP-READ-DASHBOARD",
            workItemID: nil,
            decision: .allowed(),
            targetProjectID: context.project.id,
            timestamp: Date(timeIntervalSince1970: 0)
        )

        return try AgileCockpitDashboardModel(
            context: context,
            backend: backend,
            reviewerContext: reviewer,
            auditStore: auditStore,
            observedURLs: [storeURL],
            artifactRootURL: nil
        )
    }

    static func configured(
        configurationURL: URL? = nil,
        storeURL: URL? = nil,
        environment: [String: String] = ProcessInfo.processInfo.environment,
        currentDirectoryURL: URL = URL(filePath: FileManager.default.currentDirectoryPath),
        githubIssueTransport: (any AirframeGitHubIssueTransport)? = nil
    ) throws -> AgileCockpitDashboardModel {
        let resolver = AirframeRuntimeConfigurationResolver(
            environment: environment,
            currentDirectoryURL: currentDirectoryURL
        )
        guard let resolvedConfigurationURL = resolver.configurationURL(explicitPath: configurationURL?.path) else {
            throw AirframeConfigurationError.missingFile(".airframe/airframe-workspace.json")
        }

        let context = try resolver.loadContext(explicitPath: configurationURL?.path)
        let resolvedStoreURL = resolver.storeURL(explicitPath: storeURL?.path)
        let artifactRootURL = Self.artifactRootURL(
            configurationURL: resolvedConfigurationURL,
            context: context
        )
        let backend = try configuredBackend(
            for: context,
            artifactRootURL: artifactRootURL,
            storeURL: resolvedStoreURL,
            githubIssueTransport: githubIssueTransport
        )
        let repairBackend = try configuredRepairBackend(
            for: context,
            artifactRootURL: artifactRootURL,
            fallbackBackend: backend,
            githubIssueTransport: githubIssueTransport
        )
        let reviewer = try humanReviewerContext(projectID: context.project.id)

        return try AgileCockpitDashboardModel(
            context: context,
            backend: backend,
            repairBackend: repairBackend,
            reviewerContext: reviewer,
            observedURLs: [resolvedConfigurationURL, resolvedStoreURL, artifactRootURL.appending(path: ".airframe/state")],
            artifactRootURL: artifactRootURL
        )
    }

    nonisolated fileprivate static func prepareLaunchData(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        currentDirectoryURL: URL = URL(filePath: FileManager.default.currentDirectoryPath),
        progress: @Sendable (Double, String) -> Void = { _, _ in }
    ) throws -> LaunchData {
        let resolver = AirframeRuntimeConfigurationResolver(
            environment: environment,
            currentDirectoryURL: currentDirectoryURL
        )

        progress(0.05, "Resolving workspace.")
        guard let configurationURL = resolver.configurationURL() else {
            let context = try AirframeConfigurationLoader().loadSampleContext()
            let backend = AgileCockpitUnavailableBackend(
                capabilities: .githubIssuesReadOnly,
                error: AirframeConfigurationError.missingFile(".airframe/airframe-workspace.json")
            )
            let reviewer = try humanReviewerContext(projectID: context.project.id)
            let canonicalSnapshot = AirframeCanonicalStateSnapshotBuilder().snapshot(
                project: context.project,
                records: []
            )
            let diagnostics = Self.canonicalDiagnostics(
                snapshot: canonicalSnapshot,
                canonicalRecords: [],
                backendRecords: []
            )
            let traceabilityState = Self.traceabilityState(
                canonicalState: nil,
                canonicalSnapshot: canonicalSnapshot,
                canonicalDiagnostics: diagnostics,
                artifactRootURL: nil
            )
            let payload = cachedPayload(
                context: context,
                configurationDiagnostics: AirframeConfigurationLoader().diagnostics(for: context.configuration),
                artifactRootURL: nil,
                observedURLs: [],
                canonicalState: nil,
                canonicalSnapshot: canonicalSnapshot,
                records: [],
                dashboardData: (records: [], detailTextByID: [:]),
                canonicalDiagnostics: diagnostics,
                summary: Self.canonicalSummary(records: []),
                auditRows: [],
                requirementCoverageSummary: traceabilityState.requirementCoverageSummary,
                requirementGateSummary: traceabilityState.requirementGateSummary,
                requirementTraceRows: traceabilityState.requirementTraceRows,
                requirementGapRows: traceabilityState.requirementGapRows,
                testCoverageRows: traceabilityState.testCoverageRows,
                testGapRows: traceabilityState.testGapRows
            )
            let launchRootURL = Self.launchRootURL(
                configurationURL: nil,
                currentDirectoryURL: currentDirectoryURL
            )
            saveLaunchCache(
                payload,
                fingerprint: "sample:\(currentDirectoryURL.path)",
                to: launchCacheURL(rootURL: launchRootURL)
            )
            progress(1.0, "Workspace ready.")
            return LaunchData(
                launchPayload: payload,
                backend: backend,
                repairBackend: backend,
                reviewerContext: reviewer,
                canonicalRepository: nil,
                canonicalState: nil
            )
        }

        let context = try resolver.loadContext(explicitPath: configurationURL.path)
        let resolvedStoreURL = resolver.storeURL()
        let artifactRootURL = Self.artifactRootURL(
            configurationURL: configurationURL,
            context: context
        )
        let fingerprint = launchFingerprint(
            configurationURL: configurationURL,
            storeURL: resolvedStoreURL,
            artifactRootURL: artifactRootURL,
            canonicalRepositoryExists: canonicalRepositoryExists(at: artifactRootURL)
        )

        let launchRootURL = Self.launchRootURL(
            configurationURL: configurationURL,
            currentDirectoryURL: currentDirectoryURL
        )

        if let cachedPayload = loadLaunchCache(
            from: launchCacheURL(rootURL: launchRootURL),
            fingerprint: fingerprint
        ) {
            progress(0.9, "Loaded cached workspace state.")
            let backend = try configuredBackend(
                for: context,
                artifactRootURL: artifactRootURL,
                storeURL: resolvedStoreURL,
                githubIssueTransport: nil
            )
            let repairBackend = try configuredRepairBackend(
                for: context,
                artifactRootURL: artifactRootURL,
                fallbackBackend: backend,
                githubIssueTransport: nil
            )
            let reviewer = try humanReviewerContext(projectID: context.project.id)
            let canonicalRepository = canonicalRepositoryExists(at: artifactRootURL)
                ? AirframeCanonicalStoreRepository(rootURL: artifactRootURL)
                : nil
            let canonicalState = cachedPayload.canonicalState.map(Self.cachedState(from:))
            progress(1.0, "Workspace ready.")
            return LaunchData(
                launchPayload: cachedPayload,
                backend: backend,
                repairBackend: repairBackend,
                reviewerContext: reviewer,
                canonicalRepository: canonicalRepository,
                canonicalState: canonicalState
            )
        }

        progress(0.2, "Loading configuration.")
        let backend = try configuredBackend(
            for: context,
            artifactRootURL: artifactRootURL,
            storeURL: resolvedStoreURL,
            githubIssueTransport: nil
        )
        progress(0.35, "Preparing backend.")
        let repairBackend = try configuredRepairBackend(
            for: context,
            artifactRootURL: artifactRootURL,
            fallbackBackend: backend,
            githubIssueTransport: nil
        )
        let reviewer = try humanReviewerContext(projectID: context.project.id)
        progress(0.5, "Loading work records.")
        let loadedRecords = try backend.listWorkRecords()
        let dashboardData = Self.dashboardData(
            backendRecords: loadedRecords,
            artifactRootURL: artifactRootURL,
            preferBackendRecords: canonicalRepositoryExists(at: artifactRootURL)
        )
        let canonicalRepository = canonicalRepositoryExists(at: artifactRootURL)
            ? AirframeCanonicalStoreRepository(rootURL: artifactRootURL)
            : nil
        progress(0.7, "Building canonical snapshot.")
        let canonicalSnapshot = try Self.canonicalSnapshot(
            context: context,
            records: dashboardData.records,
            canonicalRepository: canonicalRepository
        )
        let diagnostics = Self.canonicalDiagnostics(
            snapshot: canonicalSnapshot,
            canonicalRecords: dashboardData.records,
            backendRecords: loadedRecords
        )
        let canonicalState = try? canonicalRepository?.loadState()
        progress(0.85, "Computing traceability.")
        let traceabilityState = Self.traceabilityState(
            canonicalState: canonicalState,
            canonicalSnapshot: canonicalSnapshot,
            canonicalDiagnostics: diagnostics,
            artifactRootURL: artifactRootURL
        )
        let payload = cachedPayload(
            context: context,
            configurationDiagnostics: AirframeConfigurationLoader().diagnostics(for: context.configuration),
            artifactRootURL: artifactRootURL,
            observedURLs: [configurationURL, resolvedStoreURL, artifactRootURL.appending(path: ".airframe/state")],
            canonicalState: canonicalState,
            canonicalSnapshot: canonicalSnapshot,
            records: loadedRecords,
            dashboardData: dashboardData,
            canonicalDiagnostics: diagnostics,
            summary: Self.canonicalSummary(records: dashboardData.records),
            auditRows: [],
            requirementCoverageSummary: traceabilityState.requirementCoverageSummary,
            requirementGateSummary: traceabilityState.requirementGateSummary,
            requirementTraceRows: traceabilityState.requirementTraceRows,
            requirementGapRows: traceabilityState.requirementGapRows,
            testCoverageRows: traceabilityState.testCoverageRows,
            testGapRows: traceabilityState.testGapRows
        )
        progress(0.95, "Saving launch cache.")
        saveLaunchCache(
            payload,
            fingerprint: fingerprint,
            to: launchCacheURL(rootURL: launchRootURL)
        )
        progress(1.0, "Workspace ready.")
        return LaunchData(
            launchPayload: payload,
            backend: backend,
            repairBackend: repairBackend,
            reviewerContext: reviewer,
            canonicalRepository: canonicalRepository,
            canonicalState: canonicalState
        )
    }

    nonisolated fileprivate static func cachedLaunchDataForImmediateDisplay(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        currentDirectoryURL: URL = URL(filePath: FileManager.default.currentDirectoryPath)
    ) throws -> LaunchData? {
        let resolver = AirframeRuntimeConfigurationResolver(
            environment: environment,
            currentDirectoryURL: currentDirectoryURL
        )
        let configurationURL = resolver.configurationURL()
        let launchRootURL = Self.launchRootURL(
            configurationURL: configurationURL,
            currentDirectoryURL: currentDirectoryURL
        )
        guard let cachedPayload = loadAnyLaunchCache(from: launchCacheURL(rootURL: launchRootURL)) else {
            return nil
        }

        let context = AirframeProjectContext(
            configuration: cachedPayload.configuration,
            project: cachedPayload.project
        )
        let artifactRootURL = cachedPayload.artifactRootPath.map { URL(fileURLWithPath: $0) }
            ?? configurationURL.map { Self.artifactRootURL(configurationURL: $0, context: context) }
        guard let artifactRootURL else {
            return nil
        }

        let backend = try configuredBackend(
            for: context,
            artifactRootURL: artifactRootURL,
            storeURL: resolver.storeURL(),
            githubIssueTransport: nil
        )
        let repairBackend = try configuredRepairBackend(
            for: context,
            artifactRootURL: artifactRootURL,
            fallbackBackend: backend,
            githubIssueTransport: nil
        )
        let reviewer = try humanReviewerContext(projectID: context.project.id)
        let canonicalRepository = canonicalRepositoryExists(at: artifactRootURL)
            ? AirframeCanonicalStoreRepository(rootURL: artifactRootURL)
            : nil
        let canonicalState = cachedPayload.canonicalState.map(Self.cachedState(from:))
        return LaunchData(
            launchPayload: cachedPayload,
            backend: backend,
            repairBackend: repairBackend,
            reviewerContext: reviewer,
            canonicalRepository: canonicalRepository,
            canonicalState: canonicalState
        )
    }

    static func launch(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        currentDirectoryURL: URL = URL(filePath: FileManager.default.currentDirectoryPath)
    ) -> AgileCockpitDashboardModel {
        let resolver = AirframeRuntimeConfigurationResolver(
            environment: environment,
            currentDirectoryURL: currentDirectoryURL
        )

        guard resolver.configurationURL() != nil else {
            return (try? sample()) ?? fallback(message: "Sample workspace unavailable.")
        }

        do {
            return try configured(environment: environment, currentDirectoryURL: currentDirectoryURL)
        } catch {
            if let context = try? resolver.loadContext() {
                return unavailable(context: context, error: error)
            }
            return fallback(message: "Configuration load failed: \(error)")
        }
    }

    static func unavailable(context: AirframeProjectContext, error: Error) -> AgileCockpitDashboardModel {
        let backend = AgileCockpitUnavailableBackend(
            capabilities: capabilities(for: context.configuration.backend.kind),
            error: error
        )
        let reviewer = (try? humanReviewerContext(projectID: context.project.id)) ?? fallbackReviewer(projectID: context.project.id)
        let model = try! AgileCockpitDashboardModel(
            context: context,
            backend: backend,
            reviewerContext: reviewer
        )
        model.statusMessage = "Live project load failed: \(error)"
        return model
    }

    var projectStatusText: String {
        "\(context.projectName) | \(context.project.repository)"
    }

    var appStatusText: String {
        "Agile Cockpit | \(context.workspaceName)"
    }

    var backendStatusText: String {
        let capabilities = backend.capabilities
        let githubStatus = capabilities.supportsGitHubIssues ? "GitHub issue mapping on" : "GitHub issue mapping off"
        return "\(capabilities.backendKind) | \(githubStatus)"
    }

    var configurationStatusText: String {
        "Configuration \(configurationDiagnostics.status.rawValue) | \(configurationDiagnostics.projectCount) project(s)"
    }

    var activeSprintText: String {
        currentSprintID?.rawValue ?? "None"
    }

    var activeEpicText: String {
        currentEpicID?.rawValue ?? "None"
    }

    var activeRecords: [AirframeLocalWorkRecord] {
        recordsWithStatus(.active)
    }

    var readyRecords: [AirframeLocalWorkRecord] {
        recordsWithStatus(.implementedNotVerified)
    }

    var verifiedRecords: [AirframeLocalWorkRecord] {
        recordsWithStatus(.implementedVerified)
    }

    var upcomingRecords: [AirframeLocalWorkRecord] {
        recordsWithStatus(.backlog)
    }

    var blockedRecords: [AirframeLocalWorkRecord] {
        []
    }

    var selectedRecord: AirframeLocalWorkRecord? {
        guard let selectedWorkItemID else { return readyRecords.first }
        return records.first { $0.workItem.id == selectedWorkItemID } ?? readyRecords.first
    }

    var selectedPacket: AirframeTaskPacket? {
        if case .loaded(let packet) = verificationDetailState {
            return packet
        }
        return nil
    }

    var metrics: [AgileCockpitMetric] {
        [
            AgileCockpitMetric(id: "active", title: "Active", value: "\(summary.activeTaskCount)"),
            AgileCockpitMetric(id: "ready", title: "Ready", value: "\(summary.unverifiedTaskCount)"),
            AgileCockpitMetric(id: "verified", title: "Verified", value: "\(summary.verifiedTaskCount)"),
            AgileCockpitMetric(id: "issues", title: "Issues", value: "\(summary.issueCount)"),
            AgileCockpitMetric(id: "evidence", title: "Evidence", value: "\(summary.recentEvidenceCount)")
        ]
    }

    var dataHealthStatusText: String {
        let count = canonicalDiagnostics.diagnostics.count
        return count == 1
            ? "\(canonicalDiagnostics.status.rawValue) | 1 diagnostic"
            : "\(canonicalDiagnostics.status.rawValue) | \(count) diagnostics"
    }

    var diagnosticRows: [AgileCockpitDiagnosticRow] {
        canonicalDiagnostics.diagnostics.map { diagnostic in
            AgileCockpitDiagnosticRow(
                id: "\(diagnostic.reasonCode.rawValue)-\(diagnostic.affectedIDs.map(\.rawValue).joined(separator: "-"))",
                severity: diagnostic.severity.rawValue,
                reason: diagnostic.reasonCode.rawValue,
                message: diagnostic.message,
                affectedIDs: diagnostic.affectedIDs.map(\.rawValue).joined(separator: ", ")
            )
        }
    }

    var repairPreviewRows: [AgileCockpitRepairPreviewRow] {
        canonicalDiagnostics.diagnostics.flatMap { diagnostic in
            diagnostic.repairOptions.map { option in
                AgileCockpitRepairPreviewRow(
                    id: "\(diagnostic.reasonCode.rawValue)-\(option.action.rawValue)-\(option.affectedIDs.map(\.rawValue).joined(separator: "-"))",
                    action: option.action,
                    title: option.title,
                    affectedIDs: option.affectedIDs,
                    requiresHumanApproval: option.requiresHumanApproval
                )
            }
        }
    }

    var isVerificationActionPending: Bool {
        if case .pending = verificationActionState {
            return true
        }
        return false
    }

    var verificationActionStatusText: String? {
        switch verificationActionState {
        case .idle:
            nil
        case .pending(let id, let action):
            "\(id.rawValue) \(action) pending."
        case .failed(_, let message):
            message
        case .completed(let message):
            message
        }
    }

    var statusTiles: [AirframeDashboardStatusTile] {
        AirframeDashboardStatusSummary(records: canonicalDashboardRecords).tiles
    }

    var sprintRecords: [AirframeLocalWorkRecord] {
        canonicalDashboardRecords.filter { $0.sprintID == currentSprintID }
    }

    var epicRecords: [AirframeLocalWorkRecord] {
        canonicalDashboardRecords.filter { $0.epicID == currentEpicID }
    }

    var activeEpicRecord: AirframeLocalWorkRecord? {
        guard let activeEpicID = currentEpicID else { return nil }
        return canonicalDashboardRecords.first {
            $0.workItem.kind == .epic && $0.workItem.id == activeEpicID
        }
    }

    var activeSprintRecord: AirframeLocalWorkRecord? {
        guard let activeSprintID = currentSprintID else { return nil }
        return canonicalDashboardRecords.first {
            $0.workItem.kind == .sprint && $0.workItem.id == activeSprintID
        }
    }

    var reviewSprintRecords: [AirframeCanonicalSprintRecord] {
        canonicalSnapshot.sprints
            .filter { $0.workItem.status == .review }
            .sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }
    }

    var selectedReviewSprintRecord: AirframeCanonicalSprintRecord? {
        if let selectedReviewSprintID,
           let selected = reviewSprintRecords.first(where: { $0.workItem.id == selectedReviewSprintID }) {
            return selected
        }
        return reviewSprintRecords.first
    }

    var selectedReviewSprintWorkRecords: [AirframeLocalWorkRecord] {
        guard let sprintID = selectedReviewSprintRecord?.workItem.id else { return [] }
        return canonicalDashboardRecords
            .filter {
                $0.sprintID == sprintID &&
                [.task, .issue].contains($0.workItem.kind)
            }
            .sorted {
                if $0.workItem.kind != $1.workItem.kind {
                    return $0.workItem.kind == .task
                }
                return $0.workItem.id.rawValue < $1.workItem.id.rawValue
            }
    }

    var epicAcceptanceCriteriaSummary: AirframeEpicAcceptanceCriteriaSummary? {
        guard let activeEpicID = currentEpicID else { return nil }
        if let canonicalSummary = try? canonicalRepository?.epicCriteriaSummary(epicID: activeEpicID),
           canonicalSummary.hasCriteria {
            return canonicalSummary
        }
        let criteria = activeEpicRecord?.acceptanceCriteria.enumerated().map { index, text in
            Self.epicAcceptanceCriterion(
                epicID: activeEpicID,
                index: index,
                rawText: text
            )
        } ?? []
        return AirframeEpicAcceptanceCriteriaSummary(epicID: activeEpicID, criteria: criteria)
    }

    var sprintCloseEligibility: AirframeSprintCloseEligibility? {
        guard let activeSprintID = currentSprintID else { return nil }
        return AirframeSprintCloseEligibility(
            sprintID: activeSprintID,
            assignedWorkItems: sprintRecords.map(\.workItem)
        )
    }

    var epicCloseEligibility: AirframeEpicCloseEligibility? {
        guard let summary = epicAcceptanceCriteriaSummary else { return nil }
        let activeEpicID = summary.epicID
        let relatedSprints = canonicalSnapshot.sprints
            .filter { $0.epicID == activeEpicID }
            .map(\.workItem)
        return AirframeEpicCloseEligibility(
            criteriaSummary: summary,
            relatedSprints: relatedSprints
        )
    }

    var selectedEpicAcceptanceCriterion: AirframeEpicAcceptanceCriterion? {
        guard let summary = epicAcceptanceCriteriaSummary else { return nil }
        if let selectedEpicCriterionID,
           let selected = summary.criteria.first(where: { $0.id == selectedEpicCriterionID }) {
            return selected
        }
        return summary.criteria.first
    }

    var selectedStatusRecord: AirframeLocalWorkRecord? {
        guard let selectedStatusWorkItemID else { return nil }
        return canonicalDashboardRecords.first { $0.workItem.id == selectedStatusWorkItemID }
    }

    var testRows: [AgileCockpitTestRow] {
        canonicalSnapshot.tests.map {
            AgileCockpitTestRow(
                id: $0.id.rawValue,
                title: $0.title,
                objective: $0.objective,
                kind: $0.kind.rawValue,
                status: $0.status.rawValue,
                requirementIDs: $0.requirementIDs.map(\.rawValue).joined(separator: ", "),
                acceptanceCriterionIDs: $0.acceptanceCriterionIDs.map(\.rawValue).joined(separator: ", "),
                workItemIDs: $0.workItemIDs.map(\.rawValue).joined(separator: ", ")
            )
        }
    }

    var selectedTestRecord: AirframeCanonicalTestRecord? {
        guard let selectedTestID else {
            return canonicalSnapshot.tests.first
        }
        return canonicalSnapshot.tests.first { $0.id == selectedTestID } ?? canonicalSnapshot.tests.first
    }

    private var currentSprintID: AirframeID? {
        if let configuredSprintID = canonicalSnapshot.project.activeSprintID {
            return configuredSprintID
        }
        let activeSprintIDs = canonicalSnapshot.sprints
            .filter { $0.workItem.status == .active }
            .map(\.workItem.id)
            .sorted { $0.rawValue < $1.rawValue }
        return activeSprintIDs.count == 1 ? activeSprintIDs[0] : nil
    }

    private var currentEpicID: AirframeID? {
        let configuredEpicID = canonicalSnapshot.project.activeEpicID
        let activeEpicIDs = canonicalSnapshot.epics
            .filter { $0.workItem.status == .active }
            .map(\.workItem.id)
            .sorted { $0.rawValue < $1.rawValue }
        if activeEpicIDs.count == 1,
           let soleActiveEpicID = activeEpicIDs.first,
           configuredEpicID == nil || configuredEpicID != soleActiveEpicID {
            return soleActiveEpicID
        }
        if let configuredEpicID {
            return configuredEpicID
        }
        return nil
    }

    var selectedStatusDetailText: String? {
        guard let selectedStatusWorkItemID else { return nil }
        guard let detailText = dashboardDetailTextByID[selectedStatusWorkItemID] else {
            return nil
        }
        guard let canonicalDetailText = canonicalRelationshipDetailText(for: selectedStatusWorkItemID) else {
            return detailText
        }
        return "\(detailText)\n\n---\n\(canonicalDetailText)"
    }

    func showStatusItems(tile: AirframeDashboardStatusTile, row: AirframeDashboardStatusRow) {
        selectedStatusSelection = AgileCockpitStatusSelection(tile: tile, row: row)
        selectedStatusWorkItemID = nil
    }

    func selectVerificationWorkItem(_ id: AirframeID?) {
        guard selectedWorkItemID != id else { return }
        selectedWorkItemID = id
        verificationActionState = .idle
        loadSelectedVerificationDetail()
    }

    func retryVerificationLoad() {
        verificationQueueState = .loading
        do {
            try reload(selecting: selectedWorkItemID)
            verificationQueueState = .loaded
            statusMessage = "Verification Queue reloaded."
        } catch {
            verificationQueueState = .failed("\(error)")
            statusMessage = "Verification Queue load failed: \(error)"
        }
    }

    func selectEpicAcceptanceCriterion(_ criterion: AirframeEpicAcceptanceCriterion) {
        selectedEpicCriterionID = criterion.id
    }

    func selectTest(_ test: AirframeCanonicalTestRecord) {
        selectedTestID = test.id
    }

    func selectReviewSprint(_ sprint: AirframeCanonicalSprintRecord) {
        selectedReviewSprintID = sprint.workItem.id
    }

    func verifySelectedEpicAcceptanceCriterion() {
        guard let criterion = selectedEpicAcceptanceCriterion else {
            statusMessage = "No Epic acceptance criterion is selected."
            return
        }
        guard !criterion.isVerified else {
            statusMessage = "\(criterion.id.rawValue) is already verified."
            return
        }
        guard currentEpicID != nil else {
            statusMessage = "No active Epic is configured."
            return
        }

        do {
            guard let canonicalRepository else {
                statusMessage = "Epic criteria verification requires canonical Airframe state."
                return
            }
            try canonicalRepository.verifyEpicCriterion(id: criterion.id)
            auditStore.record(
                id: AirframeID("AUD-AGILE-\(auditStore.events.count + 1)"),
                context: reviewerContext,
                action: "OP-HUMAN-VERIFY-EPIC-CRITERION",
                workItemID: criterion.id,
                decision: .allowed(),
                targetProjectID: context.project.id
            )
            try reload(selecting: selectedWorkItemID)
            selectedEpicCriterionID = criterion.id
            statusMessage = "\(criterion.id.rawValue) verified."
        } catch {
            statusMessage = "Epic criteria verification failed: \(error)"
        }
    }

    func closeActiveSprint() {
        guard let activeSprintID = currentSprintID else {
            statusMessage = "No active Sprint is configured."
            return
        }
        guard let activeSprintRecord else {
            statusMessage = "Configured active Sprint \(activeSprintID.rawValue) was not found."
            return
        }
        guard let eligibility = sprintCloseEligibility else {
            statusMessage = "Sprint close eligibility is unavailable."
            return
        }
        guard eligibility.eligibility.isEligible else {
            statusMessage = "Sprint \(activeSprintID.rawValue) cannot close: \(eligibility.eligibility.blockingReasons.joined(separator: " "))"
            return
        }
        do {
            guard let canonicalRepository else {
                statusMessage = "Sprint close requires canonical Airframe state."
                return
            }
            switch activeSprintRecord.workItem.status {
            case .active:
                try canonicalRepository.transitionWorkItem(id: activeSprintID, to: .review)
                recordCloseAudit(action: "OP-HUMAN-REVIEW-SPRINT", workItemID: activeSprintID)
                try reload(selecting: selectedWorkItemID)
                statusMessage = "Sprint \(activeSprintID.rawValue) close accepted: moved to Review."
            case .review:
                try canonicalRepository.transitionWorkItem(id: activeSprintID, to: .closed)
                try canonicalRepository.clearActiveSprintID(projectID: context.project.id)
                try synchronizeMarkdownProjections()
                recordCloseAudit(action: "OP-HUMAN-CLOSE-SPRINT", workItemID: activeSprintID)
                try reload(selecting: selectedWorkItemID)
                statusMessage = "Sprint \(activeSprintID.rawValue) closed."
            default:
                statusMessage = "Sprint \(activeSprintID.rawValue) cannot close from \(activeSprintRecord.workItem.status.description)."
            }
        } catch {
            statusMessage = "Sprint close failed: \(error)"
        }
    }

    func returnSelectedReviewSprintToBacklog() {
        guard let reviewSprint = selectedReviewSprintRecord else {
            statusMessage = "No Review Sprint is selected."
            return
        }
        let sprintID = reviewSprint.workItem.id
        guard reviewSprint.workItem.status == .review else {
            statusMessage = "Sprint \(sprintID.rawValue) is \(reviewSprint.workItem.status.description), not Review."
            return
        }
        do {
            guard let canonicalRepository else {
                statusMessage = "Returning a Review Sprint to Backlog requires canonical Airframe state."
                return
            }
            try canonicalRepository.transitionWorkItem(id: sprintID, to: .backlog)
            try synchronizeMarkdownProjections()
            recordCloseAudit(action: "OP-RETURN-SPRINT-TO-BACKLOG", workItemID: sprintID)
            selectedReviewSprintID = nil
            try reload(selecting: selectedWorkItemID)
            statusMessage = "Sprint \(sprintID.rawValue) returned to Backlog."
        } catch {
            statusMessage = "Sprint return to Backlog failed: \(error)"
        }
    }

    func returnActiveSprintToBacklog() {
        guard let activeSprintID = currentSprintID else {
            statusMessage = "No active Sprint is configured."
            return
        }
        guard let activeSprintRecord else {
            statusMessage = "Configured active Sprint \(activeSprintID.rawValue) was not found."
            return
        }
        guard activeSprintRecord.workItem.status == .active else {
            statusMessage = "Sprint \(activeSprintID.rawValue) is \(activeSprintRecord.workItem.status.description), not Active."
            return
        }
        do {
            guard let canonicalRepository else {
                statusMessage = "Returning an Active Sprint to Backlog requires canonical Airframe state."
                return
            }
            try canonicalRepository.transitionWorkItem(id: activeSprintID, to: .backlog)
            try canonicalRepository.clearActiveSprintID(projectID: context.project.id)
            try synchronizeMarkdownProjections()
            recordCloseAudit(action: "OP-RETURN-SPRINT-TO-BACKLOG", workItemID: activeSprintID)
            try reload(selecting: selectedWorkItemID)
            statusMessage = "Sprint \(activeSprintID.rawValue) returned to Backlog."
        } catch {
            statusMessage = "Active Sprint return to Backlog failed: \(error)"
        }
    }

    func closeActiveEpic() {
        guard let activeEpicID = currentEpicID else {
            statusMessage = "No active Epic is configured."
            return
        }
        guard let eligibility = epicCloseEligibility else {
            statusMessage = "Epic close eligibility is unavailable."
            return
        }
        guard eligibility.eligibility.isEligible else {
            statusMessage = "Epic \(activeEpicID.rawValue) cannot close: \(eligibility.eligibility.blockingReasons.joined(separator: " "))"
            return
        }
        do {
            guard let canonicalRepository else {
                statusMessage = "Epic close requires canonical Airframe state."
                return
            }
            try canonicalRepository.transitionWorkItem(id: activeEpicID, to: .closed)
            try canonicalRepository.clearActiveEpicID(projectID: context.project.id)
            try synchronizeMarkdownProjections()
            recordCloseAudit(action: "OP-HUMAN-CLOSE-EPIC", workItemID: activeEpicID)
            try reload(selecting: selectedWorkItemID)
            statusMessage = "Epic \(activeEpicID.rawValue) closed."
        } catch {
            statusMessage = "Epic close failed: \(error)"
        }
    }

    func acceptSelectedWork() {
        apply(.accept)
    }

    func rejectSelectedWork() {
        apply(.reject)
    }

    func requestMoreEvidenceForSelectedWork() {
        apply(.requestMoreEvidence)
    }

    func applyRepair(_ row: AgileCockpitRepairPreviewRow) {
        guard !row.requiresHumanApproval else {
            statusMessage = "\(row.action.rawValue) requires human approval."
            return
        }
        let option = AirframeCanonicalRepairOption(
            action: row.action,
            title: row.title,
            affectedIDs: row.affectedIDs,
            requiresHumanApproval: row.requiresHumanApproval
        )
        do {
            let approval = repairBackend is AirframeGitHubIssuesBackend
                ? AirframeGitHubMutationApproval(
                    isApproved: true,
                    approvedBy: reviewerContext.actor.displayName,
                    reason: "AgileCockpit Data Health repair"
                )
                : nil
            let result = try AirframeCanonicalBackendRepairer().apply(
                repairOption: option,
                canonicalRecords: dashboardRecords,
                backend: repairBackend,
                approval: approval,
                context: reviewerContext,
                targetProjectID: context.project.id
            )
            try reload(selecting: selectedWorkItemID)
            statusMessage = "Applied \(result.appliedCount) repair(s)."
        } catch {
            statusMessage = "Repair failed: \(error)"
        }
    }

    func refreshFromExternalChange(message: String = "Refreshed from Airframe state.") {
        do {
            try reload(selecting: selectedWorkItemID)
            statusMessage = message
        } catch {
            verificationQueueState = .failed("\(error)")
            statusMessage = "Refresh failed: \(error)"
        }
    }

    func refreshFromUserRequest() {
        refreshFromExternalChange(message: "Refreshed from Airframe state.")
    }

    private enum EpicCriterionUpdateError: Error, CustomStringConvertible {
        case criterionNotFound(String)

        var description: String {
            switch self {
            case .criterionNotFound(let id):
                "Could not find acceptance criterion \(id)."
            }
        }
    }

    @available(*, deprecated, message: "Markdown mutation helpers are retained only for migration compatibility; use AirframeCanonicalStoreRepository instead.")
    static func markEpicAcceptanceCriterionVerified(
        _ criterionID: AirframeID,
        epicID: AirframeID,
        in contents: String
    ) throws -> String {
        let targetIndex = criterionIndex(from: criterionID)
        var lines = contents.components(separatedBy: .newlines)
        guard let epicStart = lines.firstIndex(where: { line in
            headingIDAndTitle(from: line, kind: .epic)?.id == epicID
        }) else {
            throw EpicCriterionUpdateError.criterionNotFound(criterionID.rawValue)
        }
        let epicEnd = lines.indices.first { index in
            index > epicStart && headingIDAndTitle(from: lines[index], kind: .epic) != nil
        } ?? lines.endIndex
        guard let criteriaHeading = lines[epicStart..<epicEnd].firstIndex(where: { line in
            normalizedHeading(line) == "acceptance criteria"
        }) else {
            throw EpicCriterionUpdateError.criterionNotFound(criterionID.rawValue)
        }

        var criteriaIndex = 0
        for lineIndex in lines.indices where lineIndex > criteriaHeading && lineIndex < epicEnd {
            let line = lines[lineIndex]
            if line.hasPrefix("##") || line.hasPrefix("**") {
                break
            }
            guard markdownListItem(from: line) != nil else {
                continue
            }
            criteriaIndex += 1
            guard criteriaIndex == targetIndex else {
                continue
            }
            lines[lineIndex] = verifiedCriterionLine(from: line)
            return lines.joined(separator: "\n")
        }

        throw EpicCriterionUpdateError.criterionNotFound(criterionID.rawValue)
    }

    private enum ArtifactStatusUpdateError: Error, CustomStringConvertible {
        case workItemNotFound(String)

        var description: String {
            switch self {
            case .workItemNotFound(let id):
                "Could not find work item \(id)."
            }
        }
    }

    @available(*, deprecated, message: "Markdown mutation helpers are retained only for migration compatibility; use AirframeCanonicalStoreRepository instead.")
    static func replacingArtifactStatus(
        for workItemID: AirframeID,
        kind: AirframeWorkItemKind,
        with status: AirframeWorkStatus,
        in contents: String
    ) throws -> String {
        var lines = contents.components(separatedBy: .newlines)
        guard let start = lines.firstIndex(where: { line in
            headingIDAndTitle(from: line, kind: kind)?.id == workItemID
        }) else {
            throw ArtifactStatusUpdateError.workItemNotFound(workItemID.rawValue)
        }
        let end = lines.indices.first { index in
            index > start && headingIDAndTitle(from: lines[index], kind: kind) != nil
        } ?? lines.endIndex

        if let statusIndex = lines[start..<end].firstIndex(where: { $0.hasPrefix("**Status:**") }) {
            lines[statusIndex] = "**Status:** \(status.description)"
        } else {
            lines.insert("**Status:** \(status.description)", at: min(start + 1, lines.endIndex))
        }
        return lines.joined(separator: "\n")
    }

    private func recordCloseAudit(action: String, workItemID: AirframeID) {
        auditStore.record(
            id: AirframeID("AUD-AGILE-\(auditStore.events.count + 1)"),
            context: reviewerContext,
            action: action,
            workItemID: workItemID,
            decision: .allowed(),
            targetProjectID: context.project.id
        )
    }

    private func apply(_ action: AirframeHumanVerificationAction) {
        guard let id = selectedRecord?.workItem.id else {
            statusMessage = "No ready work is selected."
            return
        }

        let label = actionLabel(action)
        verificationActionState = .pending(id, label)
        statusMessage = "\(id.rawValue) \(label) pending."

        Task { @MainActor in
            await Task.yield()
            do {
                try attachReviewerCommentIfNeeded(action, to: id)
                let result = try backend.applyHumanVerification(
                    action: action,
                    to: id,
                    context: reviewerContext,
                    targetProjectID: context.project.id
                )
                auditStore.record(
                    id: AirframeID("AUD-AGILE-\(auditStore.events.count + 1)"),
                    context: reviewerContext,
                    action: action.operationID.rawValue,
                    workItemID: id,
                    decision: result.decision,
                    targetProjectID: context.project.id
                )
                verificationCommentText = ""
                try reload(selecting: nil)
                let message = "\(id.rawValue) \(label)."
                verificationActionState = .completed(message)
                statusMessage = message
            } catch {
                let message = "Verification action failed: \(error)"
                verificationActionState = .failed(id, message)
                statusMessage = message
            }
        }
    }

    private func loadSelectedVerificationDetail() {
        guard let id = selectedWorkItemID else {
            verificationDetailState = .empty
            return
        }
        verificationDetailState = .loading(id)
        Task { @MainActor in
            await Task.yield()
            guard selectedWorkItemID == id else { return }
            do {
                verificationDetailState = .loaded(try backend.taskPacket(for: id))
            } catch {
                verificationDetailState = .failed(id, "\(error)")
            }
        }
    }

    private func attachReviewerCommentIfNeeded(
        _ action: AirframeHumanVerificationAction,
        to id: AirframeID
    ) throws {
        guard action != .accept else { return }
        let comment = verificationCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !comment.isEmpty else { return }
        guard backend.capabilities.supportsEvidenceAttachment else { return }

        let evidence = AirframeEvidence(
            id: AirframeID("EV-\(id.rawValue)-REVIEW-\(auditStore.events.count + 1)"),
            summary: "\(actionLabel(action).capitalized): \(comment)",
            artifact: "AgileCockpit verification reviewer comment"
        )
        try backend.attachEvidence(evidence, to: id)
    }

    private func synchronizeMarkdownProjections() throws {
        guard let canonicalRepository, let artifactRootURL else {
            return
        }
        let snapshot = try canonicalRepository.snapshot(project: context.project)
        try Self.writeMarkdownProjections(snapshot: snapshot, rootURL: artifactRootURL)
    }

    private func reload(selecting id: AirframeID?) throws {
        verificationQueueState = .loading
        records = try backend.listWorkRecords()
        let dashboardData = Self.dashboardData(
            backendRecords: records,
            artifactRootURL: artifactRootURL,
            preferBackendRecords: canonicalRepository != nil
        )
        dashboardRecords = dashboardData.records
        dashboardDetailTextByID = dashboardData.detailTextByID
        canonicalSnapshot = try Self.canonicalSnapshot(
            context: context,
            records: dashboardData.records,
            canonicalRepository: canonicalRepository
        )
        canonicalDiagnostics = Self.canonicalDiagnostics(
            snapshot: canonicalSnapshot,
            canonicalRecords: dashboardData.records,
            backendRecords: records
        )
        summary = Self.canonicalSummary(records: dashboardData.records)
        auditRows = auditStore.events.map(Self.auditRow)
        let traceabilityState = Self.traceabilityState(
            canonicalState: canonicalState,
            canonicalSnapshot: canonicalSnapshot,
            canonicalDiagnostics: canonicalDiagnostics,
            artifactRootURL: artifactRootURL
        )
        requirementCoverageSummary = traceabilityState.requirementCoverageSummary
        requirementGateSummary = traceabilityState.requirementGateSummary
        requirementTraceRows = traceabilityState.requirementTraceRows
        requirementGapRows = traceabilityState.requirementGapRows
        testCoverageRows = traceabilityState.testCoverageRows
        testGapRows = traceabilityState.testGapRows
        if let selectedTestID,
           !canonicalSnapshot.tests.contains(where: { $0.id == selectedTestID }) {
            self.selectedTestID = canonicalSnapshot.tests.first?.id
        } else if selectedTestID == nil {
            self.selectedTestID = canonicalSnapshot.tests.first?.id
        }
        selectedWorkItemID = id ?? records.first { $0.workItem.status == .implementedNotVerified }?.workItem.id
        if let selectedStatusSelection {
            let refreshedSummary = AirframeDashboardStatusSummary(records: canonicalDashboardRecords)
            let refreshedSelection = refreshedSummary.tiles
                .flatMap { tile in tile.rows.map { AgileCockpitStatusSelection(tile: tile, row: $0) } }
                .first { $0.id == selectedStatusSelection.id }
            self.selectedStatusSelection = refreshedSelection
            if let selectedStatusWorkItemID,
               canonicalDashboardRecords.contains(where: { $0.workItem.id == selectedStatusWorkItemID }) {
                self.selectedStatusWorkItemID = selectedStatusWorkItemID
            } else {
                self.selectedStatusWorkItemID = refreshedSelection?.row.workItems.first?.id
            }
        }
        if let selectedReviewSprintID,
           !reviewSprintRecords.contains(where: { $0.workItem.id == selectedReviewSprintID }) {
            self.selectedReviewSprintID = nil
        }
        verificationQueueState = .loaded
        if let selectedWorkItemID,
           records.contains(where: { $0.workItem.id == selectedWorkItemID && $0.workItem.status == .implementedNotVerified }) {
            loadSelectedVerificationDetail()
        } else {
            verificationDetailState = .empty
        }
    }

    private var canonicalDashboardRecords: [AirframeLocalWorkRecord] {
        Self.localRecords(from: canonicalSnapshot)
    }

    private struct RequirementState {
        let coverage: AirframeRequirementCoverageSummary
        let gate: AirframeRequirementReleaseGateSummary
        let traceRows: [AgileCockpitRequirementTraceRow]
        let gapRows: [AgileCockpitRequirementGapRow]
    }

    nonisolated private static func requirementState(
        canonicalState: AirframeCanonicalStoreState?,
        canonicalSnapshot: AirframeCanonicalStateSnapshot
    ) -> RequirementState {
        let releaseScope = canonicalSnapshot.project.activeSprintID?.rawValue
            ?? canonicalSnapshot.project.activeEpicID?.rawValue
        let index = AirframeRequirementTraceabilityIndex(
            requirements: canonicalState?.requirements ?? [],
            revisions: canonicalState?.requirementRevisions ?? [],
            evidence: canonicalState?.evidence ?? [],
            acceptanceCriteria: canonicalState?.acceptanceCriteria ?? []
        )
        return RequirementState(
            coverage: index.coverageSummary(releaseScope: releaseScope),
            gate: index.releaseGateSummary(releaseScope: releaseScope),
            traceRows: index.requirements.map { requirement in
                AgileCockpitRequirementTraceRow(
                    requirementID: requirement.id.rawValue,
                    title: requirement.title,
                    statement: requirement.statement,
                    status: requirement.status.description,
                    acceptanceCriteria: index.acceptanceCriterionTraceIDs(for: requirement.id).joined(separator: ", ")
                )
            },
            gapRows: index.gapDiagnostics(releaseScope: releaseScope).map {
                AgileCockpitRequirementGapRow(
                    requirementID: $0.requirementID.rawValue,
                    kind: $0.kind.rawValue,
                    message: $0.message
                )
            }
        )
    }

    private struct TestState {
        let coverageRows: [AgileCockpitTestCoverageRow]
        let gapRows: [AgileCockpitTestGapRow]
    }

    nonisolated private static func testState(
        canonicalSnapshot: AirframeCanonicalStateSnapshot,
        canonicalDiagnostics: AirframeCanonicalDiagnostics? = nil
    ) -> TestState {
        let index = AirframeRequirementTraceabilityIndex(
            requirements: canonicalSnapshot.requirements,
            revisions: [],
            evidence: [],
            acceptanceCriteria: canonicalSnapshot.acceptanceCriteria,
            tests: canonicalSnapshot.tests,
            epics: canonicalSnapshot.epics,
            sprints: canonicalSnapshot.sprints,
            tasks: canonicalSnapshot.tasks,
            issues: canonicalSnapshot.issues
        )
        let coverageRows = index.requirements.map { requirement in
            let summary = index.traceSummary(for: requirement.id)
            return AgileCockpitTestCoverageRow(
                requirementID: requirement.id.rawValue,
                title: requirement.title,
                status: requirement.status.description,
                acceptanceCriteria: index.acceptanceCriterionTraceIDs(for: requirement.id).joined(separator: ", "),
                tests: summary.testIDs.map(\.rawValue).joined(separator: ", ")
            )
        }
        let testGapReasonCodes: Set<String> = [
            "testRequirementMissing",
            "testAcceptanceCriterionMissing",
            "testWorkItemMissing",
            "testSuiteTestMissing",
            "testRunTestMissing",
            "testRunSuiteMissing"
        ]
        let gapRows: [AgileCockpitTestGapRow] = canonicalDiagnostics?.diagnostics.compactMap { diagnostic in
            guard testGapReasonCodes.contains(diagnostic.reasonCode.rawValue) else { return nil }
            return AgileCockpitTestGapRow(
                requirementID: diagnostic.affectedIDs.first?.rawValue ?? "Unknown",
                kind: diagnostic.reasonCode.rawValue,
                message: diagnostic.message
            )
        } ?? []
        return TestState(coverageRows: coverageRows, gapRows: gapRows)
    }

    private static func writeMarkdownProjections(
        snapshot: AirframeCanonicalStateSnapshot,
        rootURL: URL
    ) throws {
        let fileManager = FileManager.default
        let projector = AirframeMarkdownArtifactProjector()
        let epicClosedURL = rootURL.appending(path: "docs/Epics/Closed")
        let sprintClosedURL = rootURL.appending(path: "docs/Sprints/Closed")
        let generatedEpicURL = rootURL.appending(path: "docs/generated/Epics")
        let generatedSprintURL = rootURL.appending(path: "docs/generated/Sprints")
        try [epicClosedURL, sprintClosedURL, generatedEpicURL, generatedSprintURL].forEach {
            try fileManager.createDirectory(at: $0, withIntermediateDirectories: true)
        }

        for epic in snapshot.epics {
            let markdown = projector.projectEpic(epic)
            try markdown.write(
                to: generatedEpicURL.appending(path: "\(epic.workItem.id.rawValue).md"),
                atomically: true,
                encoding: .utf8
            )
            if epic.workItem.status == .closed {
                try markdown.write(
                    to: epicClosedURL.appending(path: "Epic-\(epic.workItem.id.rawValue).md"),
                    atomically: true,
                    encoding: .utf8
                )
            }
        }

        for sprint in snapshot.sprints {
            let markdown = projector.projectSprint(sprint)
            try markdown.write(
                to: generatedSprintURL.appending(path: "\(sprint.workItem.id.rawValue).md"),
                atomically: true,
                encoding: .utf8
            )
            if sprint.workItem.status == .closed {
                try markdown.write(
                    to: sprintClosedURL.appending(path: "Sprint-\(sprint.workItem.id.rawValue).md"),
                    atomically: true,
                    encoding: .utf8
                )
            }
        }

        let tasksByID = Dictionary(uniqueKeysWithValues: snapshot.tasks.map { ($0.workItem.id, $0) })
        let issuesByID = Dictionary(uniqueKeysWithValues: snapshot.issues.map { ($0.workItem.id, $0) })
        let sprintsByID = Dictionary(uniqueKeysWithValues: snapshot.sprints.map { ($0.workItem.id, $0) })
        let sortedEpics = snapshot.epics.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }
        let sortedSprints = snapshot.sprints.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }

        try sprintActiveMarkdown(
            sprints: sortedSprints.filter { [.planning, .active].contains($0.workItem.status) },
            tasksByID: tasksByID,
            issuesByID: issuesByID
        ).write(to: rootURL.appending(path: "docs/Sprints/Sprint-active.md"), atomically: true, encoding: .utf8)
        try sprintBacklogMarkdown(
            sprints: sortedSprints.filter { $0.workItem.status == .backlog },
            tasksByID: tasksByID,
            issuesByID: issuesByID
        ).write(to: rootURL.appending(path: "docs/Sprints/Sprint-backlog.md"), atomically: true, encoding: .utf8)
        try sprintIndexMarkdown(
            sprints: sortedSprints,
            tasksByID: tasksByID,
            issuesByID: issuesByID
        ).write(
            to: rootURL.appending(path: "docs/Sprints/Sprint-Documentation.md"),
            atomically: true,
            encoding: .utf8
        )
        try epicActiveMarkdown(
            epics: sortedEpics.filter { [.draft, .active, .complete].contains($0.workItem.status) },
            sprintsByID: sprintsByID,
            tasksByID: tasksByID,
            issuesByID: issuesByID
        ).write(to: rootURL.appending(path: "docs/Epics/Epic-active.md"), atomically: true, encoding: .utf8)
        try epicBacklogMarkdown(
            epics: sortedEpics.filter { [.proposed, .backlog].contains($0.workItem.status) }
        ).write(to: rootURL.appending(path: "docs/Epics/Epic-backlog.md"), atomically: true, encoding: .utf8)
        try epicIndexMarkdown(epics: sortedEpics).write(
            to: rootURL.appending(path: "docs/Epics/Epic-Documentation.md"),
            atomically: true,
            encoding: .utf8
        )
    }

    private static func sprintActiveMarkdown(
        sprints: [AirframeCanonicalSprintRecord],
        tasksByID: [AirframeID: AirframeCanonicalTaskRecord],
        issuesByID: [AirframeID: AirframeCanonicalIssueRecord]
    ) -> String {
        var lines = [
            "# Active Sprint",
            "",
            "Sprints listed here are currently in Planning or Active status and are the current execution focus.",
            "",
            "---"
        ]
        if sprints.isEmpty {
            lines.append("")
            lines.append("No Sprints are currently in Planning or Active.")
        } else {
            sprints.forEach { appendSprintSection($0, tasksByID: tasksByID, issuesByID: issuesByID, to: &lines) }
        }
        lines.append("")
        lines.append("*Last Updated: \(currentDateString())*")
        return lines.joined(separator: "\n") + "\n"
    }

    private static func sprintBacklogMarkdown(
        sprints: [AirframeCanonicalSprintRecord],
        tasksByID: [AirframeID: AirframeCanonicalTaskRecord],
        issuesByID: [AirframeID: AirframeCanonicalIssueRecord]
    ) -> String {
        var lines = [
            "# Sprint Backlog",
            "",
            "Sprints listed here are attached to an Epic but are not yet in Planning, Active, Review, or Closed status.",
            "",
            "Currently: **\(sprints.count) backlog Sprint\(sprints.count == 1 ? "" : "s")**",
            "",
            "---"
        ]
        if sprints.isEmpty {
            lines.append("")
            lines.append("No Sprints are currently in Backlog.")
        } else {
            sprints.forEach { appendSprintSection($0, tasksByID: tasksByID, issuesByID: issuesByID, to: &lines) }
        }
        lines.append("")
        lines.append("*Last Updated: \(currentDateString())*")
        return lines.joined(separator: "\n") + "\n"
    }

    private static func sprintIndexMarkdown(
        sprints: [AirframeCanonicalSprintRecord],
        tasksByID: [AirframeID: AirframeCanonicalTaskRecord],
        issuesByID: [AirframeID: AirframeCanonicalIssueRecord]
    ) -> String {
        let groups = Dictionary(grouping: sprints, by: \.workItem.status)
        var lines = [
            "# Sprints - Index",
            "",
            "This is the main index for Agile Airframe Sprints. Sprints group Tasks and Issues into focused execution windows.",
            "",
            "## Current Sprint Record",
            "",
            "Currently: **\(sprints.first { $0.workItem.status == .active }?.workItem.id.rawValue ?? "None")**",
            "",
            "## All Sprints",
            "",
            "Currently: **\(sprints.count) Sprints** | Next available: **\(nextID(prefix: "SP", existingIDs: sprints.map(\.workItem.id)))**",
            "",
            "| Sprint | Title | Epic | Tasks | Issues | Status |",
            "| ------ | ----- | ---- | ----- | ------ | ------ |"
        ]
        for sprint in sprints {
            let taskIDs = sprintTaskIDs(for: sprint, tasksByID: tasksByID)
            let issueIDs = sprintIssueIDs(for: sprint, issuesByID: issuesByID)
            lines.append("| \(sprint.workItem.id.rawValue) | \(sprint.workItem.title) | \(sprint.epicID?.rawValue ?? "None") | \(idList(taskIDs)) | \(idList(issueIDs)) | \(sprint.workItem.status.description) |")
        }
        lines.append("")
        lines.append("## Statistics")
        lines.append("")
        lines.append("- **Total Sprints:** \(sprints.count)")
        lines.append("- **Backlog:** \(groups[.backlog, default: []].count)")
        lines.append("- **Planning:** \(groups[.planning, default: []].count)")
        lines.append("- **Active:** \(groups[.active, default: []].count)")
        lines.append("- **Review:** \(groups[.review, default: []].count)")
        lines.append("- **Closed:** \(groups[.closed, default: []].count)")
        lines.append("- **Next available:** \(nextID(prefix: "SP", existingIDs: sprints.map(\.workItem.id)))")
        lines.append("")
        lines.append("*Last Updated: \(currentDateString())*")
        return lines.joined(separator: "\n") + "\n"
    }

    private static func epicActiveMarkdown(
        epics: [AirframeCanonicalEpicRecord],
        sprintsByID: [AirframeID: AirframeCanonicalSprintRecord],
        tasksByID: [AirframeID: AirframeCanonicalTaskRecord],
        issuesByID: [AirframeID: AirframeCanonicalIssueRecord]
    ) -> String {
        var lines = [
            "# Epic Active",
            "",
            "Epics listed here are drafted, active, or complete-pending-close and are the current focus of planning or execution.",
            "",
            "---"
        ]
        if epics.isEmpty {
            lines.append("")
            lines.append("No Epics are currently active.")
        } else {
            epics.forEach {
                appendEpicSection($0, sprintsByID: sprintsByID, tasksByID: tasksByID, issuesByID: issuesByID, to: &lines)
            }
        }
        lines.append("")
        lines.append("*Last Updated: \(currentDateString())*")
        return lines.joined(separator: "\n") + "\n"
    }

    private static func epicBacklogMarkdown(epics: [AirframeCanonicalEpicRecord]) -> String {
        var lines = [
            "# Epic Backlog",
            "",
            "Epics listed here are proposed and queued for future planning.",
            "",
            "Currently: **\(epics.count) backlog Epic\(epics.count == 1 ? "" : "s")**",
            "",
            "---"
        ]
        if epics.isEmpty {
            lines.append("")
            lines.append("No Epics are currently in Backlog.")
        } else {
            for epic in epics {
                lines.append("")
                lines.append("## \(epic.workItem.id.rawValue): \(epic.workItem.title)")
                lines.append("")
                lines.append("**Status:** \(epic.workItem.status.description)")
                lines.append("**Owner:** \(epic.owner)")
                lines.append("")
                lines.append("**Goal:**")
                lines.append(epic.goal)
            }
        }
        lines.append("")
        lines.append("*Last Updated: \(currentDateString())*")
        return lines.joined(separator: "\n") + "\n"
    }

    private static func epicIndexMarkdown(epics: [AirframeCanonicalEpicRecord]) -> String {
        let groups = Dictionary(grouping: epics, by: \.workItem.status)
        var lines = [
            "# Epics - Index",
            "",
            "This is the main index for Agile Airframe Epics.",
            "",
            "## All Epics",
            "",
            "Currently: **\(epics.count) Epics** | Next available: **\(nextID(prefix: "EP", existingIDs: epics.map(\.workItem.id)))**",
            "",
            "| Epic | Title | Status | Start Date | Close Date |",
            "| ---- | ----- | ------ | ---------- | ---------- |"
        ]
        for epic in epics {
            lines.append("| \(epic.workItem.id.rawValue) | \(epic.workItem.title) | \(epic.workItem.status.description) | \(epic.startDate ?? "TBD") | \(epic.closeDate ?? "TBD") |")
        }
        lines.append("")
        lines.append("## Statistics")
        lines.append("")
        lines.append("- **Total Epics:** \(epics.count)")
        lines.append("- **Backlog:** \(groups[.backlog, default: []].count)")
        lines.append("- **Active:** \(groups[.active, default: []].count)")
        lines.append("- **Closed:** \(groups[.closed, default: []].count)")
        lines.append("- **Next available:** \(nextID(prefix: "EP", existingIDs: epics.map(\.workItem.id)))")
        lines.append("")
        lines.append("*Last Updated: \(currentDateString())*")
        return lines.joined(separator: "\n") + "\n"
    }

    private static func appendSprintSection(
        _ sprint: AirframeCanonicalSprintRecord,
        tasksByID: [AirframeID: AirframeCanonicalTaskRecord],
        issuesByID: [AirframeID: AirframeCanonicalIssueRecord],
        to lines: inout [String]
    ) {
        lines.append("")
        lines.append("## \(sprint.workItem.id.rawValue): \(sprint.workItem.title)")
        lines.append("")
        lines.append("**Status:** \(sprint.workItem.status.description)")
        lines.append("**Epic:** \(sprint.epicID?.rawValue ?? "TBD")")
        lines.append("**Goal:** \(sprint.goal)")
        lines.append("**Start Date:** \(sprint.startDate ?? "TBD")")
        lines.append("**End Date:** \(sprint.endDate ?? "TBD")")
        lines.append("**Capacity:** \(sprint.capacity ?? "TBD")")
        lines.append("")
        lines.append("### Assigned Tasks")
        lines.append("")
        lines.append("| Task | Title | Priority | Status |")
        lines.append("| ---- | ----- | -------- | ------ |")
        let taskIDs = sprintTaskIDs(for: sprint, tasksByID: tasksByID)
        if taskIDs.isEmpty {
            lines.append("| None |  |  |  |")
        } else {
            for taskID in taskIDs {
                let task = tasksByID[taskID]
                lines.append("| \(taskID.rawValue) | \(task?.workItem.title ?? "") | \(task?.priority.description ?? "") | \(task?.workItem.status.description ?? "") |")
            }
        }
        lines.append("")
        lines.append("### Assigned Issues")
        lines.append("")
        let issueIDs = sprintIssueIDs(for: sprint, issuesByID: issuesByID)
        if issueIDs.isEmpty {
            lines.append("None.")
        } else {
            lines.append("| Issue | Title | Severity | Status |")
            lines.append("| ----- | ----- | -------- | ------ |")
            for issueID in issueIDs {
                let issue = issuesByID[issueID]
                lines.append("| \(issueID.rawValue) | \(issue?.workItem.title ?? "") | \(issue?.severity.description ?? "") | \(issue?.workItem.status.description ?? "") |")
            }
        }
    }

    private static func appendEpicSection(
        _ epic: AirframeCanonicalEpicRecord,
        sprintsByID: [AirframeID: AirframeCanonicalSprintRecord],
        tasksByID: [AirframeID: AirframeCanonicalTaskRecord],
        issuesByID: [AirframeID: AirframeCanonicalIssueRecord],
        to lines: inout [String]
    ) {
        lines.append("")
        lines.append("## \(epic.workItem.id.rawValue): \(epic.workItem.title)")
        lines.append("")
        lines.append("**Status:** \(epic.workItem.status.description)")
        lines.append("**Owner:** \(epic.owner)")
        lines.append("**Start Date:** \(epic.startDate ?? "TBD")")
        lines.append("**Target Close Date:** \(epic.targetCloseDate ?? "TBD")")
        lines.append("**Close Date:** \(epic.closeDate ?? "TBD")")
        lines.append("")
        lines.append("**Goal:**")
        lines.append(epic.goal)
        lines.append("")
        lines.append("### Related Sprints")
        lines.append("")
        lines.append("| Sprint | Goal | Status |")
        lines.append("| ------ | ---- | ------ |")
        for sprintID in epic.sprintIDs {
            let sprint = sprintsByID[sprintID]
            lines.append("| \(sprintID.rawValue) | \(sprint?.goal ?? "") | \(sprint?.workItem.status.description ?? "") |")
        }
        lines.append("")
        lines.append("### Related Tasks")
        lines.append("")
        lines.append("| Task | Title | Status |")
        lines.append("| ---- | ----- | ------ |")
        for taskID in epic.taskIDs {
            let task = tasksByID[taskID]
            lines.append("| \(taskID.rawValue) | \(task?.workItem.title ?? "") | \(task?.workItem.status.description ?? "") |")
        }
        lines.append("")
        lines.append("### Related Issues")
        lines.append("")
        lines.append("| Issue | Title | Status |")
        lines.append("| ----- | ----- | ------ |")
        for issueID in epic.issueIDs {
            let issue = issuesByID[issueID]
            lines.append("| \(issueID.rawValue) | \(issue?.workItem.title ?? "") | \(issue?.workItem.status.description ?? "") |")
        }
    }

    private static func idList(_ ids: [AirframeID]) -> String {
        ids.isEmpty ? "None" : ids.map(\.rawValue).joined(separator: ", ")
    }

    private static func sprintTaskIDs(
        for sprint: AirframeCanonicalSprintRecord,
        tasksByID: [AirframeID: AirframeCanonicalTaskRecord]
    ) -> [AirframeID] {
        if !sprint.taskIDs.isEmpty {
            return sprint.taskIDs
        }
        return tasksByID.values
            .filter { $0.sprintID == sprint.workItem.id }
            .map(\.workItem.id)
            .sorted { $0.rawValue < $1.rawValue }
    }

    private static func sprintIssueIDs(
        for sprint: AirframeCanonicalSprintRecord,
        issuesByID: [AirframeID: AirframeCanonicalIssueRecord]
    ) -> [AirframeID] {
        if !sprint.issueIDs.isEmpty {
            return sprint.issueIDs
        }
        return issuesByID.values
            .filter { $0.sprintID == sprint.workItem.id }
            .map(\.workItem.id)
            .sorted { $0.rawValue < $1.rawValue }
    }

    private static func nextID(prefix: String, existingIDs: [AirframeID]) -> String {
        let next = existingIDs.compactMap { id -> Int? in
            guard id.rawValue.hasPrefix("\(prefix)-") else { return nil }
            return Int(id.rawValue.dropFirst(prefix.count + 1))
        }.max().map { $0 + 1 } ?? 1
        return "\(prefix)-\(String(format: "%03d", next))"
    }

    private static func currentDateString() -> String {
        String(ISO8601DateFormatter().string(from: Date()).prefix(10))
    }

    nonisolated private static func canonicalSnapshot(
        context: AirframeProjectContext,
        records: [AirframeLocalWorkRecord],
        canonicalRepository: AirframeCanonicalStoreRepository?
    ) throws -> AirframeCanonicalStateSnapshot {
        if let canonicalRepository {
            return try canonicalRepository.snapshot(project: context.project)
        }
        return AirframeCanonicalStateSnapshotBuilder().snapshot(
            project: context.project,
            records: records
        )
    }

    nonisolated private static func canonicalSummary(records: [AirframeLocalWorkRecord]) -> AirframeDashboardSummary {
        AirframeCanonicalProjectSummary().dashboardSummary(records: records)
    }

    nonisolated private static func canonicalDiagnostics(
        snapshot: AirframeCanonicalStateSnapshot,
        canonicalRecords: [AirframeLocalWorkRecord],
        backendRecords: [AirframeLocalWorkRecord]
    ) -> AirframeCanonicalDiagnostics {
        let stateDiagnostics = AirframeCanonicalStateValidator().diagnostics(for: snapshot)
        let reconciliationDiagnostics = AirframeCanonicalBackendReconciler().diagnostics(
            canonicalRecords: canonicalRecords,
            backendRecords: backendRecords
        )
        return AirframeCanonicalDiagnostics(
            diagnostics: (stateDiagnostics.diagnostics + reconciliationDiagnostics).sorted {
                $0.reasonCode.rawValue == $1.reasonCode.rawValue
                    ? $0.affectedIDs.map(\.rawValue).joined() < $1.affectedIDs.map(\.rawValue).joined()
                    : $0.reasonCode.rawValue < $1.reasonCode.rawValue
            }
        )
    }

    nonisolated private static func launchRootURL(
        configurationURL: URL?,
        currentDirectoryURL: URL
    ) -> URL {
        guard let configurationURL else {
            return currentDirectoryURL
        }
        let workspaceDirectory = configurationURL.deletingLastPathComponent()
        return workspaceDirectory.lastPathComponent == ".airframe"
            ? workspaceDirectory.deletingLastPathComponent()
            : workspaceDirectory
    }

    nonisolated private static func launchCacheURL(rootURL: URL) -> URL {
        rootURL
            .appending(path: ".airframe")
            .appending(path: "agilecockpit-launch-cache.json")
    }

    nonisolated private static func loadLaunchCache(
        from url: URL,
        fingerprint: String
    ) -> LaunchCachePayload? {
        guard let data = try? Data(contentsOf: url),
              let entry = try? JSONDecoder().decode(LaunchCacheEntry.self, from: data),
              entry.fingerprint == fingerprint else {
            return nil
        }
        return entry.payload
    }

    nonisolated private static func loadAnyLaunchCache(from url: URL) -> LaunchCachePayload? {
        guard let data = try? Data(contentsOf: url),
              let entry = try? JSONDecoder().decode(LaunchCacheEntry.self, from: data) else {
            return nil
        }
        return entry.payload
    }

    nonisolated private static func loadTraceabilityCache(
        from url: URL,
        fingerprint: String
    ) -> TraceabilityCachePayload? {
        guard let data = try? Data(contentsOf: url),
              let entry = try? JSONDecoder().decode(TraceabilityCacheEntry.self, from: data),
              entry.fingerprint == fingerprint else {
            return nil
        }
        return entry.payload
    }

    nonisolated private static func saveTraceabilityCache(
        _ payload: TraceabilityCachePayload,
        fingerprint: String,
        to url: URL
    ) {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let entry = TraceabilityCacheEntry(fingerprint: fingerprint, payload: payload)
            let data = try JSONEncoder().encode(entry)
            try data.write(to: url, options: [.atomic])
        } catch {
        }
    }

    nonisolated private static func traceabilityCacheURL(rootURL: URL) -> URL {
        rootURL
            .appending(path: ".airframe")
            .appending(path: "agilecockpit-traceability-cache.json")
    }

    nonisolated private static func traceabilityFingerprint(
        artifactRootURL: URL?,
        canonicalSnapshot: AirframeCanonicalStateSnapshot
    ) -> String {
        guard let artifactRootURL else {
            return "no-artifact-root"
        }
        let stateRoot = artifactRootURL.appending(path: ".airframe/state")
        let watchedDirectories: [URL] = [
            stateRoot.appending(path: "requirements"),
            stateRoot.appending(path: "requirement-revisions"),
            stateRoot.appending(path: "acceptance-criteria"),
            stateRoot.appending(path: "tests"),
            stateRoot.appending(path: "test-suites")
        ]
        let metadataEntries = watchedDirectories.flatMap { directory in
            fingerprintEntries(for: directory)
        }
        return metadataEntries.sorted().joined(separator: "\n")
    }

    nonisolated private static func traceabilityState(
        canonicalState: AirframeCanonicalStoreState?,
        canonicalSnapshot: AirframeCanonicalStateSnapshot,
        canonicalDiagnostics: AirframeCanonicalDiagnostics?,
        artifactRootURL: URL?
    ) -> TraceabilityCachePayload {
        let fingerprint = traceabilityFingerprint(
            artifactRootURL: artifactRootURL,
            canonicalSnapshot: canonicalSnapshot
        )
        if let artifactRootURL,
           let cached = loadTraceabilityCache(
            from: traceabilityCacheURL(rootURL: artifactRootURL),
            fingerprint: fingerprint
           ) {
            return cached
        }

        let requirementState = requirementState(
            canonicalState: canonicalState,
            canonicalSnapshot: canonicalSnapshot
        )
        let testState = testState(
            canonicalSnapshot: canonicalSnapshot,
            canonicalDiagnostics: canonicalDiagnostics
        )
        let payload = TraceabilityCachePayload(
            requirementCoverageSummary: requirementState.coverage,
            requirementGateSummary: requirementState.gate,
            requirementTraceRows: requirementState.traceRows,
            requirementGapRows: requirementState.gapRows,
            testCoverageRows: testState.coverageRows,
            testGapRows: testState.gapRows
        )
        if let artifactRootURL {
            saveTraceabilityCache(
                payload,
                fingerprint: fingerprint,
                to: traceabilityCacheURL(rootURL: artifactRootURL)
            )
        }
        return payload
    }

    nonisolated private static func saveLaunchCache(
        _ payload: LaunchCachePayload,
        fingerprint: String,
        to url: URL
    ) {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let entry = LaunchCacheEntry(fingerprint: fingerprint, payload: payload)
            let data = try JSONEncoder().encode(entry)
            try data.write(to: url, options: [.atomic])
        } catch {
        }
    }

    nonisolated private static func launchFingerprint(
        configurationURL: URL?,
        storeURL: URL,
        artifactRootURL: URL?,
        canonicalRepositoryExists: Bool
    ) -> String {
        let watchedURLs: [URL] = [
            configurationURL,
            storeURL,
            canonicalRepositoryExists ? artifactRootURL?.appending(path: ".airframe/state") : nil
        ]
        .compactMap { $0 }
        let metadataEntries = watchedURLs.flatMap { watchURL in
            Self.watchURLs(for: watchURL).flatMap { fingerprintEntries(for: $0) }
        }
        return [AirframeCoreInfo.current.summary, metadataEntries.sorted().joined(separator: "\n")]
            .joined(separator: "\n---\n")
    }

    nonisolated private static func fingerprintEntries(for url: URL) -> [String] {
        let fileManager = FileManager.default
        let resolvedURL = url.standardizedFileURL
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: resolvedURL.path, isDirectory: &isDirectory) else {
            return ["missing:\(resolvedURL.path)"]
        }

        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey]
        func entry(for fileURL: URL) -> String {
            let values = try? fileURL.resourceValues(forKeys: resourceKeys)
            let kind = values?.isDirectory == true ? "dir" : "file"
            let size = values?.fileSize ?? -1
            let modified = values?.contentModificationDate?.timeIntervalSinceReferenceDate ?? -1
            return "\(fileURL.standardizedFileURL.path)|\(kind)|\(size)|\(modified)"
        }

        var entries = [entry(for: resolvedURL)]
        if isDirectory.boolValue,
           let enumerator = fileManager.enumerator(
            at: resolvedURL,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles]
           ) {
            while let child = enumerator.nextObject() as? URL {
                entries.append(entry(for: child))
            }
        }
        return entries
    }

    nonisolated private static func cachedState(
        from state: LaunchCachePayload.CachedCanonicalState
    ) -> AirframeCanonicalStoreState {
        AirframeCanonicalStoreState(
            workspaces: state.workspaces,
            projects: state.projects,
            epics: state.epics,
            sprints: state.sprints,
            tasks: state.tasks,
            issues: state.issues,
            requirements: state.requirements,
            requirementRevisions: state.requirementRevisions,
            acceptanceCriteria: state.acceptanceCriteria,
            tests: state.tests,
            testSuites: state.testSuites,
            testRuns: state.testRuns,
            evidence: state.evidence
        )
    }

    nonisolated private static func cachedSnapshot(
        from snapshot: LaunchCachePayload.CachedCanonicalSnapshot
    ) -> AirframeCanonicalStateSnapshot {
        AirframeCanonicalStateSnapshot(
            project: snapshot.project,
            epics: snapshot.epics,
            sprints: snapshot.sprints,
            tasks: snapshot.tasks,
            issues: snapshot.issues,
            requirements: snapshot.requirements,
            acceptanceCriteria: snapshot.acceptanceCriteria,
            tests: snapshot.tests,
            testSuites: snapshot.testSuites,
            testRuns: snapshot.testRuns
        )
    }

    nonisolated private static func cachedPayload(
        context: AirframeProjectContext,
        configurationDiagnostics: AirframeConfigurationDiagnostics,
        artifactRootURL: URL?,
        observedURLs: [URL],
        canonicalState: AirframeCanonicalStoreState?,
        canonicalSnapshot: AirframeCanonicalStateSnapshot,
        records: [AirframeLocalWorkRecord],
        dashboardData: (records: [AirframeLocalWorkRecord], detailTextByID: [AirframeID: String]),
        canonicalDiagnostics: AirframeCanonicalDiagnostics,
        summary: AirframeDashboardSummary,
        auditRows: [AgileCockpitAuditRow],
        requirementCoverageSummary: AirframeRequirementCoverageSummary,
        requirementGateSummary: AirframeRequirementReleaseGateSummary,
        requirementTraceRows: [AgileCockpitRequirementTraceRow],
        requirementGapRows: [AgileCockpitRequirementGapRow],
        testCoverageRows: [AgileCockpitTestCoverageRow],
        testGapRows: [AgileCockpitTestGapRow]
    ) -> LaunchCachePayload {
        LaunchCachePayload(
            configuration: context.configuration,
            project: context.project,
            configurationDiagnostics: configurationDiagnostics,
            artifactRootPath: artifactRootURL?.path,
            observedURLs: observedURLs,
            records: records,
            dashboardRecords: dashboardData.records,
            dashboardDetailTextByID: Dictionary(
                uniqueKeysWithValues: dashboardData.detailTextByID.map { ($0.key.rawValue, $0.value) }
            ),
            canonicalState: canonicalState.map {
                LaunchCachePayload.CachedCanonicalState(
                    workspaces: $0.workspaces,
                    projects: $0.projects,
                    epics: $0.epics,
                    sprints: $0.sprints,
                    tasks: $0.tasks,
                    issues: $0.issues,
                    requirements: $0.requirements,
                    requirementRevisions: $0.requirementRevisions,
                    acceptanceCriteria: $0.acceptanceCriteria,
                    tests: $0.tests,
                    testSuites: $0.testSuites,
                    testRuns: $0.testRuns,
                    evidence: $0.evidence
                )
            },
            canonicalSnapshot: LaunchCachePayload.CachedCanonicalSnapshot(
                project: canonicalSnapshot.project,
                epics: canonicalSnapshot.epics,
                sprints: canonicalSnapshot.sprints,
                tasks: canonicalSnapshot.tasks,
                issues: canonicalSnapshot.issues,
                requirements: canonicalSnapshot.requirements,
                acceptanceCriteria: canonicalSnapshot.acceptanceCriteria,
                tests: canonicalSnapshot.tests,
                testSuites: canonicalSnapshot.testSuites,
                testRuns: canonicalSnapshot.testRuns
            ),
            canonicalDiagnostics: canonicalDiagnostics,
            summary: summary,
            auditRows: auditRows,
            requirementCoverageSummary: requirementCoverageSummary,
            requirementGateSummary: requirementGateSummary,
            requirementTraceRows: requirementTraceRows,
            requirementGapRows: requirementGapRows,
            testCoverageRows: testCoverageRows,
            testGapRows: testGapRows
        )
    }

    private static func localRecords(from snapshot: AirframeCanonicalStateSnapshot) -> [AirframeLocalWorkRecord] {
        let epics = snapshot.epics.map { epic in
            AirframeLocalWorkRecord(
                workItem: epic.workItem,
                priority: .medium,
                acceptanceCriteria: epic.acceptanceCriterionIDs.map(\.rawValue),
                scope: epic.scope,
                constraints: epic.outOfScope
            )
        }
        let sprints = snapshot.sprints.map { sprint in
            AirframeLocalWorkRecord(
                workItem: sprint.workItem,
                epicID: sprint.epicID,
                priority: .medium,
                scope: sprint.notes
            )
        }
        let tasks = snapshot.tasks.map { task in
            AirframeLocalWorkRecord(
                workItem: task.workItem,
                epicID: task.epicID,
                sprintID: task.sprintID,
                priority: task.priority,
                acceptanceCriteria: task.acceptanceCriteria,
                scope: task.componentsAffected,
                constraints: task.notes,
                evidenceRequirements: task.testSteps
            )
        }
        let issues = snapshot.issues.map { issue in
            AirframeLocalWorkRecord(
                workItem: issue.workItem,
                epicID: issue.epicID,
                sprintID: issue.sprintID,
                priority: issue.severity
            )
        }
        return (epics + sprints + tasks + issues).sorted {
            $0.workItem.id.rawValue < $1.workItem.id.rawValue
        }
    }

    nonisolated private static func artifactRootURL(
        configurationURL: URL,
        context: AirframeProjectContext
    ) -> URL {
        let configuredRootPath = context.configuration.workspace.rootPath
        if configuredRootPath.hasPrefix("/") {
            return URL(filePath: configuredRootPath)
        }
        let configurationDirectory = configurationURL.deletingLastPathComponent()
        let workspaceBaseURL = configurationDirectory.lastPathComponent == ".airframe"
            ? configurationDirectory.deletingLastPathComponent()
            : configurationDirectory
        return workspaceBaseURL
            .appending(path: configuredRootPath)
            .standardizedFileURL
    }

    nonisolated private static func canonicalRepositoryExists(at artifactRootURL: URL) -> Bool {
        FileManager.default.fileExists(atPath: artifactRootURL.appending(path: ".airframe/state").path)
    }

    nonisolated private static func dashboardData(
        backendRecords: [AirframeLocalWorkRecord],
        artifactRootURL: URL?,
        preferBackendRecords: Bool = false
    ) -> (records: [AirframeLocalWorkRecord], detailTextByID: [AirframeID: String]) {
        guard let artifactRootURL else {
            return (
                records: backendRecords,
                detailTextByID: Dictionary(
                    uniqueKeysWithValues: backendRecords.map { ($0.workItem.id, detailText(for: $0)) }
                )
            )
        }
        let artifactRecords = localArtifactRecords(rootURL: artifactRootURL)
        let artifactRecordsByID = artifactRecords.reduce(into: [AirframeID: StatusDetailRecord]()) { recordsByID, artifactRecord in
            recordsByID[artifactRecord.record.workItem.id] = artifactRecord
        }
        let uniqueArtifactRecords = artifactRecordsByID.values.sorted {
            $0.record.workItem.id.rawValue < $1.record.workItem.id.rawValue
        }
        let backendIDs = Set(backendRecords.map(\.workItem.id))
        let mergedBackendRecords = preferBackendRecords
            ? backendRecords
            : backendRecords.map { backendRecord in
                artifactRecordsByID[backendRecord.workItem.id]?.record ?? backendRecord
            }
        var detailTextByID = Dictionary(
            uniqueKeysWithValues: backendRecords.map { ($0.workItem.id, detailText(for: $0)) }
        )
        for artifactRecord in artifactRecords {
            detailTextByID[artifactRecord.record.workItem.id] = artifactRecord.detailText
        }
        let additionalArtifactRecords = preferBackendRecords
            ? []
            : uniqueArtifactRecords.map(\.record).filter { !backendIDs.contains($0.workItem.id) }
        return (
            records: mergedBackendRecords + additionalArtifactRecords,
            detailTextByID: detailTextByID
        )
    }

    nonisolated private static func localArtifactRecords(rootURL: URL) -> [StatusDetailRecord] {
        let files: [(URL, AirframeWorkItemKind)] = [
            (rootURL.appending(path: "docs/Epics/Epic-backlog.md"), .epic),
            (rootURL.appending(path: "docs/Epics/Epic-active.md"), .epic),
            (rootURL.appending(path: "docs/Sprints/Sprint-backlog.md"), .sprint),
            (rootURL.appending(path: "docs/Sprints/Sprint-active.md"), .sprint)
        ]
        let sectionedFiles: [(URL, AirframeWorkItemKind)] = [
            (rootURL.appending(path: "docs/Tasks/Task-backlog.md"), .task),
            (rootURL.appending(path: "docs/Tasks/Task-active.md"), .task),
            (rootURL.appending(path: "docs/Tasks/Task-unverified.md"), .task),
            (rootURL.appending(path: "docs/Issues/Issue-backlog.md"), .issue),
            (rootURL.appending(path: "docs/Issues/Issue-active.md"), .issue)
        ]
        let closedFiles = markdownFiles(in: rootURL.appending(path: "docs/Epics/Closed"))
            .map { ($0, AirframeWorkItemKind.epic) }
            + markdownFiles(in: rootURL.appending(path: "docs/Sprints/Closed"))
            .map { ($0, AirframeWorkItemKind.sprint) }
        let reviewSprintFiles = markdownFiles(in: rootURL.appending(path: "docs/Sprints/Review"))
            .map { ($0, AirframeWorkItemKind.sprint) }
        let verifiedTaskFiles = markdownFiles(in: rootURL.appending(path: "docs/Tasks/Verified"))

        let fullFileRecords = (files + closedFiles + reviewSprintFiles).flatMap { fileURL, kind in
            records(from: fileURL, kind: kind)
        }
        let sectionArtifactRecords = sectionedFiles.flatMap { fileURL, kind in
            sectionRecords(from: fileURL, kind: kind)
        }
        let verifiedTaskRecords = verifiedTaskFiles.flatMap { fileURL in
            tableTaskRecords(from: fileURL)
        }
        return fullFileRecords + sectionArtifactRecords + verifiedTaskRecords
    }

    nonisolated private static func markdownFiles(in directoryURL: URL) -> [URL] {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        return urls
            .filter { $0.pathExtension == "md" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    nonisolated private static func records(
        from fileURL: URL,
        kind: AirframeWorkItemKind
    ) -> [StatusDetailRecord] {
        guard let contents = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return []
        }

        var records: [StatusDetailRecord] = []
        var currentID: AirframeID?
        var currentTitle: String?
        var currentStatus: AirframeWorkStatus?
        var currentEpicID: AirframeID?
        var currentSectionLines: [String] = []

        func flush() {
            guard let currentID, let currentTitle, let currentStatus else {
                currentSectionLines.removeAll()
                return
            }
            records.append(
                StatusDetailRecord(
                    record: AirframeLocalWorkRecord(
                        workItem: AirframeWorkItem(
                            id: currentID,
                            kind: kind,
                            title: currentTitle,
                            status: currentStatus
                        ),
                        epicID: kind == .sprint ? currentEpicID : nil,
                        sprintID: nil,
                        priority: .medium,
                        acceptanceCriteria: acceptanceCriteria(from: currentSectionLines)
                    ),
                    detailText: contents
                )
            )
            currentSectionLines.removeAll()
        }

        for line in contents.components(separatedBy: .newlines) {
            if line.hasPrefix("## ") || line.hasPrefix("# EP-") || line.hasPrefix("# SP-") {
                flush()
                currentStatus = nil
                currentEpicID = nil
                currentSectionLines = [line]
                let heading = line.drop { $0 == "#" || $0 == " " }
                let parts = heading.split(separator: ":", maxSplits: 1).map {
                    String($0).trimmingCharacters(in: .whitespaces)
                }
                currentID = parts.first.map(AirframeID.init)
                currentTitle = parts.count > 1 ? parts[1] : parts.first
            } else if line.hasPrefix("**Status:**") {
                currentSectionLines.append(line)
                currentStatus = status(from: line)
            } else if kind == .sprint, line.hasPrefix("**Epic:**") {
                currentSectionLines.append(line)
                currentEpicID = firstAirframeID(in: line, prefix: "EP-")
            } else if currentID != nil {
                currentSectionLines.append(line)
            }
        }

        flush()
        return records
    }

    nonisolated private static func sectionRecords(
        from fileURL: URL,
        kind: AirframeWorkItemKind
    ) -> [StatusDetailRecord] {
        guard let contents = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return []
        }

        let lines = contents.components(separatedBy: .newlines)
        let headingIndices = lines.indices.filter { index in
            headingIDAndTitle(from: lines[index], kind: kind) != nil
        }

        return headingIndices.compactMap { startIndex in
            guard let heading = headingIDAndTitle(from: lines[startIndex], kind: kind) else {
                return nil
            }
            let endIndex = headingIndices.first { $0 > startIndex } ?? lines.endIndex
            let sectionLines = Array(lines[startIndex..<endIndex])
            let sectionText = sectionLines.joined(separator: "\n")
            let status = sectionLines
                .first { $0.hasPrefix("**Status:**") }
                .map(status(from:)) ?? .backlog

            return StatusDetailRecord(
                record: AirframeLocalWorkRecord(
                    workItem: AirframeWorkItem(
                        id: heading.id,
                        kind: kind,
                        title: heading.title,
                        status: status,
                        githubIssue: sectionLines
                            .first { $0.hasPrefix("**GitHub Issue:**") }
                            .flatMap(githubIssueNumber(from:))
                    ),
                    epicID: sectionLines
                        .first { $0.hasPrefix("**Epic:**") }
                        .flatMap { firstAirframeID(in: $0, prefix: "EP-") },
                    sprintID: sectionLines
                        .first { $0.hasPrefix("**Sprint") }
                        .flatMap { firstAirframeID(in: $0, prefix: "SP-") },
                    priority: sectionLines
                        .first { $0.hasPrefix("**Priority:**") || $0.hasPrefix("**Severity:**") }
                        .map(priority(from:)) ?? .medium,
                    acceptanceCriteria: acceptanceCriteria(from: sectionLines)
                ),
                detailText: sectionText
            )
        }
    }

    nonisolated private static func tableTaskRecords(from fileURL: URL) -> [StatusDetailRecord] {
        guard let contents = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return []
        }

        return contents.components(separatedBy: .newlines).compactMap { line in
            let columns = line
                .split(separator: "|")
                .map { String($0).trimmingCharacters(in: .whitespaces) }
            guard columns.count >= 4,
                  let id = columns.first,
                  id.hasPrefix("T-"),
                  let statusText = columns.last,
                  statusText != "Status" else {
                return nil
            }

            return StatusDetailRecord(
                record: AirframeLocalWorkRecord(
                    workItem: AirframeWorkItem(
                        id: AirframeID(id),
                        kind: .task,
                        title: columns[2],
                        status: status(from: statusText),
                        githubIssue: githubIssueNumber(from: columns[1])
                    ),
                    priority: .medium
                ),
                detailText: contents
            )
        }
    }

    nonisolated private static func headingIDAndTitle(
        from line: String,
        kind: AirframeWorkItemKind
    ) -> (id: AirframeID, title: String)? {
        guard line.hasPrefix("#") else { return nil }
        let heading = line.drop { $0 == "#" || $0 == " " }
        let parts = heading.split(separator: ":", maxSplits: 1).map {
            String($0).trimmingCharacters(in: .whitespaces)
        }
        guard let rawID = parts.first,
              rawID.hasPrefix(idPrefix(for: kind)),
              rawID.split(separator: " ").count == 1 else {
            return nil
        }
        return (AirframeID(rawID), parts.count > 1 ? parts[1] : rawID)
    }

    nonisolated private static func idPrefix(for kind: AirframeWorkItemKind) -> String {
        switch kind {
        case .task:
            "T-"
        case .issue:
            "I-"
        case .sprint:
            "SP-"
        case .epic:
            "EP-"
        }
    }

    nonisolated private static func status(from line: String) -> AirframeWorkStatus {
        let normalized = line
            .replacingOccurrences(of: "**Status:**", with: "")
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
        if normalized.contains("implemented - verified")
            || normalized.contains("resolved - verified") {
            return .implementedVerified
        }
        if normalized.contains("implemented")
            || normalized.contains("resolved") {
            return .implementedNotVerified
        }
        if normalized.contains("proposed") { return .proposed }
        if normalized.contains("draft") { return .draft }
        if normalized.contains("planning") { return .planning }
        if normalized.contains("review") { return .review }
        if normalized.contains("complete") { return .complete }
        if normalized.contains("closed") { return .closed }
        if normalized.contains("active") || normalized.contains("in progress") { return .active }
        return .backlog
    }

    nonisolated private static func firstAirframeID(in line: String, prefix: String) -> AirframeID? {
        line
            .split { !$0.isLetter && !$0.isNumber && $0 != "-" }
            .map(String.init)
            .first { $0.hasPrefix(prefix) }
            .map(AirframeID.init)
    }

    nonisolated private static func githubIssueNumber(from line: String) -> Int? {
        line
            .split { !$0.isNumber }
            .compactMap { Int($0) }
            .first
    }

    nonisolated private static func priority(from line: String) -> AirframeWorkPriority {
        let normalized = line.lowercased()
        if normalized.contains("high") { return .high }
        if normalized.contains("low") { return .low }
        return .medium
    }

    nonisolated private static func acceptanceCriteria(from lines: [String]) -> [String] {
        guard let headingIndex = lines.firstIndex(where: { line in
            normalizedHeading(line) == "acceptance criteria"
        }) else {
            return []
        }

        var criteria: [String] = []
        for line in lines.dropFirst(headingIndex + 1) {
            if line.hasPrefix("##") || line.hasPrefix("**") {
                break
            }
            guard let item = markdownListItem(from: line) else {
                continue
            }
            criteria.append(item)
        }
        return criteria
    }

    nonisolated private static func normalizedHeading(_ line: String) -> String {
        line
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#*:"))
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
    }

    nonisolated private static func markdownListItem(from line: String) -> String? {
        var text = line.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return nil }

        if text.hasPrefix("- ") {
            text.removeFirst(2)
        } else if text.hasPrefix("* ") {
            text.removeFirst(2)
        } else {
            let parts = text.split(separator: ".", maxSplits: 1).map(String.init)
            guard parts.count == 2, Int(parts[0]) != nil else {
                return nil
            }
            text = parts[1].trimmingCharacters(in: .whitespaces)
        }

        return text.isEmpty ? nil : text
    }

    nonisolated private static func criterionIndex(from criterionID: AirframeID) -> Int {
        Int(criterionID.rawValue.split(separator: "-").last ?? "") ?? 1
    }

    nonisolated private static func verifiedCriterionLine(from line: String) -> String {
        if line.contains("[x]") || line.contains("[X]") {
            return line
        }
        if line.contains("[ ]") {
            return line.replacingOccurrences(of: "[ ]", with: "[x]")
        }

        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let leadingWhitespace = String(line.prefix { $0 == " " || $0 == "\t" })
        if trimmed.hasPrefix("- ") {
            return "\(leadingWhitespace)- [x] \(trimmed.dropFirst(2))"
        }
        if trimmed.hasPrefix("* ") {
            return "\(leadingWhitespace)* [x] \(trimmed.dropFirst(2))"
        }
        let parts = trimmed.split(separator: ".", maxSplits: 1).map(String.init)
        if parts.count == 2, Int(parts[0]) != nil {
            return "\(leadingWhitespace)\(parts[0]). [x] \(parts[1].trimmingCharacters(in: .whitespaces))"
        }
        return line
    }

    nonisolated private static func epicAcceptanceCriterion(
        epicID: AirframeID,
        index: Int,
        rawText: String
    ) -> AirframeEpicAcceptanceCriterion {
        var text = rawText.trimmingCharacters(in: .whitespaces)
        let isVerified: Bool
        if text.lowercased().hasPrefix("[x]") {
            isVerified = true
            text = String(text.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        } else if text.lowercased().hasPrefix("[ ]") {
            isVerified = false
            text = String(text.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        } else {
            isVerified = false
        }
        return AirframeEpicAcceptanceCriterion(
            id: AirframeID("\(epicID.rawValue)-AC-\(String(format: "%02d", index + 1))"),
            text: text,
            isVerified: isVerified
        )
    }

    nonisolated private static func detailText(for record: AirframeLocalWorkRecord) -> String {
        var lines: [String] = []
        lines.append("ID: \(record.workItem.id.rawValue)")
        lines.append("Kind: \(record.workItem.kind.rawValue)")
        lines.append("Title: \(record.workItem.title)")
        lines.append("Status: \(record.workItem.status.description)")
        lines.append("Priority: \(record.priority.description)")
        lines.append("GitHub Issue: \(record.workItem.githubIssue.map(String.init) ?? "None")")
        lines.append("Epic: \(record.epicID?.rawValue ?? "None")")
        lines.append("Sprint: \(record.sprintID?.rawValue ?? "None")")
        lines.append("")
        lines.append("Acceptance Criteria:")
        appendBlock(record.acceptanceCriteria, to: &lines)
        lines.append("")
        lines.append("Scope:")
        appendBlock(record.scope, to: &lines)
        lines.append("")
        lines.append("Constraints:")
        appendBlock(record.constraints, to: &lines)
        lines.append("")
        lines.append("Evidence Requirements:")
        appendBlock(record.evidenceRequirements, to: &lines)
        lines.append("")
        lines.append("Protected Paths:")
        appendBlock(record.protectedPaths, to: &lines)
        lines.append("")
        lines.append("Report Format:")
        lines.append(record.reportFormat)
        return lines.joined(separator: "\n")
    }

    private func canonicalRelationshipDetailText(for id: AirframeID) -> String? {
        if let epic = canonicalSnapshot.epics.first(where: { $0.workItem.id == id }) {
            return [
                "Canonical Relationships:",
                "Related Sprints: \(Self.idList(epic.sprintIDs))",
                "Related Tasks: \(Self.idList(epic.taskIDs))",
                "Related Issues: \(Self.idList(epic.issueIDs))"
            ].joined(separator: "\n")
        }
        if let sprint = canonicalSnapshot.sprints.first(where: { $0.workItem.id == id }) {
            return [
                "Canonical Relationships:",
                "Epic: \(sprint.epicID?.rawValue ?? "None")",
                "Related Tasks: \(Self.idList(sprint.taskIDs))",
                "Related Issues: \(Self.idList(sprint.issueIDs))"
            ].joined(separator: "\n")
        }
        if let task = canonicalSnapshot.tasks.first(where: { $0.workItem.id == id }) {
            return [
                "Canonical Relationships:",
                "Epic: \(task.epicID?.rawValue ?? "None")",
                "Sprint: \(task.sprintID?.rawValue ?? "None")"
            ].joined(separator: "\n")
        }
        if let issue = canonicalSnapshot.issues.first(where: { $0.workItem.id == id }) {
            return [
                "Canonical Relationships:",
                "Epic: \(issue.epicID?.rawValue ?? "None")",
                "Sprint: \(issue.sprintID?.rawValue ?? "None")"
            ].joined(separator: "\n")
        }
        return nil
    }

    nonisolated private static func appendBlock(_ values: [String], to lines: inout [String]) {
        if values.isEmpty {
            lines.append("None recorded.")
        } else {
            lines.append(contentsOf: values.map { "- \($0)" })
        }
    }

    private func startRefreshObservation(observedURLs: [URL]) {
        refreshObserver = DistributedNotificationCenter.default().addObserver(
            forName: AirframeRefreshNotification.name,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.scheduleRefresh(message: "Refresh notification received.")
            }
        }

        startFileObservation(observedURLs: observedURLs)
    }

    private func startFileObservation(observedURLs: [URL]) {
        #if os(macOS)
        let watchURLs = Set(observedURLs.flatMap { Self.watchURLs(for: $0) })
        for url in watchURLs {
            let descriptor = open(url.path, O_EVTONLY)
            guard descriptor >= 0 else { continue }

            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: descriptor,
                eventMask: [.write, .delete, .rename, .extend, .attrib],
                queue: .main
            )
            source.setEventHandler { [weak self] in
                self?.scheduleRefresh(message: "Airframe files changed; refreshed.")
            }
            source.setCancelHandler {
                close(descriptor)
            }
            fileWatchSources.append(source)
            source.resume()
        }
        #endif
    }

    private func scheduleRefresh(message: String) {
        pendingRefreshWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.refreshFromExternalChange(message: message)
        }
        pendingRefreshWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
    }

    nonisolated static func watchURLs(for url: URL, fileManager: FileManager = .default) -> [URL] {
        let resolvedURL = fileManager.fileExists(atPath: url.path) ? url : url.deletingLastPathComponent()
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: resolvedURL.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            return [resolvedURL]
        }

        var urls = [resolvedURL]
        if let children = try? fileManager.contentsOfDirectory(
            at: resolvedURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) {
            urls.append(contentsOf: children.filter { childURL in
                (try? childURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
            })
        }
        return urls
    }

    private func recordsWithStatus(_ status: AirframeWorkStatus) -> [AirframeLocalWorkRecord] {
        canonicalDashboardRecords
            .filter { $0.workItem.status == status }
            .sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }
    }

    private func actionLabel(_ action: AirframeHumanVerificationAction) -> String {
        switch action {
        case .accept:
            "accepted"
        case .reject:
            "rejected"
        case .requestMoreEvidence:
            "sent back for more evidence"
        }
    }

    private static func auditRow(_ event: AirframeAuditEvent) -> AgileCockpitAuditRow {
        AgileCockpitAuditRow(
            id: event.id.rawValue,
            action: event.action,
            workItemID: event.workItemID?.rawValue ?? "Project",
            reason: event.reason?.rawValue ?? "unknown"
        )
    }

    nonisolated private static func humanReviewerContext(projectID: AirframeID) throws -> AirframeCertifiedContext {
        let actor = AirframeActor(
            id: AirframeID("ACTOR-HUMAN-REVIEWER"),
            displayName: "AgileCockpit Reviewer",
            authorityClass: .humanReviewer,
            credentialSource: .xcodeSession
        )
        let credential = AirframeCredentialContext(
            credentialID: AirframeID("CRED-AGILECOCKPIT-REVIEWER"),
            actorID: actor.id,
            credentialSource: .xcodeSession,
            executionProjectID: projectID,
            allowedProjectIDs: [projectID]
        )
        return try AirframeCertifiedContext(actor: actor, credential: credential, targetProjectID: projectID)
    }

    nonisolated private static func configuredBackend(
        for context: AirframeProjectContext,
        artifactRootURL: URL,
        storeURL: URL,
        githubIssueTransport: (any AirframeGitHubIssueTransport)?
    ) throws -> any AirframeBackend {
        if FileManager.default.fileExists(atPath: artifactRootURL.appending(path: ".airframe/state").path) {
            return AirframeCanonicalStoreBackend(rootURL: artifactRootURL)
        }
        switch AirframeBackendKind(rawValue: context.configuration.backend.kind) {
        case .localFixture:
            return AirframeLocalFilesystemBackend(storeURL: storeURL)
        case .githubFixture:
            return AirframeGitHubFixtureBackend(
                storeURL: storeURL,
                configuration: AirframeGitHubBackendConfiguration(repositorySlug: context.project.repository)
            )
        case .githubIssues:
            return AirframeGitHubIssuesBackend(
                configuration: AirframeGitHubBackendConfiguration(repositorySlug: context.project.repository),
                transport: githubIssueTransport ?? AirframeGitHubCLITransport(),
                controlledMutationsEnabled: true
            )
        case nil:
            throw AirframeConfigurationError.invalidConfiguration("Unsupported backend \(context.configuration.backend.kind).")
        }
    }

    nonisolated private static func configuredRepairBackend(
        for context: AirframeProjectContext,
        artifactRootURL: URL,
        fallbackBackend: any AirframeBackend,
        githubIssueTransport: (any AirframeGitHubIssueTransport)?
    ) throws -> any AirframeBackend {
        guard FileManager.default.fileExists(atPath: artifactRootURL.appending(path: ".airframe/state").path),
              AirframeBackendKind(rawValue: context.configuration.backend.kind) == .githubIssues else {
            return fallbackBackend
        }
        return AirframeGitHubIssuesBackend(
            configuration: AirframeGitHubBackendConfiguration(repositorySlug: context.project.repository),
            transport: githubIssueTransport ?? AirframeGitHubCLITransport(),
            controlledMutationsEnabled: true
        )
    }

    nonisolated private static func capabilities(for backendKind: String) -> AirframeBackendCapabilities {
        switch AirframeBackendKind(rawValue: backendKind) {
        case .localFixture:
            .localFilesystem
        case .githubFixture:
            .githubFixture
        case .githubIssues:
            .githubIssuesReadOnly
        case nil:
            AirframeBackendCapabilities(
                backendKind: backendKind,
                supportsCreateWorkItem: false,
                supportsUpdateWorkItem: false,
                supportsEvidenceAttachment: false,
                supportsTaskPacket: false,
                supportsDashboardSummary: false
            )
        }
    }

    fileprivate static func fallback(message: String) -> AgileCockpitDashboardModel {
        let project = AirframeProject(
            id: AirframeID("PRJ-UNAVAILABLE"),
            name: "Unavailable Project",
            repository: "unknown",
            activeSprintID: nil,
            activeEpicID: nil
        )
        let configuration = AirframeWorkspaceConfiguration(
            schemaVersion: 1,
            workspace: AirframeWorkspace(
                id: AirframeID("WS-UNAVAILABLE"),
                name: "Unavailable Workspace",
                rootPath: "."
            ),
            projects: [project],
            defaultProjectID: project.id,
            backend: AirframeBackendReference(kind: "unavailable", location: "unavailable")
        )
        let model = unavailable(context: AirframeProjectContext(configuration: configuration, project: project), error: AirframeConfigurationError.invalidConfiguration(message))
        model.statusMessage = message
        return model
    }

    nonisolated private static func fallbackReviewer(projectID: AirframeID) -> AirframeCertifiedContext {
        let actor = AirframeActor(
            id: AirframeID("ACTOR-FALLBACK-REVIEWER"),
            displayName: "Fallback Reviewer",
            authorityClass: .humanReviewer,
            credentialSource: .xcodeSession
        )
        let credential = AirframeCredentialContext(
            credentialID: AirframeID("CRED-FALLBACK-REVIEWER"),
            actorID: actor.id,
            credentialSource: .xcodeSession,
            executionProjectID: projectID,
            allowedProjectIDs: [projectID]
        )
        return try! AirframeCertifiedContext(
            actor: actor,
            credential: credential,
            targetProjectID: projectID
        )
    }

    private static let sampleRecords: [AirframeLocalWorkRecord] = [
        sampleRecord(id: "T-0041", title: "Add full regression and integration test pass", status: .active),
        sampleRecord(id: "T-0042", title: "Harden CLI output and error contracts", status: .implementedNotVerified),
        sampleRecord(id: "T-0043", title: "Harden AgileCockpit accessibility and UI flows", status: .backlog),
        sampleRecord(id: "T-0044", title: "Add configuration diagnostics and failure handling", status: .backlog, priority: .medium),
        sampleRecord(id: "T-0045", title: "Write release candidate verification documentation", status: .backlog, priority: .medium),
        sampleRecord(id: "T-0040", title: "Integrate GitHub backend status with AgileCockpit", status: .implementedVerified, sprintID: AirframeID("SP-007"), epicID: AirframeID("EP-007")),
        sampleRecord(id: "I-0001", title: "Dashboard status rows need issue counts", kind: .issue, status: .backlog)
    ]

    nonisolated private static func sampleRecord(
        id: String,
        title: String,
        kind: AirframeWorkItemKind = .task,
        status: AirframeWorkStatus,
        priority: AirframeWorkPriority = .high,
        sprintID: AirframeID? = AirframeID("SP-008"),
        epicID: AirframeID? = AirframeID("EP-008")
    ) -> AirframeLocalWorkRecord {
        AirframeLocalWorkRecord(
            workItem: AirframeWorkItem(
                id: AirframeID(id),
                kind: kind,
                title: title,
                status: status,
                githubIssue: githubIssue(for: id, kind: kind)
            ),
            epicID: epicID,
            sprintID: sprintID,
            priority: priority,
            acceptanceCriteria: ["The AgileCockpit MVP presents this work clearly and routes writes through AirframeCore."],
            scope: ["AgileCockpit", "AirframeCore"],
            constraints: ["Keep canonical workflow and authority decisions in AirframeCore."],
            evidenceRequirements: ["Record app, Core, and UI verification commands."]
        )
    }

    nonisolated private static func numericSuffix(from id: String) -> Int? {
        Int(id.split(separator: "-").last.map(String.init) ?? "")
    }

    nonisolated private static func githubIssue(for id: String, kind: AirframeWorkItemKind) -> Int? {
        switch kind {
        case .task, .issue:
            numericSuffix(from: id)
        case .sprint, .epic:
            nil
        }
    }
}

nonisolated private final class AgileCockpitUnavailableBackend: @unchecked Sendable, AirframeBackend {
    let capabilities: AirframeBackendCapabilities

    private let error: Error

    nonisolated init(capabilities: AirframeBackendCapabilities, error: Error) {
        self.capabilities = capabilities
        self.error = error
    }

    nonisolated func listWorkRecords() throws -> [AirframeLocalWorkRecord] {
        []
    }

    nonisolated func workRecord(id: AirframeID) throws -> AirframeLocalWorkRecord? {
        nil
    }

    nonisolated func createWorkRecord(_ record: AirframeLocalWorkRecord) throws {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    nonisolated func updateWorkRecord(_ record: AirframeLocalWorkRecord) throws {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    nonisolated func updateWorkItem(_ workItem: AirframeWorkItem) throws {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    nonisolated func transitionWorkItem(
        id: AirframeID,
        to status: AirframeWorkStatus,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    nonisolated func attachEvidence(_ evidence: AirframeEvidence, to workItemID: AirframeID) throws {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    nonisolated func evidence(for workItemID: AirframeID) throws -> [AirframeEvidence] {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    nonisolated func taskPacket(for workItemID: AirframeID) throws -> AirframeTaskPacket {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    nonisolated func applyHumanVerification(
        action: AirframeHumanVerificationAction,
        to workItemID: AirframeID,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeHumanVerificationResult {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    nonisolated func dashboardSummary() throws -> AirframeDashboardSummary {
        AirframeDashboardSummary(
            totalWorkItemCount: 0,
            activeTaskCount: 0,
            unverifiedTaskCount: 0,
            verifiedTaskCount: 0,
            issueCount: 0,
            nextTask: nil,
            recentEvidenceCount: 0
        )
    }
}

struct AgileCockpitRootView: View {
    @StateObject private var launcher: AgileCockpitLaunchController

    init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        currentDirectoryURL: URL = URL(filePath: FileManager.default.currentDirectoryPath)
    ) {
        _launcher = StateObject(
            wrappedValue: AgileCockpitLaunchController(
                environment: environment,
                currentDirectoryURL: currentDirectoryURL
            )
        )
    }

    var body: some View {
        Group {
            switch launcher.phase {
            case .loading(let message, let progress):
                launchLoadingView(message: message, progress: progress)
            case .loaded(let model):
                ContentView(model: model)
                    .id(ObjectIdentifier(model))
            case .failed(let message):
                launchFailedView(message: message)
            }
        }
        .task {
            launcher.beginLoading()
        }
    }

    private func launchLoadingView(message: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressView(value: progress, total: 1.0)
            Text("Rebuilding...")
                .font(.headline)
            Text(message)
                .foregroundStyle(.secondary)
            Text("\(Int(progress * 100))%")
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 920, minHeight: 640, alignment: .leading)
        .padding(24)
    }

    private func launchFailedView(message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Agile Cockpit could not launch.")
                .font(.headline)
            Text(message)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("Retry") {
                launcher.retry()
            }
            .accessibilityIdentifier("agile-cockpit-launch-retry")
        }
        .frame(minWidth: 920, minHeight: 640, alignment: .leading)
        .padding(24)
    }
}

@MainActor
final class AgileCockpitLaunchController: ObservableObject {
    enum Phase {
        case loading(message: String, progress: Double)
        case loaded(AgileCockpitDashboardModel)
        case failed(message: String)
    }

    @Published var phase: Phase = .loading(message: "Preparing workspace state.", progress: 0.0)

    private let environment: [String: String]
    private let currentDirectoryURL: URL
    private var refreshOnStartup: Bool
    private var loadTask: Task<Void, Never>?

    init(
        environment: [String: String],
        currentDirectoryURL: URL
    ) {
        self.environment = environment
        self.currentDirectoryURL = currentDirectoryURL
        if let cachedLaunchData = try? AgileCockpitDashboardModel.cachedLaunchDataForImmediateDisplay(
            environment: environment,
            currentDirectoryURL: currentDirectoryURL
        ) {
            let model = AgileCockpitDashboardModel(launchData: cachedLaunchData)
            model.statusMessage = "Loaded cached workspace state."
            self.phase = .loaded(model)
            self.refreshOnStartup = false
        } else if let context = try? AirframeRuntimeConfigurationResolver(
            environment: environment,
            currentDirectoryURL: currentDirectoryURL
        ).loadContext() {
            let model = AgileCockpitDashboardModel.unavailable(
                context: context,
                error: AirframeConfigurationError.invalidConfiguration("Refreshing workspace state.")
            )
            model.statusMessage = "Refreshing workspace state."
            self.phase = .loaded(model)
            self.refreshOnStartup = true
        } else {
            let model = (try? AgileCockpitDashboardModel.sample())
                ?? AgileCockpitDashboardModel.fallback(message: "Refreshing workspace state.")
            model.statusMessage = "Refreshing workspace state."
            self.phase = .loaded(model)
            self.refreshOnStartup = true
        }
    }

    deinit {
        loadTask?.cancel()
    }

    func beginLoading() {
        guard loadTask == nil else { return }
        guard refreshOnStartup else { return }
        refreshOnStartup = false
        loadTask = Task.detached(priority: .userInitiated) { [environment, currentDirectoryURL] in
            do {
                let launchData = try AgileCockpitDashboardModel.prepareLaunchData(
                    environment: environment,
                    currentDirectoryURL: currentDirectoryURL,
                    progress: { progress, message in
                        Task { @MainActor in
                            if case .loaded(let model) = self.phase {
                                model.statusMessage = message
                            }
                        }
                    }
                )
                await MainActor.run {
                    self.phase = .loaded(AgileCockpitDashboardModel(launchData: launchData))
                    self.loadTask = nil
                }
            } catch {
                await MainActor.run {
                    if case .loaded(let model) = self.phase {
                        model.statusMessage = "Background refresh failed: \(error)"
                    } else {
                        self.phase = .failed(message: "Launch failed: \(error)")
                    }
                    self.loadTask = nil
                }
            }
        }
    }

    func retry() {
        guard loadTask == nil else { return }
        refreshOnStartup = true
        phase = .loading(message: "Rebuilding workspace state.", progress: 0.0)
        beginLoading()
    }
}

struct ContentView: View {
    @StateObject private var model: AgileCockpitDashboardModel

    init(model: AgileCockpitDashboardModel) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $model.selectedSection) {
                ForEach(AgileCockpitSection.allCases) { section in
                    Text(section.rawValue)
                        .tag(section)
                        .accessibilityIdentifier("agile-cockpit-nav-\(section.accessibilityID)")
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
            .accessibilityIdentifier("agile-cockpit-navigation")
        } detail: {
            VStack(alignment: .leading, spacing: 0) {
                header
                Divider()
                ScrollView {
                    content
                        .padding(20)
                }
                Divider()
                Text(model.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .accessibilityIdentifier("agile-cockpit-status-message")
            }
        }
        .frame(minWidth: 920, minHeight: 640)
        .popover(item: $model.selectedStatusSelection, arrowEdge: .top) { selection in
            StatusDrillDownView(model: model, selection: selection)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.context.projectName)
                    .font(.title)
                    .accessibilityIdentifier("agile-cockpit-project-title")
                Text(model.context.project.repository)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-project")
                Text(model.appStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-title")
                Text(model.backendStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-backend-status")
                Text(model.configurationStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-configuration-status")
                Text("Data Health \(model.dataHealthStatusText)")
                    .font(.caption)
                    .foregroundStyle(model.canonicalDiagnostics.isValid ? Color.secondary : Color.red)
                    .accessibilityIdentifier("agile-cockpit-data-health-status")
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Button {
                    model.refreshFromUserRequest()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("agile-cockpit-refresh")
                Text("Sprint \(model.activeSprintText)")
                    .accessibilityIdentifier("agile-cockpit-active-sprint")
                Text("Epic \(model.activeEpicText) | \(model.coreInfo.summary)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-core-summary")
            }
        }
        .padding(20)
    }

    @ViewBuilder
    private var content: some View {
        switch model.selectedSection {
        case .dashboard:
            dashboardView
        case .verification:
            verificationView
        case .planning:
            planningView
        case .requirements:
            requirementsView
        case .tests:
            testsView
        case .metrics:
            metricsView
        }
    }

    private var dashboardView: some View {
        VStack(alignment: .leading, spacing: 18) {
            dataHealthSection
            statusTileGrid
            dashboardSection("Recently Done", records: model.verifiedRecords)
            dashboardSection("Active", records: model.activeRecords)
            dashboardSection("Ready for Verification", records: model.readyRecords, showsVerificationActions: true)
            dashboardSection("Blocked", records: model.blockedRecords)
            dashboardSection("Upcoming", records: model.upcomingRecords)
            if let nextTask = model.summary.nextTask {
                LabeledContent("Next Task", value: "\(nextTask.id.rawValue) \(nextTask.title)")
                    .accessibilityIdentifier("agile-cockpit-next-task")
            }
        }
        .accessibilityIdentifier("agile-cockpit-dashboard")
    }

    @ViewBuilder
    private var verificationView: some View {
        switch model.verificationQueueState {
        case .loading:
            loadingPanel(title: "Loading Verification Queue")
                .accessibilityIdentifier("agile-cockpit-verification-loading")
        case .failed(let message):
            loadFailedPanel(title: "Verification Queue Load Failed", message: message) {
                model.retryVerificationLoad()
            }
            .accessibilityIdentifier("agile-cockpit-verification-load-failed")
        case .loaded:
            verificationLoadedView
                .accessibilityIdentifier("agile-cockpit-verification")
        }
    }

    private var verificationLoadedView: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Verification Queue")
                    .font(.headline)
                ForEach(model.readyRecords, id: \.workItem.id.rawValue) { record in
                    Button {
                        model.selectVerificationWorkItem(record.workItem.id)
                    } label: {
                        WorkRow(record: record)
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(record.workItem.id.rawValue) \(record.workItem.title)")
                    .accessibilityIdentifier("agile-cockpit-queue-\(record.workItem.id.rawValue)")
                }
                if model.readyRecords.isEmpty {
                    Text("No work is waiting for human verification.")
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("agile-cockpit-empty-verification-queue")
                }
            }
            .frame(maxWidth: 340, alignment: .leading)

            Divider()

            verificationDetail
        }
    }

    @ViewBuilder
    private var verificationDetail: some View {
        switch model.verificationDetailState {
        case .empty:
            Text("Select ready work to review evidence and acceptance criteria.")
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("agile-cockpit-empty-review")
        case .loading(let id):
            loadingPanel(title: "Loading \(id.rawValue)")
                .accessibilityIdentifier("agile-cockpit-review-loading")
        case .failed(_, let message):
            loadFailedPanel(title: "Verification Detail Load Failed", message: message) {
                model.retryVerificationLoad()
            }
            .accessibilityIdentifier("agile-cockpit-review-load-failed")
        case .loaded(let packet):
            VStack(alignment: .leading, spacing: 14) {
                Text(packet.workItem.title)
                    .font(.title3)
                    .accessibilityIdentifier("agile-cockpit-review-title")
                Text(packet.workItem.id.rawValue)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-review-id")

                packetSection("Acceptance Criteria", values: packet.acceptanceCriteria)
                packetSection("Evidence", values: packet.existingEvidence.map { "\($0.id.rawValue): \($0.summary)" })
                packetSection("Constraints", values: packet.constraints)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Reviewer Comment")
                        .font(.headline)
                    TextEditor(text: $model.verificationCommentText)
                        .frame(minHeight: 70)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.25))
                        )
                        .accessibilityIdentifier("agile-cockpit-verification-comment")
                }

                if let actionStatus = model.verificationActionStatusText {
                    Text(actionStatus)
                        .font(.caption)
                        .foregroundStyle(actionStatus.contains("failed") ? Color.red : Color.secondary)
                        .accessibilityIdentifier("agile-cockpit-verification-action-status")
                }

                HStack {
                    Button("Accept") { model.acceptSelectedWork() }
                        .keyboardShortcut(.defaultAction)
                        .disabled(model.isVerificationActionPending)
                        .accessibilityIdentifier("agile-cockpit-accept-work")
                    Button("Reject") { model.rejectSelectedWork() }
                        .disabled(model.isVerificationActionPending)
                        .accessibilityIdentifier("agile-cockpit-reject-work")
                    Button("Request More Evidence") { model.requestMoreEvidenceForSelectedWork() }
                        .disabled(model.isVerificationActionPending)
                        .accessibilityIdentifier("agile-cockpit-request-evidence")
                }
            }
        }
    }

    private func loadingPanel(title: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ProgressView()
                .controlSize(.small)
            Text(title)
                .font(.headline)
            Text("Preparing verification data.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    private func loadFailedPanel(
        title: String,
        message: String,
        retry: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(message)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("Reload") {
                retry()
            }
            .accessibilityIdentifier("agile-cockpit-verification-reload")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    private var planningView: some View {
        VStack(alignment: .leading, spacing: 18) {
            dataHealthSection
            planningTabPicker
            closeEligibilitySection
            planningTabContent
        }
        .accessibilityIdentifier("agile-cockpit-planning")
    }

    private var requirementsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Requirements")
                .font(.headline)
                .accessibilityIdentifier("agile-cockpit-requirements-title")
            requirementGateSection
            requirementTraceabilitySection
        }
        .accessibilityIdentifier("agile-cockpit-requirements")
    }

    private var testsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Tests")
                .font(.headline)
                .accessibilityIdentifier("agile-cockpit-tests-title")
            testSummarySection
            testListAndDetailSection
            testRequirementCoverageSection
            testGapSection
        }
        .accessibilityIdentifier("agile-cockpit-tests")
    }

    private var planningTabPicker: some View {
        Picker("Sprint and Epic View", selection: $model.selectedPlanningTab) {
            ForEach(AgileCockpitPlanningTab.allCases) { tab in
                Text(tab.rawValue)
                    .tag(tab)
                    .accessibilityIdentifier("agile-cockpit-planning-tab-\(tab.accessibilityID)")
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("agile-cockpit-planning-tabs")
    }

    @ViewBuilder
    private var planningTabContent: some View {
        switch model.selectedPlanningTab {
        case .sprintWork:
            VStack(alignment: .leading, spacing: 18) {
                Text("Sprint \(model.activeSprintText)")
                    .font(.headline)
                    .accessibilityIdentifier("agile-cockpit-sprint-view")
                dashboardSection("Sprint Work", records: model.sprintRecords)
                reviewSprintsSection
            }
            .accessibilityIdentifier("agile-cockpit-planning-sprint-work")
        case .epicCriteria:
            VStack(alignment: .leading, spacing: 18) {
                Text("Epic \(model.activeEpicText)")
                    .font(.headline)
                    .accessibilityIdentifier("agile-cockpit-epic-view")
                epicAcceptanceCriteriaSection
            }
            .accessibilityIdentifier("agile-cockpit-planning-epic-criteria")
        case .epicWork:
            VStack(alignment: .leading, spacing: 18) {
                Text("Epic \(model.activeEpicText)")
                    .font(.headline)
                    .accessibilityIdentifier("agile-cockpit-epic-view")
                dashboardSection("Epic Work", records: model.epicRecords)
            }
            .accessibilityIdentifier("agile-cockpit-planning-epic-work")
        }
    }

    private var reviewSprintsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Review Sprints")
                .font(.headline)
            if model.reviewSprintRecords.isEmpty {
                Text("None")
                    .foregroundStyle(.secondary)
            } else {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(model.reviewSprintRecords, id: \.workItem.id.rawValue) { sprint in
                            Button {
                                model.selectReviewSprint(sprint)
                            } label: {
                                HStack(spacing: 8) {
                                    Text(sprint.workItem.id.rawValue)
                                        .fontWeight(model.selectedReviewSprintRecord?.workItem.id == sprint.workItem.id ? .semibold : .regular)
                                    Text(sprint.workItem.title)
                                        .lineLimit(1)
                                }
                            }
                            .buttonStyle(.borderless)
                            .accessibilityIdentifier("agile-cockpit-review-sprint-\(sprint.workItem.id.rawValue)")
                        }
                    }
                    .frame(minWidth: 220, alignment: .leading)

                    if let sprint = model.selectedReviewSprintRecord {
                        VStack(alignment: .leading, spacing: 6) {
                            LabeledContent("Sprint", value: sprint.workItem.id.rawValue)
                            LabeledContent("Status", value: sprint.workItem.status.description)
                            LabeledContent("Epic", value: sprint.epicID?.rawValue ?? "None")
                            LabeledContent("Tasks", value: sprint.taskIDs.map(\.rawValue).joined(separator: ", "))
                            LabeledContent("Issues", value: sprint.issueIDs.map(\.rawValue).joined(separator: ", "))
                            Button("Return to Backlog") {
                                model.returnSelectedReviewSprintToBacklog()
                            }
                            .accessibilityIdentifier("agile-cockpit-return-review-sprint-to-backlog")
                        }
                        .accessibilityIdentifier("agile-cockpit-review-sprint-detail")
                    }
                }
                dashboardSection("Review Sprint Work", records: model.selectedReviewSprintWorkRecords)
            }
        }
        .accessibilityIdentifier("agile-cockpit-review-sprints")
    }

    private var closeEligibilitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Close Eligibility")
                .font(.headline)
            if let sprintEligibility = model.sprintCloseEligibility {
                eligibilityRow(
                    title: "Sprint",
                    isEligible: sprintEligibility.eligibility.isEligible,
                    detail: sprintEligibility.eligibility.isEligible
                        ? "All assigned Tasks and Issues are verified."
                        : sprintEligibility.eligibility.blockingReasons.joined(separator: " ")
                )
                .accessibilityIdentifier("agile-cockpit-sprint-close-eligibility")
                Button("Close Sprint") {
                    model.closeActiveSprint()
                }
                .disabled(!sprintEligibility.eligibility.isEligible)
                .accessibilityHint(
                    sprintEligibility.eligibility.isEligible
                        ? "Moves the active Sprint to Review."
                        : "All assigned Tasks and Issues must be verified before close."
                )
                .accessibilityIdentifier("agile-cockpit-close-sprint")
                if model.activeSprintRecord?.workItem.status == .active {
                    Button("Return Active Sprint to Backlog") {
                        model.returnActiveSprintToBacklog()
                    }
                    .accessibilityHint("Moves the current active Sprint back to Backlog and clears the active Sprint pointer.")
                    .accessibilityIdentifier("agile-cockpit-return-active-sprint-to-backlog")
                }
            }
            if let epicEligibility = model.epicCloseEligibility {
                eligibilityRow(
                    title: "Epic",
                    isEligible: epicEligibility.eligibility.isEligible,
                    detail: epicEligibility.eligibility.isEligible
                        ? "All Epic acceptance criteria are verified."
                        : epicEligibility.eligibility.blockingReasons.joined(separator: " ")
                )
                .accessibilityIdentifier("agile-cockpit-epic-close-eligibility")
                Button("Close Epic") {
                    model.closeActiveEpic()
                }
                .disabled(!epicEligibility.eligibility.isEligible)
                .accessibilityHint(
                    epicEligibility.eligibility.isEligible
                        ? "Moves the active Epic to Closed."
                        : "All Epic acceptance criteria must be verified before close."
                )
                .accessibilityIdentifier("agile-cockpit-close-epic")
            }
        }
        .accessibilityIdentifier("agile-cockpit-close-eligibility")
    }

    private var requirementGateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Release Gate")
                .font(.headline)
            HStack(spacing: 12) {
                gateMetric("Total", "\(model.requirementCoverageSummary.totalRequirementCount)")
                gateMetric("Assigned", "\(model.requirementCoverageSummary.assignedRequirementCount)")
                gateMetric("Implemented", "\(model.requirementCoverageSummary.implementedRequirementCount)")
                gateMetric("Verified", "\(model.requirementCoverageSummary.verifiedRequirementCount)")
                gateMetric("Unassigned", "\(model.requirementCoverageSummary.unassignedRequirementCount)")
            }
            LabeledContent("Scope", value: model.requirementGateSummary.releaseScope ?? "All requirements")
            LabeledContent("Can Close", value: model.requirementGateSummary.canClose ? "Yes" : "No")
            HStack(spacing: 12) {
                gateMetric("In Scope", "\(model.requirementGateSummary.inScopeRequirementIDs.count)")
                gateMetric("Implemented", "\(model.requirementGateSummary.implementedCount)")
                gateMetric("Verified", "\(model.requirementGateSummary.verifiedCount)")
                gateMetric("Validated", "\(model.requirementGateSummary.validatedCount)")
                gateMetric("Blocked", "\(model.requirementGateSummary.blockedCount)")
            }
            if model.requirementGateSummary.blockingReasons.isEmpty {
                Text("No blocking traceability gaps were found.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.requirementGateSummary.blockingReasons, id: \.self) { reason in
                    Text(reason)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityIdentifier("agile-cockpit-requirement-gate")
    }

    private var requirementTraceabilitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Traceability Matrix")
                .font(.headline)
            if model.requirementTraceRows.isEmpty {
                Text("No requirements are recorded in canonical state.")
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-requirements-empty")
            } else {
                ForEach(model.requirementTraceRows) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(row.requirementID)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 82, alignment: .leading)
                            Text(row.title)
                                .font(.caption)
                                .frame(width: 220, alignment: .leading)
                            Text(row.status)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 110, alignment: .leading)
                            Text(row.acceptanceCriteria.isEmpty ? "No acceptance criteria" : row.acceptanceCriteria)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        if !row.acceptanceCriteria.isEmpty {
                            Text(row.statement)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            Text("Gaps")
                .font(.headline)
            if model.requirementGapRows.isEmpty {
                Text("No gaps recorded.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.requirementGapRows) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(row.requirementID)
                                .font(.caption)
                                .frame(width: 82, alignment: .leading)
                            Text(row.kind)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 180, alignment: .leading)
                        }
                        Text(row.message)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .accessibilityIdentifier("agile-cockpit-requirement-traceability")
    }

    private var testSummarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Canonical Test Summary")
                .font(.headline)
            HStack(spacing: 12) {
                gateMetric("Tests", "\(model.testRows.count)")
                gateMetric("Requirements", "\(model.testCoverageRows.count)")
                gateMetric("Gaps", "\(model.testGapRows.count)")
            }
        }
        .accessibilityIdentifier("agile-cockpit-test-summary")
    }

    private var testListAndDetailSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Test Definitions")
                .font(.headline)
            if model.testRows.isEmpty {
                Text("No canonical tests are recorded.")
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-tests-empty")
            } else {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(model.canonicalSnapshot.tests, id: \.id.rawValue) { test in
                            Button {
                                model.selectTest(test)
                            } label: {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(test.id.rawValue)
                                        .fontWeight(model.selectedTestRecord?.id == test.id ? .semibold : .regular)
                                        .frame(width: 96, alignment: .leading)
                                    Text(test.title)
                                        .lineLimit(1)
                                    Spacer(minLength: 0)
                                    Text(test.kind.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(test.status.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 6)
                                .background(
                                    model.selectedTestRecord?.id == test.id
                                        ? Color.accentColor.opacity(0.12)
                                        : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(test.id.rawValue) \(test.title) \(test.kind.rawValue) \(test.status.rawValue)")
                            .accessibilityIdentifier("agile-cockpit-test-\(test.id.rawValue)")
                        }
                    }
                    .frame(maxWidth: 420, alignment: .leading)

                    Divider()

                    testDetailView
                }
            }
        }
        .accessibilityIdentifier("agile-cockpit-test-definitions")
    }

    @ViewBuilder
    private var testDetailView: some View {
        if let test = model.selectedTestRecord {
            VStack(alignment: .leading, spacing: 10) {
                Text(test.id.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-selected-test-id")
                Text(test.title)
                    .font(.title3)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("agile-cockpit-selected-test-title")
                Text(test.objective)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("agile-cockpit-selected-test-objective")
                LabeledContent("Kind", value: test.kind.rawValue)
                LabeledContent("Status", value: test.status.rawValue)
                LabeledContent("Requirements", value: test.requirementIDs.map(\.rawValue).joined(separator: ", "))
                LabeledContent("Acceptance Criteria", value: test.acceptanceCriterionIDs.map(\.rawValue).joined(separator: ", "))
                LabeledContent("Work Items", value: test.workItemIDs.map(\.rawValue).joined(separator: ", "))

                Text("Steps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(test.steps.isEmpty ? ["None recorded."] : test.steps, id: \.self) { step in
                    Text(step)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("Expected Results")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(test.expectedResults.isEmpty ? ["None recorded."] : test.expectedResults, id: \.self) { result in
                    Text(result)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("Automation")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(test.automationCommand ?? "None recorded.")
                    .fixedSize(horizontal: false, vertical: true)

                Text("Artifacts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(test.artifactReferences.isEmpty ? ["None recorded."] : test.artifactReferences, id: \.self) { artifact in
                    Text(artifact)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("Notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(test.notes.isEmpty ? ["None recorded."] : test.notes, id: \.self) { note in
                    Text(note)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("agile-cockpit-test-detail")
        } else {
            Text("Select a Test definition.")
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("agile-cockpit-test-detail-empty")
        }
    }

    private var testRequirementCoverageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Requirement Coverage")
                .font(.headline)
            if model.testCoverageRows.isEmpty {
                Text("No requirement trace coverage is recorded.")
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-tests-coverage-empty")
            } else {
                ForEach(model.testCoverageRows) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(row.requirementID)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 82, alignment: .leading)
                            Text(row.title)
                                .font(.caption)
                                .frame(width: 220, alignment: .leading)
                            Text(row.status)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 110, alignment: .leading)
                            Text(row.tests.isEmpty ? "No tests" : row.tests)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        if !row.acceptanceCriteria.isEmpty {
                            Text(row.acceptanceCriteria)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .accessibilityIdentifier("agile-cockpit-test-requirement-coverage")
    }

    private var testGapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Test Link Gaps")
                .font(.headline)
            if model.testGapRows.isEmpty {
                Text("No test link gaps recorded.")
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-tests-gaps-empty")
            } else {
                ForEach(model.testGapRows) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(row.requirementID)
                                .font(.caption)
                                .frame(width: 82, alignment: .leading)
                            Text(row.kind)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 180, alignment: .leading)
                        }
                        Text(row.message)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .accessibilityIdentifier("agile-cockpit-test-gaps")
    }

    private func gateMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .monospacedDigit()
        }
        .frame(minWidth: 78, alignment: .leading)
        .padding(6)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var epicAcceptanceCriteriaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Epic Acceptance Criteria")
                .font(.headline)
            if let summary = model.epicAcceptanceCriteriaSummary, summary.hasCriteria {
                Text("\(summary.verifiedCount) of \(summary.totalCount) verified")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-epic-criteria-summary")
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(summary.criteria) { criterion in
                            Button {
                                model.selectEpicAcceptanceCriterion(criterion)
                            } label: {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(criterion.isVerified ? "Verified" : "Unverified")
                                        .font(.caption)
                                        .foregroundStyle(criterion.isVerified ? .green : .secondary)
                                        .frame(width: 72, alignment: .leading)
                                    Text(criterion.text)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 0)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 6)
                                .background(
                                    model.selectedEpicAcceptanceCriterion?.id == criterion.id
                                        ? Color.accentColor.opacity(0.12)
                                        : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(criterion.id.rawValue) \(criterion.isVerified ? "verified" : "unverified") \(criterion.text)")
                            .accessibilityIdentifier("agile-cockpit-epic-criterion-\(criterion.id.rawValue)")
                        }
                    }
                    .frame(maxWidth: 420, alignment: .leading)

                    Divider()

                    epicAcceptanceCriteriaDetail
                }
            } else {
                Text("No acceptance criteria are recorded.")
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-epic-criteria-empty")
            }
        }
        .accessibilityIdentifier("agile-cockpit-epic-acceptance-criteria")
    }

    @ViewBuilder
    private var epicAcceptanceCriteriaDetail: some View {
        if let criterion = model.selectedEpicAcceptanceCriterion {
            VStack(alignment: .leading, spacing: 10) {
                Text(criterion.id.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-selected-epic-criterion-id")
                Text(criterion.text)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("agile-cockpit-selected-epic-criterion-text")
                LabeledContent("Status", value: criterion.isVerified ? "Verified" : "Unverified")
                    .accessibilityIdentifier("agile-cockpit-selected-epic-criterion-status")
                Text("Evidence")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Verification is recorded in the Epic acceptance criteria checklist and audit log.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("agile-cockpit-selected-epic-criterion-evidence")
                Button("Mark Verified") {
                    model.verifySelectedEpicAcceptanceCriterion()
                }
                .disabled(criterion.isVerified)
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier("agile-cockpit-verify-epic-criterion")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("agile-cockpit-epic-criterion-detail")
        } else {
            Text("Select an Epic acceptance criterion.")
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("agile-cockpit-epic-criterion-detail-empty")
        }
    }

    private func eligibilityRow(
        title: String,
        isEligible: Bool,
        detail: String
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 54, alignment: .leading)
            Text(isEligible ? "Eligible" : "Blocked")
                .font(.caption)
                .foregroundStyle(isEligible ? .green : .secondary)
                .frame(width: 64, alignment: .leading)
            Text(detail.isEmpty ? "No blocking details recorded." : detail)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var metricsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            dataHealthSection
            statusTileGrid
            Text("Audit")
                .font(.headline)
            ForEach(model.auditRows) { row in
                HStack {
                    Text(row.id).frame(width: 140, alignment: .leading)
                    Text(row.action)
                    Spacer()
                    Text(row.workItemID)
                    Text(row.reason).foregroundStyle(.secondary)
                }
                .font(.caption)
                .accessibilityIdentifier("agile-cockpit-audit-\(row.id)")
            }
        }
        .accessibilityIdentifier("agile-cockpit-metrics-audit")
    }

    private var dataHealthSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Data Health")
                    .font(.headline)
                Text(model.dataHealthStatusText)
                    .font(.caption)
                    .foregroundStyle(model.canonicalDiagnostics.isValid ? Color.secondary : Color.red)
                    .accessibilityIdentifier("agile-cockpit-data-health-summary")
            }
            if model.diagnosticRows.isEmpty {
                Text("No diagnostics")
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-data-health-empty")
            } else {
                ForEach(model.diagnosticRows) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(row.severity)
                                .font(.caption)
                                .foregroundStyle(row.severity == "blocking" || row.severity == "error" ? Color.red : Color.secondary)
                                .frame(width: 58, alignment: .leading)
                            Text(row.reason)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(row.affectedIDs)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(row.message)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)
                    .accessibilityIdentifier("agile-cockpit-diagnostic-\(row.id)")
                }
                repairPreviewSection
            }
        }
        .accessibilityIdentifier("agile-cockpit-data-health")
    }

    private var repairPreviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repair Preview")
                .font(.subheadline)
            if model.repairPreviewRows.isEmpty {
                Text("No repair options")
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-repair-preview-empty")
            } else {
                ForEach(model.repairPreviewRows) { row in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(row.title)
                            Text("\(row.actionText) | \(row.affectedIDsText)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(row.requiresHumanApproval ? "Human Approval Required" : "Apply") {
                            model.applyRepair(row)
                        }
                            .disabled(row.requiresHumanApproval)
                            .accessibilityIdentifier("agile-cockpit-repair-preview-\(row.id)")
                    }
                }
            }
        }
        .accessibilityIdentifier("agile-cockpit-repair-preview")
    }

    private var statusTileGrid: some View {
        HStack(alignment: .top, spacing: 6) {
            ForEach(model.statusTiles) { tile in
                VStack(alignment: .leading, spacing: 8) {
                    Text(tile.title)
                        .font(.headline)
                    ForEach(tile.rows) { row in
                        Button {
                            model.showStatusItems(tile: tile, row: row)
                        } label: {
                            HStack(spacing: 4) {
                                Text(row.symbol)
                                    .font(.caption)
                                    .frame(width: 18, alignment: .leading)
                                Text(row.title)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .accessibilityIdentifier("agile-cockpit-status-\(row.id)")
                                Text("\(row.count)")
                                    .font(.caption2)
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                                    .frame(width: 22, alignment: .trailing)
                            }
                            .contentShape(Rectangle())
                            .accessibilityIdentifier("agile-cockpit-status-\(row.id)")
                        }
                        .buttonStyle(.plain)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(row.symbol) \(row.title) \(row.count)")
                        .accessibilityIdentifier("agile-cockpit-status-\(row.id)")
                    }
                }
                .padding(6)
                .frame(width: 138, alignment: .topLeading)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityIdentifier("agile-cockpit-status-tile-\(tile.id)")
            }
        }
    }

    private func dashboardSection(
        _ title: String,
        records: [AirframeLocalWorkRecord],
        showsVerificationActions: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            if records.isEmpty {
                Text("None")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(records, id: \.workItem.id.rawValue) { record in
                    VStack(alignment: .leading, spacing: 4) {
                        WorkRow(record: record)
                        if showsVerificationActions {
                            HStack(spacing: 8) {
                                Button("Accept") {
                                    model.selectVerificationWorkItem(record.workItem.id)
                                    model.acceptSelectedWork()
                                }
                                .disabled(model.isVerificationActionPending)
                                .accessibilityIdentifier("agile-cockpit-dashboard-accept-\(record.workItem.id.rawValue)")
                                Button("Reject") {
                                    model.selectVerificationWorkItem(record.workItem.id)
                                    model.rejectSelectedWork()
                                }
                                .disabled(model.isVerificationActionPending)
                                .accessibilityIdentifier("agile-cockpit-dashboard-reject-\(record.workItem.id.rawValue)")
                                Button("Request More Evidence") {
                                    model.selectVerificationWorkItem(record.workItem.id)
                                    model.requestMoreEvidenceForSelectedWork()
                                }
                                .disabled(model.isVerificationActionPending)
                                .accessibilityIdentifier("agile-cockpit-dashboard-request-evidence-\(record.workItem.id.rawValue)")
                            }
                            .buttonStyle(.borderless)
                            .font(.caption)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("agile-cockpit-section-\(title.replacingOccurrences(of: " ", with: "-").lowercased())")
    }

    private func packetSection(_ title: String, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            ForEach(values.isEmpty ? ["None recorded."] : values, id: \.self) { value in
                Text(value)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct StatusDetailRecord {
    let record: AirframeLocalWorkRecord
    let detailText: String
}

private struct WorkRow: View {
    let record: AirframeLocalWorkRecord

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(record.workItem.id.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 64, alignment: .leading)
                .accessibilityIdentifier("agile-cockpit-work-row-id-\(record.workItem.id.rawValue)")
            Text(record.workItem.title)
                .lineLimit(2)
            Spacer()
            Text(displayStatus)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(record.priority.description)
                .font(.caption)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var displayStatus: String {
        switch (record.workItem.kind, record.workItem.status) {
        case (.task, .implementedNotVerified):
            "Implemented"
        case (.task, .implementedVerified):
            "Verified"
        case (.issue, .active):
            "In Progress"
        case (.issue, .implementedNotVerified):
            "Resolved"
        case (.issue, .implementedVerified):
            "Verified"
        default:
            record.workItem.status.description
        }
    }
}

private struct StatusDrillDownView: View {
    @ObservedObject var model: AgileCockpitDashboardModel
    let selection: AgileCockpitStatusSelection

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text("\(selection.tile.title) - \(selection.row.title)")
                    .font(.headline)
                if selection.row.workItems.isEmpty {
                    Text("None")
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(selection.row.workItems, id: \.id.rawValue) { item in
                                Button {
                                    model.selectedStatusWorkItemID = item.id
                                } label: {
                                    HStack {
                                        Text(item.id.rawValue)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 76, alignment: .leading)
                                        Text(item.title)
                                            .lineLimit(2)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background {
                                        if let selectedID = model.selectedStatusWorkItemID, selectedID == item.id {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.accentColor.opacity(0.18))
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .focusable(false)
                                .accessibilityIdentifier("agile-cockpit-status-item-\(item.id.rawValue)")
                            }
                        }
                    }
                    .frame(maxHeight: 440)
                }
            }
            .frame(width: 300, alignment: .leading)

            Divider()

            if let record = model.selectedStatusRecord,
               let detailText = model.selectedStatusDetailText {
                WorkDetail(record: record, detailText: detailText)
                    .id(record.workItem.id.rawValue)
            } else {
                Text("Select an item to view details.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(minWidth: 720, minHeight: 420)
        .accessibilityIdentifier("agile-cockpit-status-drilldown")
    }
}

private struct WorkDetail: View {
    let record: AirframeLocalWorkRecord
    let detailText: String

    var body: some View {
        ScrollView {
            Text(verbatim: detailText)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("agile-cockpit-status-detail-\(record.workItem.id.rawValue)")
    }
}

#Preview {
    ContentView(
        model: try! AgileCockpitDashboardModel.sample()
    )
}
