import Foundation

public struct AirframeBackendCapabilities: Codable, Equatable, Sendable {
    public let backendKind: String
    public let supportsCreateWorkItem: Bool
    public let supportsUpdateWorkItem: Bool
    public let supportsEvidenceAttachment: Bool
    public let supportsTaskPacket: Bool
    public let supportsDashboardSummary: Bool
    public let supportsGitHubIssues: Bool
    public let supportsGitHubLabels: Bool
    public let supportsSprintEpicMapping: Bool
    public let supportsEvidenceReferences: Bool
    public let supportsGitHubIssueComments: Bool
    public let supportsGitHubStatusMutations: Bool

    public init(
        backendKind: String = "local-fixture",
        supportsCreateWorkItem: Bool,
        supportsUpdateWorkItem: Bool,
        supportsEvidenceAttachment: Bool,
        supportsTaskPacket: Bool,
        supportsDashboardSummary: Bool,
        supportsGitHubIssues: Bool = false,
        supportsGitHubLabels: Bool = false,
        supportsSprintEpicMapping: Bool = false,
        supportsEvidenceReferences: Bool = false,
        supportsGitHubIssueComments: Bool = false,
        supportsGitHubStatusMutations: Bool = false
    ) {
        self.backendKind = backendKind
        self.supportsCreateWorkItem = supportsCreateWorkItem
        self.supportsUpdateWorkItem = supportsUpdateWorkItem
        self.supportsEvidenceAttachment = supportsEvidenceAttachment
        self.supportsTaskPacket = supportsTaskPacket
        self.supportsDashboardSummary = supportsDashboardSummary
        self.supportsGitHubIssues = supportsGitHubIssues
        self.supportsGitHubLabels = supportsGitHubLabels
        self.supportsSprintEpicMapping = supportsSprintEpicMapping
        self.supportsEvidenceReferences = supportsEvidenceReferences
        self.supportsGitHubIssueComments = supportsGitHubIssueComments
        self.supportsGitHubStatusMutations = supportsGitHubStatusMutations
    }

    public static let localFilesystem = AirframeBackendCapabilities(
        backendKind: "local-fixture",
        supportsCreateWorkItem: true,
        supportsUpdateWorkItem: true,
        supportsEvidenceAttachment: true,
        supportsTaskPacket: true,
        supportsDashboardSummary: true
    )

    public static let githubFixture = AirframeBackendCapabilities(
        backendKind: "github-fixture",
        supportsCreateWorkItem: true,
        supportsUpdateWorkItem: true,
        supportsEvidenceAttachment: true,
        supportsTaskPacket: true,
        supportsDashboardSummary: true,
        supportsGitHubIssues: true,
        supportsGitHubLabels: true,
        supportsSprintEpicMapping: true,
        supportsEvidenceReferences: true
    )

    public static let githubIssuesReadOnly = AirframeBackendCapabilities(
        backendKind: "github-issues",
        supportsCreateWorkItem: false,
        supportsUpdateWorkItem: false,
        supportsEvidenceAttachment: false,
        supportsTaskPacket: true,
        supportsDashboardSummary: true,
        supportsGitHubIssues: true,
        supportsGitHubLabels: true,
        supportsSprintEpicMapping: true,
        supportsEvidenceReferences: true
    )

    public static let githubIssuesControlledMutations = AirframeBackendCapabilities(
        backendKind: "github-issues",
        supportsCreateWorkItem: false,
        supportsUpdateWorkItem: false,
        supportsEvidenceAttachment: false,
        supportsTaskPacket: true,
        supportsDashboardSummary: true,
        supportsGitHubIssues: true,
        supportsGitHubLabels: true,
        supportsSprintEpicMapping: true,
        supportsEvidenceReferences: true,
        supportsGitHubIssueComments: true,
        supportsGitHubStatusMutations: true
    )
}

public enum AirframeBackendError: Error, Equatable, CustomStringConvertible, Sendable {
    case missingWorkItem(AirframeID)
    case duplicateWorkItem(AirframeID)
    case unsupportedWorkItemKind(AirframeWorkItemKind)
    case invalidTransition(from: AirframeWorkStatus, to: AirframeWorkStatus)
    case requiresConfirmation(AirframeAuthorityReasonCode)
    case authorityDenied(AirframeAuthorityReasonCode?)
    case unreadableStore(String)
    case unwritableStore(String)
    case decodingFailed(String)
    case encodingFailed(String)
    case githubAccessFailed(String)
    case readOnlyBackend(String)

