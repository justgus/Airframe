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
        case .metrics:
            "metrics"
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
    @Published private(set) var dashboardRecords: [AirframeLocalWorkRecord]
    @Published private(set) var dashboardDetailTextByID: [AirframeID: String]
    @Published private(set) var summary: AirframeDashboardSummary
    @Published private(set) var auditRows: [AgileCockpitAuditRow]
    @Published var selectedSection: AgileCockpitSection
    @Published var selectedWorkItemID: AirframeID?
    @Published var selectedStatusSelection: AgileCockpitStatusSelection?
    @Published var selectedStatusWorkItemID: AirframeID?
    @Published var statusMessage: String

    private let backend: any AirframeBackend
    private let reviewerContext: AirframeCertifiedContext
    private let artifactRootURL: URL?
    private var auditStore: AirframeAuditEventStore
    private var refreshObserver: NSObjectProtocol?
    private var fileWatchSources: [DispatchSourceFileSystemObject] = []
    private var pendingRefreshWorkItem: DispatchWorkItem?

    init(
        coreInfo: AirframeCoreInfo = .current,
        context: AirframeProjectContext,
        backend: any AirframeBackend,
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
        self.reviewerContext = reviewerContext
        self.artifactRootURL = artifactRootURL
        self.auditStore = auditStore
        self.selectedSection = selectedSection
        let loadedRecords = try backend.listWorkRecords()
        self.records = loadedRecords
        let dashboardData = Self.dashboardData(
            backendRecords: loadedRecords,
            artifactRootURL: artifactRootURL
        )
        self.dashboardRecords = dashboardData.records
        self.dashboardDetailTextByID = dashboardData.detailTextByID
        self.summary = try backend.dashboardSummary()
        self.auditRows = auditStore.events.map(Self.auditRow)
        self.selectedWorkItemID = loadedRecords.first { $0.workItem.status == .implementedNotVerified }?.workItem.id
        self.selectedStatusSelection = nil
        self.selectedStatusWorkItemID = nil
        self.statusMessage = "Loaded \(backend.capabilities.backendKind) Airframe workspace."
        startRefreshObservation(observedURLs: observedURLs)
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
        let backend = try configuredBackend(
            for: context,
            storeURL: resolvedStoreURL,
            githubIssueTransport: githubIssueTransport
        )
        let reviewer = try humanReviewerContext(projectID: context.project.id)

        return try AgileCockpitDashboardModel(
            context: context,
            backend: backend,
            reviewerContext: reviewer,
            observedURLs: [resolvedConfigurationURL, resolvedStoreURL],
            artifactRootURL: Self.artifactRootURL(
                configurationURL: resolvedConfigurationURL,
                context: context
            )
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

    var statusTiles: [AirframeDashboardStatusTile] {
        AirframeDashboardStatusSummary(records: dashboardRecords).tiles
    }

    var sprintRecords: [AirframeLocalWorkRecord] {
        records.filter { $0.sprintID == context.project.activeSprintID }
    }

    var epicRecords: [AirframeLocalWorkRecord] {
        records.filter { $0.epicID == context.project.activeEpicID }
    }

    var selectedStatusRecord: AirframeLocalWorkRecord? {
        guard let selectedStatusWorkItemID else { return nil }
        return dashboardRecords.first { $0.workItem.id == selectedStatusWorkItemID }
    }

    var selectedStatusDetailText: String? {
        guard let selectedStatusWorkItemID else { return nil }
        return dashboardDetailTextByID[selectedStatusWorkItemID]
    }

    func showStatusItems(tile: AirframeDashboardStatusTile, row: AirframeDashboardStatusRow) {
        selectedStatusSelection = AgileCockpitStatusSelection(tile: tile, row: row)
        selectedStatusWorkItemID = nil
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

    func refreshFromExternalChange(message: String = "Refreshed from Airframe state.") {
        do {
            try reload(selecting: selectedWorkItemID)
            statusMessage = message
        } catch {
            statusMessage = "Refresh failed: \(error)"
        }
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
        let dashboardData = Self.dashboardData(
            backendRecords: records,
            artifactRootURL: artifactRootURL
        )
        dashboardRecords = dashboardData.records
        dashboardDetailTextByID = dashboardData.detailTextByID
        summary = try backend.dashboardSummary()
        auditRows = auditStore.events.map(Self.auditRow)
        selectedWorkItemID = id ?? records.first { $0.workItem.status == .implementedNotVerified }?.workItem.id
        if let selectedStatusSelection {
            let refreshedSummary = AirframeDashboardStatusSummary(records: dashboardRecords)
            let refreshedSelection = refreshedSummary.tiles
                .flatMap { tile in tile.rows.map { AgileCockpitStatusSelection(tile: tile, row: $0) } }
                .first { $0.id == selectedStatusSelection.id }
            self.selectedStatusSelection = refreshedSelection
            if let selectedStatusWorkItemID,
               dashboardRecords.contains(where: { $0.workItem.id == selectedStatusWorkItemID }) {
                self.selectedStatusWorkItemID = selectedStatusWorkItemID
            } else {
                self.selectedStatusWorkItemID = refreshedSelection?.row.workItems.first?.id
            }
        }
    }

    private static func artifactRootURL(
        configurationURL: URL,
        context: AirframeProjectContext
    ) -> URL {
        let configuredRootPath = context.configuration.workspace.rootPath
        if configuredRootPath.hasPrefix("/") {
            return URL(filePath: configuredRootPath)
        }
        return configurationURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: configuredRootPath)
            .standardizedFileURL
    }

    private static func dashboardData(
        backendRecords: [AirframeLocalWorkRecord],
        artifactRootURL: URL?
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
        let backendIDs = Set(backendRecords.map(\.workItem.id))
        var detailTextByID = Dictionary(
            uniqueKeysWithValues: backendRecords.map { ($0.workItem.id, detailText(for: $0)) }
        )
        for artifactRecord in artifactRecords {
            detailTextByID[artifactRecord.record.workItem.id] = artifactRecord.detailText
        }
        return (
            records: backendRecords + artifactRecords.map(\.record).filter { !backendIDs.contains($0.workItem.id) },
            detailTextByID: detailTextByID
        )
    }

    private static func localArtifactRecords(rootURL: URL) -> [StatusDetailRecord] {
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
        let verifiedTaskFiles = markdownFiles(in: rootURL.appending(path: "docs/Tasks/Verified"))

        let fullFileRecords = (files + closedFiles).flatMap { fileURL, kind in
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

    private static func markdownFiles(in directoryURL: URL) -> [URL] {
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

    private static func records(
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

        func flush() {
            guard let currentID, let currentTitle, let currentStatus else {
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
                        priority: .medium
                    ),
                    detailText: contents
                )
            )
        }

        for line in contents.components(separatedBy: .newlines) {
            if line.hasPrefix("## ") || line.hasPrefix("# EP-") || line.hasPrefix("# SP-") {
                flush()
                currentStatus = nil
                currentEpicID = nil
                let heading = line.drop { $0 == "#" || $0 == " " }
                let parts = heading.split(separator: ":", maxSplits: 1).map {
                    String($0).trimmingCharacters(in: .whitespaces)
                }
                currentID = parts.first.map(AirframeID.init)
                currentTitle = parts.count > 1 ? parts[1] : parts.first
            } else if line.hasPrefix("**Status:**") {
                currentStatus = status(from: line)
            } else if kind == .sprint, line.hasPrefix("**Epic:**") {
                currentEpicID = firstAirframeID(in: line, prefix: "EP-")
            }
        }

        flush()
        return records
    }

    private static func sectionRecords(
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
                        .map(priority(from:)) ?? .medium
                ),
                detailText: sectionText
            )
        }
    }

    private static func tableTaskRecords(from fileURL: URL) -> [StatusDetailRecord] {
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

    private static func headingIDAndTitle(
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

    private static func idPrefix(for kind: AirframeWorkItemKind) -> String {
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

    private static func status(from line: String) -> AirframeWorkStatus {
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

    private static func firstAirframeID(in line: String, prefix: String) -> AirframeID? {
        line
            .split { !$0.isLetter && !$0.isNumber && $0 != "-" }
            .map(String.init)
            .first { $0.hasPrefix(prefix) }
            .map(AirframeID.init)
    }

    private static func githubIssueNumber(from line: String) -> Int? {
        line
            .split { !$0.isNumber }
            .compactMap { Int($0) }
            .first
    }

    private static func priority(from line: String) -> AirframeWorkPriority {
        let normalized = line.lowercased()
        if normalized.contains("high") { return .high }
        if normalized.contains("low") { return .low }
        return .medium
    }

    private static func detailText(for record: AirframeLocalWorkRecord) -> String {
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

    private static func appendBlock(_ values: [String], to lines: inout [String]) {
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
        let watchURLs = Set(observedURLs.map(Self.watchURL))
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

    private static func watchURL(for url: URL) -> URL {
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        return url.deletingLastPathComponent()
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
                transport: githubIssueTransport ?? AirframeGitHubCLITransport(),
                controlledMutationsEnabled: true
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
        sampleRecord(id: "T-0040", title: "Integrate GitHub backend status with AgileCockpit", status: .implementedVerified, sprintID: AirframeID("SP-007"), epicID: AirframeID("EP-007")),
        sampleRecord(id: "I-0001", title: "Dashboard status rows need issue counts", kind: .issue, status: .backlog)
    ]

    private static func sampleRecord(
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

    private static func numericSuffix(from id: String) -> Int? {
        Int(id.split(separator: "-").last.map(String.init) ?? "")
    }

    private static func githubIssue(for id: String, kind: AirframeWorkItemKind) -> Int? {
        switch kind {
        case .task, .issue:
            numericSuffix(from: id)
        case .sprint, .epic:
            nil
        }
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

    func updateWorkRecord(_ record: AirframeLocalWorkRecord) throws {
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
                                    model.selectedWorkItemID = record.workItem.id
                                    model.acceptSelectedWork()
                                }
                                .accessibilityIdentifier("agile-cockpit-dashboard-accept-\(record.workItem.id.rawValue)")
                                Button("Reject") {
                                    model.selectedWorkItemID = record.workItem.id
                                    model.rejectSelectedWork()
                                }
                                .accessibilityIdentifier("agile-cockpit-dashboard-reject-\(record.workItem.id.rawValue)")
                                Button("Request More Evidence") {
                                    model.selectedWorkItemID = record.workItem.id
                                    model.requestMoreEvidenceForSelectedWork()
                                }
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
