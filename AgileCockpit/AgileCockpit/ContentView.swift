import AirframeCore
import Combine
import Foundation
import SwiftUI

enum AgileCockpitSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case verification = "Verification"
    case planning = "Sprint & Epic"
    case metrics = "Metrics & Audit"

    var id: String { rawValue }
}

struct AgileCockpitMetric: Equatable, Identifiable {
    let id: String
    let title: String
    let value: String
}

struct AgileCockpitAuditRow: Equatable, Identifiable {
    let id: String
    let action: String
    let workItemID: String
    let reason: String
}

@MainActor
final class AgileCockpitDashboardModel: ObservableObject {
    let coreInfo: AirframeCoreInfo
    let context: AirframeProjectContext
    let configurationDiagnostics: AirframeConfigurationDiagnostics

    @Published private(set) var records: [AirframeLocalWorkRecord]
    @Published private(set) var summary: AirframeDashboardSummary
    @Published private(set) var auditRows: [AgileCockpitAuditRow]
    @Published var selectedSection: AgileCockpitSection
    @Published var selectedWorkItemID: AirframeID?
    @Published var statusMessage: String

    private let backend: any AirframeBackend
    private let reviewerContext: AirframeCertifiedContext
    private var auditStore: AirframeAuditEventStore

    init(
        coreInfo: AirframeCoreInfo = .current,
        context: AirframeProjectContext,
        backend: any AirframeBackend,
        reviewerContext: AirframeCertifiedContext,
        auditStore: AirframeAuditEventStore = AirframeAuditEventStore(),
        selectedSection: AgileCockpitSection = .dashboard
    ) throws {
        self.coreInfo = coreInfo
        self.context = context
        self.configurationDiagnostics = AirframeConfigurationLoader().diagnostics(for: context.configuration)
        self.backend = backend
        self.reviewerContext = reviewerContext
        self.auditStore = auditStore
        self.selectedSection = selectedSection
        let loadedRecords = try backend.listWorkRecords()
        self.records = loadedRecords
        self.summary = try backend.dashboardSummary()
        self.auditRows = auditStore.events.map(Self.auditRow)
        self.selectedWorkItemID = loadedRecords.first { $0.workItem.status == .implementedNotVerified }?.workItem.id
        self.statusMessage = "Loaded \(backend.capabilities.backendKind) Airframe workspace."
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
            auditStore: auditStore
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
        guard resolver.configurationURL(explicitPath: configurationURL?.path) != nil else {
            throw AirframeConfigurationError.missingFile(".airframe/airframe-workspace.json")
        }

        let context = try resolver.loadContext(explicitPath: configurationURL?.path)
        let resolvedStoreURL = resolver.storeURL(explicitPath: storeURL?.path)
        let backend = try configuredBackend(
            for: context,
            storeURL: resolvedStoreURL,
            githubIssueTransport: githubIssueTransport
        )
        let reviewer = try humanReviewerContext(projectID: context.project.id)

        return try AgileCockpitDashboardModel(
            context: context,
            backend: backend,
            reviewerContext: reviewer
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

    var backendStatusText: String {
        let capabilities = backend.capabilities
        let githubStatus = capabilities.supportsGitHubIssues ? "GitHub issue mapping on" : "GitHub issue mapping off"
        return "\(capabilities.backendKind) | \(githubStatus)"
    }

    var configurationStatusText: String {
        "Configuration \(configurationDiagnostics.status.rawValue) | \(configurationDiagnostics.projectCount) project(s)"
    }

    var activeSprintText: String {
        context.project.activeSprintID?.rawValue ?? "None"
    }

    var activeEpicText: String {
        context.project.activeEpicID?.rawValue ?? "None"
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
        guard let id = selectedRecord?.workItem.id else { return nil }
        return try? backend.taskPacket(for: id)
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

    var sprintRecords: [AirframeLocalWorkRecord] {
        records.filter { $0.sprintID == context.project.activeSprintID }
    }

    var epicRecords: [AirframeLocalWorkRecord] {
        records.filter { $0.epicID == context.project.activeEpicID }
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

    private func apply(_ action: AirframeHumanVerificationAction) {
        guard let id = selectedRecord?.workItem.id else {
            statusMessage = "No ready work is selected."
            return
        }

        do {
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
            try reload(selecting: readyRecords.first?.workItem.id)
            statusMessage = "\(id.rawValue) \(actionLabel(action))."
        } catch {
            statusMessage = "Verification action failed: \(error)"
        }
    }

    private func reload(selecting id: AirframeID?) throws {
        records = try backend.listWorkRecords()
        summary = try backend.dashboardSummary()
        auditRows = auditStore.events.map(Self.auditRow)
        selectedWorkItemID = id ?? records.first { $0.workItem.status == .implementedNotVerified }?.workItem.id
    }

    private func recordsWithStatus(_ status: AirframeWorkStatus) -> [AirframeLocalWorkRecord] {
        records
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

    private static func humanReviewerContext(projectID: AirframeID) throws -> AirframeCertifiedContext {
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

    private static func configuredBackend(
        for context: AirframeProjectContext,
        storeURL: URL,
        githubIssueTransport: (any AirframeGitHubIssueTransport)?
    ) throws -> any AirframeBackend {
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
                transport: githubIssueTransport ?? AirframeGitHubCLITransport()
            )
        case nil:
            throw AirframeConfigurationError.invalidConfiguration("Unsupported backend \(context.configuration.backend.kind).")
        }
    }

    private static func capabilities(for backendKind: String) -> AirframeBackendCapabilities {
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

    private static func fallback(message: String) -> AgileCockpitDashboardModel {
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

    private static func fallbackReviewer(projectID: AirframeID) -> AirframeCertifiedContext {
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
        sampleRecord(id: "T-0040", title: "Integrate GitHub backend status with AgileCockpit", status: .implementedVerified, sprintID: AirframeID("SP-007"), epicID: AirframeID("EP-007"))
    ]

    private static func sampleRecord(
        id: String,
        title: String,
        status: AirframeWorkStatus,
        priority: AirframeWorkPriority = .high,
        sprintID: AirframeID = AirframeID("SP-008"),
        epicID: AirframeID = AirframeID("EP-008")
    ) -> AirframeLocalWorkRecord {
        AirframeLocalWorkRecord(
            workItem: AirframeWorkItem(
                id: AirframeID(id),
                kind: .task,
                title: title,
                status: status,
                githubIssue: Int(id.dropFirst(2))
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
}

private final class AgileCockpitUnavailableBackend: @unchecked Sendable, AirframeBackend {
    let capabilities: AirframeBackendCapabilities

    private let error: Error

    init(capabilities: AirframeBackendCapabilities, error: Error) {
        self.capabilities = capabilities
        self.error = error
    }

    func listWorkRecords() throws -> [AirframeLocalWorkRecord] {
        []
    }

    func workRecord(id: AirframeID) throws -> AirframeLocalWorkRecord? {
        nil
    }

    func createWorkRecord(_ record: AirframeLocalWorkRecord) throws {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    func updateWorkItem(_ workItem: AirframeWorkItem) throws {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    func transitionWorkItem(
        id: AirframeID,
        to status: AirframeWorkStatus,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    func attachEvidence(_ evidence: AirframeEvidence, to workItemID: AirframeID) throws {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    func evidence(for workItemID: AirframeID) throws -> [AirframeEvidence] {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    func taskPacket(for workItemID: AirframeID) throws -> AirframeTaskPacket {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    func applyHumanVerification(
        action: AirframeHumanVerificationAction,
        to workItemID: AirframeID,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeHumanVerificationResult {
        throw AirframeBackendError.githubAccessFailed("\(error)")
    }

    func dashboardSummary() throws -> AirframeDashboardSummary {
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

struct ContentView: View {
    @StateObject private var model: AgileCockpitDashboardModel

    init(model: AgileCockpitDashboardModel) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $model.selectedSection) {
                ForEach(AgileCockpitSection.allCases) { section in
                    Text(section.rawValue).tag(section)
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
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Agile Cockpit")
                    .font(.title)
                    .accessibilityIdentifier("agile-cockpit-title")
                Text(model.projectStatusText)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-project")
                Text(model.backendStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-backend-status")
                Text(model.configurationStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-configuration-status")
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
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
        case .metrics:
            metricsView
        }
    }

    private var dashboardView: some View {
        VStack(alignment: .leading, spacing: 18) {
            metricStrip
            dashboardSection("Recently Done", records: model.verifiedRecords)
            dashboardSection("Active", records: model.activeRecords)
            dashboardSection("Ready for Verification", records: model.readyRecords)
            dashboardSection("Blocked", records: model.blockedRecords)
            dashboardSection("Upcoming", records: model.upcomingRecords)
            if let nextTask = model.summary.nextTask {
                LabeledContent("Next Task", value: "\(nextTask.id.rawValue) \(nextTask.title)")
                    .accessibilityIdentifier("agile-cockpit-next-task")
            }
        }
        .accessibilityIdentifier("agile-cockpit-dashboard")
    }

    private var verificationView: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Verification Queue")
                    .font(.headline)
                ForEach(model.readyRecords, id: \.workItem.id.rawValue) { record in
                    Button {
                        model.selectedWorkItemID = record.workItem.id
                    } label: {
                        WorkRow(record: record)
                    }
                    .buttonStyle(.plain)
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
        .accessibilityIdentifier("agile-cockpit-verification")
    }

    @ViewBuilder
    private var verificationDetail: some View {
        if let packet = model.selectedPacket {
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

                HStack {
                    Button("Accept") { model.acceptSelectedWork() }
                        .keyboardShortcut(.defaultAction)
                        .accessibilityIdentifier("agile-cockpit-accept-work")
                    Button("Reject") { model.rejectSelectedWork() }
                        .accessibilityIdentifier("agile-cockpit-reject-work")
                    Button("Request More Evidence") { model.requestMoreEvidenceForSelectedWork() }
                        .accessibilityIdentifier("agile-cockpit-request-evidence")
                }
            }
        } else {
            Text("Select ready work to review evidence and acceptance criteria.")
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("agile-cockpit-empty-review")
        }
    }

    private var planningView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Sprint \(model.activeSprintText)")
                .font(.headline)
                .accessibilityIdentifier("agile-cockpit-sprint-view")
            dashboardSection("Sprint Work", records: model.sprintRecords)
            Text("Epic \(model.activeEpicText)")
                .font(.headline)
                .accessibilityIdentifier("agile-cockpit-epic-view")
            dashboardSection("Epic Work", records: model.epicRecords)
        }
    }

    private var metricsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            metricStrip
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

    private var metricStrip: some View {
        HStack(spacing: 12) {
            ForEach(model.metrics) { metric in
                VStack(alignment: .leading, spacing: 4) {
                    Text(metric.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(metric.value)
                        .font(.title2)
                        .monospacedDigit()
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityIdentifier("agile-cockpit-metric-\(metric.id)")
            }
        }
    }

    private func dashboardSection(_ title: String, records: [AirframeLocalWorkRecord]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            if records.isEmpty {
                Text("None")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(records, id: \.workItem.id.rawValue) { record in
                    WorkRow(record: record)
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

private struct WorkRow: View {
    let record: AirframeLocalWorkRecord

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(record.workItem.id.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 64, alignment: .leading)
            Text(record.workItem.title)
                .lineLimit(2)
            Spacer()
            Text(record.workItem.status.description)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(record.priority.description)
                .font(.caption)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ContentView(
        model: try! AgileCockpitDashboardModel.sample()
    )
}