    public var description: String {
        switch self {
        case .missingWorkItem(let id):
            "Missing work item: \(id.rawValue)"
        case .duplicateWorkItem(let id):
            "Duplicate work item: \(id.rawValue)"
        case .unsupportedWorkItemKind(let kind):
            "Unsupported work item kind: \(kind.rawValue)"
        case .invalidTransition(let from, let to):
            "Invalid workflow transition from \(from.description) to \(to.description)."
        case .requiresConfirmation(let reason):
            "Workflow transition requires confirmation: \(reason.rawValue)"
        case .authorityDenied(let reason):
            "Authority denied workflow transition: \(reason?.rawValue ?? "unknown")"
        case .unreadableStore(let path):
            "Local backend store could not be read: \(path)"
        case .unwritableStore(let path):
            "Local backend store could not be written: \(path)"
        case .decodingFailed(let message):
            "Local backend decoding failed: \(message)"
        case .encodingFailed(let message):
            "Local backend encoding failed: \(message)"
        case .githubAccessFailed(let message):
            "GitHub issue access failed: \(message)"
        case .readOnlyBackend(let operation):
            "GitHub issues backend is read-only and does not support \(operation)."
        }
    }
}

public protocol AirframeBackend {
    var capabilities: AirframeBackendCapabilities { get }

    func listWorkRecords() throws -> [AirframeLocalWorkRecord]
    func workRecord(id: AirframeID) throws -> AirframeLocalWorkRecord?
    func createWorkRecord(_ record: AirframeLocalWorkRecord) throws
    func updateWorkItem(_ workItem: AirframeWorkItem) throws
    func transitionWorkItem(
        id: AirframeID,
        to status: AirframeWorkStatus,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws
    func attachEvidence(_ evidence: AirframeEvidence, to workItemID: AirframeID) throws
    func evidence(for workItemID: AirframeID) throws -> [AirframeEvidence]
    func taskPacket(for workItemID: AirframeID) throws -> AirframeTaskPacket
    func applyHumanVerification(
        action: AirframeHumanVerificationAction,
        to workItemID: AirframeID,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeHumanVerificationResult
    func dashboardSummary() throws -> AirframeDashboardSummary
}

public extension AirframeBackend {
    func listWorkItems() throws -> [AirframeWorkItem] {
        try listWorkRecords().map(\.workItem)
    }
}

public final class AirframeLocalFilesystemBackend: @unchecked Sendable, AirframeBackend {
    public let capabilities: AirframeBackendCapabilities = .localFilesystem

    private let storeURL: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let lock = NSLock()

    public init(
        rootURL: URL,
        fileManager: FileManager = .default,
        encoder: JSONEncoder = AirframeLocalFilesystemBackend.makeEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.storeURL = rootURL.appending(path: "airframe-local-backend.json")
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
    }

    public init(
        storeURL: URL,
        fileManager: FileManager = .default,
        encoder: JSONEncoder = AirframeLocalFilesystemBackend.makeEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.storeURL = storeURL
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
    }

    public func listWorkRecords() throws -> [AirframeLocalWorkRecord] {
        try withLockedState { state in
            state.records.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }
        }
    }

    public func workRecord(id: AirframeID) throws -> AirframeLocalWorkRecord? {
        try withLockedState { state in
            state.records.first { $0.workItem.id == id }
        }
    }

    public func createWorkRecord(_ record: AirframeLocalWorkRecord) throws {
        guard record.workItem.kind == .task || record.workItem.kind == .issue else {
            throw AirframeBackendError.unsupportedWorkItemKind(record.workItem.kind)
        }

        try withMutableLockedState { state in
            guard !state.records.contains(where: { $0.workItem.id == record.workItem.id }) else {
                throw AirframeBackendError.duplicateWorkItem(record.workItem.id)
            }
            state.records.append(record)
        }
    }

    public func updateWorkItem(_ workItem: AirframeWorkItem) throws {
        try withMutableLockedState { state in
            guard let index = state.records.firstIndex(where: { $0.workItem.id == workItem.id }) else {
                throw AirframeBackendError.missingWorkItem(workItem.id)
            }
            state.records[index] = state.records[index].updating(workItem: workItem)
        }
    }

    public func transitionWorkItem(
        id: AirframeID,
        to status: AirframeWorkStatus,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws {
        try withMutableLockedState { state in
            guard let index = state.records.firstIndex(where: { $0.workItem.id == id }) else {
                throw AirframeBackendError.missingWorkItem(id)
            }

            let record = state.records[index]
            let operation = AirframeOperation(
                id: operationID(for: status),
                category: operationCategory(for: status)
            )
            let transition = AirframeWorkflowTransition(
                workItemID: id,
                kind: record.workItem.kind,
                fromStatus: record.workItem.status,
                toStatus: status,
                operation: operation
            )
            let decision = AirframeWorkflowTransitionEvaluator().evaluate(
                context: context,
                transition: transition,
                targetProjectID: targetProjectID
            )

            switch decision {
            case .allowed:
                let updated = AirframeWorkItem(
                    id: record.workItem.id,
                    kind: record.workItem.kind,
                    title: record.workItem.title,
                    status: status,
                    githubIssue: record.workItem.githubIssue
                )
                state.records[index] = record.updating(workItem: updated)
            case .requiresConfirmation(let reason):
                throw AirframeBackendError.requiresConfirmation(reason)
            case .denied(let reason, let authorityReason):
                if reason == .invalidTransition {
                    throw AirframeBackendError.invalidTransition(from: record.workItem.status, to: status)
                }
                throw AirframeBackendError.authorityDenied(authorityReason)
            }
        }
    }

    public func attachEvidence(
        _ evidence: AirframeEvidence,
        to workItemID: AirframeID
    ) throws {
        try withMutableLockedState { state in
            guard state.records.contains(where: { $0.workItem.id == workItemID }) else {
                throw AirframeBackendError.missingWorkItem(workItemID)
            }
            var existing = state.evidenceByWorkItemID[workItemID.rawValue] ?? []
            existing.removeAll { $0.id == evidence.id }
            existing.append(evidence)
            state.evidenceByWorkItemID[workItemID.rawValue] = existing.sorted { $0.id.rawValue < $1.id.rawValue }
        }
    }

    public func evidence(for workItemID: AirframeID) throws -> [AirframeEvidence] {
        try withLockedState { state in
            guard state.records.contains(where: { $0.workItem.id == workItemID }) else {
                throw AirframeBackendError.missingWorkItem(workItemID)
            }
            return state.evidenceByWorkItemID[workItemID.rawValue] ?? []
        }
    }

    public func taskPacket(for workItemID: AirframeID) throws -> AirframeTaskPacket {
        try withLockedState { state in
            guard let record = state.records.first(where: { $0.workItem.id == workItemID }) else {
                throw AirframeBackendError.missingWorkItem(workItemID)
            }
            let evidence = state.evidenceByWorkItemID[workItemID.rawValue] ?? []
            return AirframeTaskPacket(
                workItem: record.workItem,
                objective: record.workItem.title,
                scope: record.scope,
                acceptanceCriteria: record.acceptanceCriteria,
                constraints: record.constraints,
                evidenceRequirements: record.evidenceRequirements,
                protectedPaths: record.protectedPaths,
                reportFormat: record.reportFormat,
                existingEvidence: evidence
            )
        }
    }

    public func applyHumanVerification(
        action: AirframeHumanVerificationAction,
        to workItemID: AirframeID,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID
    ) throws -> AirframeHumanVerificationResult {
        try withMutableLockedState { state in
            guard let index = state.records.firstIndex(where: { $0.workItem.id == workItemID }) else {
                throw AirframeBackendError.missingWorkItem(workItemID)
            }

            let record = state.records[index]
            guard record.workItem.status == .implementedNotVerified else {
                throw AirframeBackendError.invalidTransition(
                    from: record.workItem.status,
                    to: action.resultingStatus
                )
            }

            let operation = AirframeOperation(
                id: action.operationID,
                category: .humanAcceptance
            )
            let decision = AirframeAuthorityEvaluator().evaluate(
                context: context,
                operation: operation,
                targetProjectID: targetProjectID
            )

            switch decision {
            case .allowed:
                let updated = AirframeWorkItem(
                    id: record.workItem.id,
                    kind: record.workItem.kind,
                    title: record.workItem.title,
                    status: action.resultingStatus,
                    githubIssue: record.workItem.githubIssue
                )
                state.records[index] = record.updating(workItem: updated)
                return AirframeHumanVerificationResult(
                    action: action,
                    workItem: updated,
                    decision: decision
                )
            case .requiresConfirmation(let reason):
                throw AirframeBackendError.requiresConfirmation(reason)
            case .denied(let reason):
                throw AirframeBackendError.authorityDenied(reason)
            }
        }
    }

    public func dashboardSummary() throws -> AirframeDashboardSummary {
        try withLockedState { state in
            let workItems = state.records.map(\.workItem)
            let tasks = workItems.filter { $0.kind == .task }
            let nextTask = tasks
                .filter { $0.status == .active }
                .sorted { $0.id.rawValue < $1.id.rawValue }
                .first

            return AirframeDashboardSummary(
                totalWorkItemCount: workItems.count,
                activeTaskCount: tasks.filter { $0.status == .active }.count,
                unverifiedTaskCount: tasks.filter { $0.status == .implementedNotVerified }.count,
                verifiedTaskCount: tasks.filter { $0.status == .implementedVerified }.count,
                issueCount: workItems.filter { $0.kind == .issue }.count,
                nextTask: nextTask,
                recentEvidenceCount: state.evidenceByWorkItemID.values.reduce(0) { $0 + $1.count }
            )
        }
    }

    public static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    private func withLockedState<T>(
        _ body: (AirframeLocalBackendState) throws -> T
    ) throws -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body(loadState())
    }

    private func withMutableLockedState<T>(
        _ body: (inout AirframeLocalBackendState) throws -> T
    ) throws -> T {
        lock.lock()
        defer { lock.unlock() }
        var state = try loadState()
        let value = try body(&state)
        try saveState(state)
        return value
    }

    private func loadState() throws -> AirframeLocalBackendState {
        guard fileManager.fileExists(atPath: storeURL.path) else {
            return AirframeLocalBackendState()
        }

        let data: Data
        do {
            data = try Data(contentsOf: storeURL)
        } catch {
            throw AirframeBackendError.unreadableStore(storeURL.path)
        }

        do {
            return try decoder.decode(AirframeLocalBackendState.self, from: data)
        } catch {
            throw AirframeBackendError.decodingFailed(error.localizedDescription)
        }
    }

    private func saveState(_ state: AirframeLocalBackendState) throws {
        let directoryURL = storeURL.deletingLastPathComponent()
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        } catch {
            throw AirframeBackendError.unwritableStore(directoryURL.path)
        }

        let data: Data
        do {
            data = try encoder.encode(state)
        } catch {
            throw AirframeBackendError.encodingFailed(error.localizedDescription)
        }

        do {
            try data.write(to: storeURL, options: .atomic)
        } catch {
            throw AirframeBackendError.unwritableStore(storeURL.path)
        }
    }

    private func operationID(for status: AirframeWorkStatus) -> AirframeID {
        switch status {
        case .backlog:
            AirframeID("OP-RETURN-TO-BACKLOG")
        case .active:
            AirframeID("OP-ACTIVATE-WORK")
        case .implementedNotVerified:
            AirframeID("OP-READY-FOR-VERIFICATION")
        case .implementedVerified:
            AirframeID("OP-HUMAN-VERIFY")
        case .closed:
            AirframeID("OP-CLOSE-WORK")
        }
    }

    private func operationCategory(for status: AirframeWorkStatus) -> AirframeOperationCategory {
        switch status {
        case .implementedVerified:
            .humanAcceptance
        default:
            .workflowTransition
        }
    }
}

private struct AirframeLocalBackendState: Codable, Equatable, Sendable {
    let schemaVersion: Int
    var records: [AirframeLocalWorkRecord]
    var evidenceByWorkItemID: [String: [AirframeEvidence]]

    init(
        schemaVersion: Int = 1,
        records: [AirframeLocalWorkRecord] = [],
        evidenceByWorkItemID: [String: [AirframeEvidence]] = [:]
    ) {
        self.schemaVersion = schemaVersion
        self.records = records
        self.evidenceByWorkItemID = evidenceByWorkItemID
    }
}
