import Foundation

public struct AirframeID: Codable, Equatable, Hashable, Sendable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

public enum AirframeWorkItemKind: String, Codable, Equatable, Sendable {
    case task
    case issue
    case sprint
    case epic
}

public enum AirframeWorkStatus: String, Codable, Equatable, Sendable {
    case proposed
    case draft
    case backlog
    case planning
    case active
    case review
    case implementedNotVerified
    case implementedVerified
    case complete
    case closed
}

extension AirframeWorkStatus {
    /// Parses a human-authored Markdown status label into a canonical status.
    ///
    /// Markdown artifacts decorate status with leading emoji and trailing
    /// parentheticals, e.g. `🟡 Implemented - Not Verified`, `✅ Closed`, or
    /// `🔴 Open (backlog, not assigned)`. This normalizes such labels by
    /// stripping leading non-alphanumeric decoration and any trailing
    /// parenthetical, then matching the canonical synonyms. Returns `nil` when
    /// the label does not correspond to a known status.
    public static func fromMarkdownLabel(_ rawValue: String) -> AirframeWorkStatus? {
        var normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

        // Drop a trailing parenthetical note, e.g. "Open (backlog, not assigned)".
        if let parenIndex = normalized.firstIndex(of: "(") {
            normalized = String(normalized[..<parenIndex])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // Strip leading decoration (status emoji, symbols, separators) so the
        // first alphabetic character begins the matchable label.
        if let firstLetter = normalized.firstIndex(where: { $0.isLetter }) {
            normalized = String(normalized[firstLetter...])
        }

        switch normalized.lowercased() {
        case "proposed": return .proposed
        case "draft": return .draft
        case "backlog", "open": return .backlog
        case "planning": return .planning
        case "active", "in progress": return .active
        case "review": return .review
        case "implemented", "implemented - not verified",
             "resolved", "resolved - not verified":
            return .implementedNotVerified
        case "verified", "implemented - verified", "resolved - verified":
            return .implementedVerified
        case "complete": return .complete
        case "closed": return .closed
        default: return nil
        }
    }
}

extension AirframeWorkStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .proposed:
            "Proposed"
        case .draft:
            "Draft"
        case .backlog:
            "Backlog"
        case .planning:
            "Planning"
        case .active:
            "Active"
        case .review:
            "Review"
        case .implementedNotVerified:
            "Implemented - Not Verified"
        case .implementedVerified:
            "Implemented - Verified"
        case .complete:
            "Complete"
        case .closed:
            "Closed"
        }
    }
}

public struct AirframeWorkItem: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let kind: AirframeWorkItemKind
    public let title: String
    public let status: AirframeWorkStatus
    public let githubIssue: Int?

    public init(
        id: AirframeID,
        kind: AirframeWorkItemKind,
        title: String,
        status: AirframeWorkStatus,
        githubIssue: Int? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.status = status
        self.githubIssue = githubIssue
    }
}

public enum AirframeWorkPriority: String, Codable, Equatable, Sendable {
    case low
    case medium
    case high
}

extension AirframeWorkPriority: CustomStringConvertible {
    public var description: String {
        switch self {
        case .low:
            "Low"
        case .medium:
            "Medium"
        case .high:
            "High"
        }
    }
}

public enum AirframeRequirementLifecycleStatus: String, Codable, Equatable, Sendable {
    case proposed
    case draft
    case active
    case implemented
    case verified
    case validated
    case deferred
    case waived
    case superseded
    case removed
}

extension AirframeRequirementLifecycleStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .proposed:
            "Proposed"
        case .draft:
            "Draft"
        case .active:
            "Active"
        case .implemented:
            "Implemented"
        case .verified:
            "Verified"
        case .validated:
            "Validated"
        case .deferred:
            "Deferred"
        case .waived:
            "Waived"
        case .superseded:
            "Superseded"
        case .removed:
            "Removed"
        }
    }
}

public enum AirframeRequirementVerificationMethod: String, Codable, Equatable, Sendable {
    case test
    case analysis
    case inspection
    case demonstration
    case review
    case mixed
}

extension AirframeRequirementVerificationMethod: CustomStringConvertible {
    public var description: String {
        switch self {
        case .test:
            "Test"
        case .analysis:
            "Analysis"
        case .inspection:
            "Inspection"
        case .demonstration:
            "Demonstration"
        case .review:
            "Review"
        case .mixed:
            "Mixed"
        }
    }
}

public enum AirframeRequirementSourceKind: String, Codable, Equatable, Sendable {
    case airframe
    case csv
    case json
    case external
    case generated
    case manual
}

public struct AirframeRequirementLink: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let title: String?
    public let targetKind: String
    public let targetID: String

    public init(
        id: AirframeID,
        targetKind: String,
        targetID: String,
        title: String? = nil
    ) {
        self.id = id
        self.title = title
        self.targetKind = targetKind
        self.targetID = targetID
    }
}

public struct AirframeLocalWorkRecord: Codable, Equatable, Sendable {
    public let workItem: AirframeWorkItem
    public let epicID: AirframeID?
    public let sprintID: AirframeID?
    public let priority: AirframeWorkPriority
    public let acceptanceCriteria: [String]
    public let scope: [String]
    public let constraints: [String]
    public let evidenceRequirements: [String]
    public let protectedPaths: [String]
    public let reportFormat: String

    public init(
        workItem: AirframeWorkItem,
        epicID: AirframeID? = nil,
        sprintID: AirframeID? = nil,
        priority: AirframeWorkPriority = .medium,
        acceptanceCriteria: [String] = [],
        scope: [String] = [],
        constraints: [String] = [],
        evidenceRequirements: [String] = [],
        protectedPaths: [String] = [],
        reportFormat: String = "Summarize changes, verification commands, and residual risks."
    ) {
        self.workItem = workItem
        self.epicID = epicID
        self.sprintID = sprintID
        self.priority = priority
        self.acceptanceCriteria = acceptanceCriteria
        self.scope = scope
        self.constraints = constraints
        self.evidenceRequirements = evidenceRequirements
        self.protectedPaths = protectedPaths
        self.reportFormat = reportFormat
    }

    public func updating(workItem: AirframeWorkItem) -> AirframeLocalWorkRecord {
        AirframeLocalWorkRecord(
            workItem: workItem,
            epicID: epicID,
            sprintID: sprintID,
            priority: priority,
            acceptanceCriteria: acceptanceCriteria,
            scope: scope,
            constraints: constraints,
            evidenceRequirements: evidenceRequirements,
            protectedPaths: protectedPaths,
            reportFormat: reportFormat
        )
    }
}

public enum AirframeAcceptanceDisposition: String, Codable, Equatable, Sendable {
    case unverified
    case verified
    case grandfatheredHistoricalClose

    public var displayName: String {
        switch self {
        case .unverified: "Unverified"
        case .verified: "Verified"
        case .grandfatheredHistoricalClose: "Historical Close"
        }
    }
}

public struct AirframeEpicAcceptanceCriterion: Codable, Equatable, Identifiable, Sendable {
    public let id: AirframeID
    public let text: String
    public let disposition: AirframeAcceptanceDisposition

    public init(
        id: AirframeID,
        text: String,
        disposition: AirframeAcceptanceDisposition = .unverified
    ) {
        self.id = id
        self.text = text
        self.disposition = disposition
    }

    public init(id: AirframeID, text: String, isVerified: Bool) {
        self.init(id: id, text: text, disposition: isVerified ? .verified : .unverified)
    }

    public var isVerified: Bool {
        disposition == .verified
    }

    private enum CodingKeys: String, CodingKey {
        case id, text, disposition, isVerified
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(AirframeID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        if let decodedDisposition = try container.decodeIfPresent(AirframeAcceptanceDisposition.self, forKey: .disposition) {
            disposition = decodedDisposition
        } else {
            disposition = try container.decodeIfPresent(Bool.self, forKey: .isVerified) == true ? .verified : .unverified
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(disposition, forKey: .disposition)
        try container.encode(isVerified, forKey: .isVerified)
    }
}

public struct AirframeEpicAcceptanceCriteriaSummary: Codable, Equatable, Sendable {
    public let epicID: AirframeID
    public let criteria: [AirframeEpicAcceptanceCriterion]
    public let allowsHistoricalCloseDisposition: Bool

    public init(
        epicID: AirframeID,
        criteria: [AirframeEpicAcceptanceCriterion],
        allowsHistoricalCloseDisposition: Bool = false
    ) {
        self.epicID = epicID
        self.criteria = criteria
        self.allowsHistoricalCloseDisposition = allowsHistoricalCloseDisposition
    }

    public var totalCount: Int {
        criteria.count
    }

    public var verifiedCount: Int {
        criteria.filter(\.isVerified).count
    }

    public var hasCriteria: Bool {
        !criteria.isEmpty
    }

    public var allCriteriaVerified: Bool {
        hasCriteria && verifiedCount == totalCount
    }

    public var allCriteriaSatisfiedForClose: Bool {
        hasCriteria && criteria.allSatisfy { criterion in
            criterion.disposition == .verified
                || (allowsHistoricalCloseDisposition && criterion.disposition == .grandfatheredHistoricalClose)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case epicID, criteria, allowsHistoricalCloseDisposition
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        epicID = try container.decode(AirframeID.self, forKey: .epicID)
        criteria = try container.decode([AirframeEpicAcceptanceCriterion].self, forKey: .criteria)
        allowsHistoricalCloseDisposition = try container.decodeIfPresent(
            Bool.self,
            forKey: .allowsHistoricalCloseDisposition
        ) ?? false
    }
}

public struct AirframeCloseEligibility: Codable, Equatable, Sendable {
    public let isEligible: Bool
    public let blockingReasons: [String]

    public init(
        isEligible: Bool,
        blockingReasons: [String] = []
    ) {
        self.isEligible = isEligible
        self.blockingReasons = blockingReasons
    }

    public static let eligible = AirframeCloseEligibility(isEligible: true)
}

public struct AirframeSprintCloseEligibility: Codable, Equatable, Sendable {
    public let sprintID: AirframeID
    public let eligibility: AirframeCloseEligibility
    public let blockingWorkItems: [AirframeWorkItem]

    public init(
        sprintID: AirframeID,
        assignedWorkItems: [AirframeWorkItem]
    ) {
        self.sprintID = sprintID
        self.blockingWorkItems = assignedWorkItems.filter { workItem in
            switch workItem.kind {
            case .task, .issue:
                workItem.status != .implementedVerified && workItem.status != .closed
            case .sprint, .epic:
                false
            }
        }.sorted { $0.id.rawValue < $1.id.rawValue }

        if blockingWorkItems.isEmpty {
            self.eligibility = .eligible
        } else {
            self.eligibility = AirframeCloseEligibility(
                isEligible: false,
                blockingReasons: blockingWorkItems.map {
                    "\($0.id.rawValue) is \($0.status.description)"
                }
            )
        }
    }
}

public struct AirframeEpicCloseEligibility: Codable, Equatable, Sendable {
    public let criteriaSummary: AirframeEpicAcceptanceCriteriaSummary
    public let eligibility: AirframeCloseEligibility
    public let blockingSprints: [AirframeWorkItem]

    public init(
        criteriaSummary: AirframeEpicAcceptanceCriteriaSummary,
        relatedSprints: [AirframeWorkItem] = []
    ) {
        self.criteriaSummary = criteriaSummary
        self.blockingSprints = relatedSprints.filter { sprint in
            sprint.kind == .sprint && sprint.status != .closed
        }.sorted { $0.id.rawValue < $1.id.rawValue }

        if criteriaSummary.allCriteriaSatisfiedForClose, blockingSprints.isEmpty {
            self.eligibility = .eligible
        } else if criteriaSummary.criteria.isEmpty {
            let sprintReasons = blockingSprints.map {
                "\($0.id.rawValue) is \($0.status.description)."
            }
            self.eligibility = AirframeCloseEligibility(
                isEligible: false,
                blockingReasons: ["No acceptance criteria are recorded."] + sprintReasons
            )
        } else {
            let unverified = criteriaSummary.criteria.filter { criterion in
                criterion.disposition != .verified
                    && !(criteriaSummary.allowsHistoricalCloseDisposition
                        && criterion.disposition == .grandfatheredHistoricalClose)
            }
            let criteriaReasons = unverified.map {
                if $0.disposition == .grandfatheredHistoricalClose {
                    "\($0.id.rawValue) has a historical-close disposition that is not valid for this Epic."
                } else {
                    "\($0.id.rawValue) is not verified."
                }
            }
            let sprintReasons = blockingSprints.map {
                "\($0.id.rawValue) is \($0.status.description)."
            }
            self.eligibility = AirframeCloseEligibility(
                isEligible: false,
                blockingReasons: criteriaReasons + sprintReasons
            )
        }
    }
}

public enum AirframeAuthorityClass: String, Codable, Equatable, Sendable {
    case humanOwner = "HumanOwner"
    case humanMaintainer = "HumanMaintainer"
    case humanReviewer = "HumanReviewer"
    case llmAgent = "LLMAgent"
    case automation = "Automation"
    case readOnlyObserver = "ReadOnlyObserver"
    case unknown = "Unknown"
}

public enum AirframeCredentialSource: String, Codable, Equatable, Sendable {
    case localSession
    case cliEnvironment
    case xcodeSession
    case githubToken
    case configuredIdentity
    case unknown
}

public struct AirframeActor: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let displayName: String
    public let authorityClass: AirframeAuthorityClass
    public let credentialSource: AirframeCredentialSource
    public let isActive: Bool

    public init(
        id: AirframeID,
        displayName: String,
        authorityClass: AirframeAuthorityClass,
        credentialSource: AirframeCredentialSource,
        isActive: Bool = true
    ) {
        self.id = id
        self.displayName = displayName
        self.authorityClass = authorityClass
        self.credentialSource = credentialSource
        self.isActive = isActive
    }
}

public struct AirframeCredentialContext: Codable, Equatable, Sendable {
    public let credentialID: AirframeID
    public let actorID: AirframeID
    public let credentialSource: AirframeCredentialSource
    public let executionProjectID: AirframeID
    public let allowedProjectIDs: [AirframeID]
    public let expiresAt: Date?

    public init(
        credentialID: AirframeID,
        actorID: AirframeID,
        credentialSource: AirframeCredentialSource,
        executionProjectID: AirframeID,
        allowedProjectIDs: [AirframeID],
        expiresAt: Date? = nil
    ) {
        self.credentialID = credentialID
        self.actorID = actorID
        self.credentialSource = credentialSource
        self.executionProjectID = executionProjectID
        self.allowedProjectIDs = allowedProjectIDs
        self.expiresAt = expiresAt
    }

    public func allowsProject(_ projectID: AirframeID) -> Bool {
        allowedProjectIDs.contains(projectID)
    }
}

public enum AirframeCertificationError: Error, Equatable, CustomStringConvertible, Sendable {
    case inactiveActor(AirframeID)
    case unknownAuthorityClass(AirframeID)
    case actorCredentialMismatch(actorID: AirframeID, credentialActorID: AirframeID)
    case credentialSourceMismatch(actorSource: AirframeCredentialSource, credentialSource: AirframeCredentialSource)
    case executionProjectOutOfScope(AirframeID)
    case targetProjectOutOfScope(AirframeID)
    case expiredCredential(AirframeID)

    public var description: String {
        switch self {
        case .inactiveActor(let actorID):
            "Actor \(actorID.rawValue) is inactive."
        case .unknownAuthorityClass(let actorID):
            "Actor \(actorID.rawValue) has no certified authority class."
        case .actorCredentialMismatch(let actorID, let credentialActorID):
            "Actor \(actorID.rawValue) does not match credential actor \(credentialActorID.rawValue)."
        case .credentialSourceMismatch(let actorSource, let credentialSource):
            "Actor credential source \(actorSource.rawValue) does not match credential source \(credentialSource.rawValue)."
        case .executionProjectOutOfScope(let projectID):
            "Execution project \(projectID.rawValue) is outside credential scope."
        case .targetProjectOutOfScope(let projectID):
            "Target project \(projectID.rawValue) is outside credential scope."
        case .expiredCredential(let credentialID):
            "Credential \(credentialID.rawValue) is expired."
        }
    }
}

public struct AirframeCertifiedContext: Codable, Equatable, Sendable {
    public let actor: AirframeActor
    public let credential: AirframeCredentialContext
    public let executionProjectID: AirframeID
    public let targetProjectID: AirframeID

    public init(
        actor: AirframeActor,
        credential: AirframeCredentialContext,
        targetProjectID: AirframeID,
        now: Date = Date()
    ) throws(AirframeCertificationError) {
        guard actor.isActive else {
            throw .inactiveActor(actor.id)
        }

        guard actor.authorityClass != .unknown else {
            throw .unknownAuthorityClass(actor.id)
        }

        guard actor.id == credential.actorID else {
            throw .actorCredentialMismatch(actorID: actor.id, credentialActorID: credential.actorID)
        }

        guard actor.credentialSource == credential.credentialSource else {
            throw .credentialSourceMismatch(
                actorSource: actor.credentialSource,
                credentialSource: credential.credentialSource
            )
        }

        if let expiresAt = credential.expiresAt {
            guard expiresAt > now else {
                throw .expiredCredential(credential.credentialID)
            }
        }

        guard credential.allowsProject(credential.executionProjectID) else {
            throw .executionProjectOutOfScope(credential.executionProjectID)
        }

        guard credential.allowsProject(targetProjectID) else {
            throw .targetProjectOutOfScope(targetProjectID)
        }

        self.actor = actor
        self.credential = credential
        self.executionProjectID = credential.executionProjectID
        self.targetProjectID = targetProjectID
    }
}

public struct AirframeEvidence: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let summary: String
    public let artifact: String

    public init(id: AirframeID, summary: String, artifact: String) {
        self.id = id
        self.summary = summary
        self.artifact = artifact
    }
}

public struct AirframeGitHubMutationApproval: Codable, Equatable, Sendable {
    public let isApproved: Bool
    public let approvedBy: String
    public let reason: String

    public init(isApproved: Bool, approvedBy: String, reason: String) {
        self.isApproved = isApproved
        self.approvedBy = approvedBy
        self.reason = reason
    }
}

public struct AirframeGitHubMutationResult: Codable, Equatable, Sendable {
    public let workItem: AirframeWorkItem
    public let githubIssue: Int
    public let mutation: String
    public let auditEvent: AirframeAuditEvent

    public init(
        workItem: AirframeWorkItem,
        githubIssue: Int,
        mutation: String,
        auditEvent: AirframeAuditEvent
    ) {
        self.workItem = workItem
        self.githubIssue = githubIssue
        self.mutation = mutation
        self.auditEvent = auditEvent
    }
}

public struct AirframeVerificationGate: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let name: String
    public let requiredAuthorityClass: AirframeAuthorityClass

    public init(id: AirframeID, name: String, requiredAuthorityClass: AirframeAuthorityClass) {
        self.id = id
        self.name = name
        self.requiredAuthorityClass = requiredAuthorityClass
    }
}

public struct AirframeAuditEvent: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let actorID: AirframeID
    public let action: String
    public let workItemID: AirframeID?
    public let decision: AirframeAuthorityDecision?
    public let reason: AirframeAuthorityReasonCode?
    public let targetProjectID: AirframeID?
    public let timestamp: Date?

    public init(id: AirframeID, actorID: AirframeID, action: String, workItemID: AirframeID?) {
        self.id = id
        self.actorID = actorID
        self.action = action
        self.workItemID = workItemID
        self.decision = nil
        self.reason = nil
        self.targetProjectID = nil
        self.timestamp = nil
    }

    public init(
        id: AirframeID,
        actorID: AirframeID,
        action: String,
        workItemID: AirframeID?,
        decision: AirframeAuthorityDecision,
        targetProjectID: AirframeID,
        timestamp: Date
    ) {
        self.id = id
        self.actorID = actorID
        self.action = action
        self.workItemID = workItemID
        self.decision = decision
        self.reason = decision.reason
        self.targetProjectID = targetProjectID
        self.timestamp = timestamp
    }
}

public struct AirframeMetricSnapshot: Codable, Equatable, Sendable {
    public let activeTaskCount: Int
    public let unverifiedTaskCount: Int

    public init(activeTaskCount: Int, unverifiedTaskCount: Int) {
        self.activeTaskCount = activeTaskCount
        self.unverifiedTaskCount = unverifiedTaskCount
    }
}

public struct AirframeTaskPacket: Codable, Equatable, Sendable {
    public let workItem: AirframeWorkItem
    public let objective: String
    public let scope: [String]
    public let acceptanceCriteria: [String]
    public let constraints: [String]
    public let evidenceRequirements: [String]
    public let protectedPaths: [String]
    public let reportFormat: String
    public let existingEvidence: [AirframeEvidence]
    public let diagnostics: [AirframeCanonicalDiagnostic]

    public init(
        workItem: AirframeWorkItem,
        objective: String,
        scope: [String],
        acceptanceCriteria: [String],
        constraints: [String],
        evidenceRequirements: [String],
        protectedPaths: [String],
        reportFormat: String,
        existingEvidence: [AirframeEvidence] = [],
        diagnostics: [AirframeCanonicalDiagnostic] = []
    ) {
        self.workItem = workItem
        self.objective = objective
        self.scope = scope
        self.acceptanceCriteria = acceptanceCriteria
        self.constraints = constraints
        self.evidenceRequirements = evidenceRequirements
        self.protectedPaths = protectedPaths
        self.reportFormat = reportFormat
        self.existingEvidence = existingEvidence
        self.diagnostics = diagnostics
    }
}

public enum AirframeHumanVerificationAction: String, Codable, Equatable, Sendable {
    case accept
    case reject
    case requestMoreEvidence

    public var operationID: AirframeID {
        switch self {
        case .accept:
            AirframeID("OP-HUMAN-ACCEPT-WORK")
        case .reject:
            AirframeID("OP-HUMAN-REJECT-WORK")
        case .requestMoreEvidence:
            AirframeID("OP-HUMAN-REQUEST-EVIDENCE")
        }
    }

    public var resultingStatus: AirframeWorkStatus {
        switch self {
        case .accept:
            .implementedVerified
        case .reject, .requestMoreEvidence:
            .active
        }
    }
}

public struct AirframeHumanVerificationResult: Codable, Equatable, Sendable {
    public let action: AirframeHumanVerificationAction
    public let workItem: AirframeWorkItem
    public let decision: AirframeAuthorityDecision

    public init(
        action: AirframeHumanVerificationAction,
        workItem: AirframeWorkItem,
        decision: AirframeAuthorityDecision
    ) {
        self.action = action
        self.workItem = workItem
        self.decision = decision
    }
}

public struct AirframeDashboardSummary: Codable, Equatable, Sendable {
    public let totalWorkItemCount: Int
    public let activeTaskCount: Int
    public let unverifiedTaskCount: Int
    public let verifiedTaskCount: Int
    public let issueCount: Int
    public let nextTask: AirframeWorkItem?
    public let recentEvidenceCount: Int

    public init(
        totalWorkItemCount: Int,
        activeTaskCount: Int,
        unverifiedTaskCount: Int,
        verifiedTaskCount: Int,
        issueCount: Int,
        nextTask: AirframeWorkItem?,
        recentEvidenceCount: Int
    ) {
        self.totalWorkItemCount = totalWorkItemCount
        self.activeTaskCount = activeTaskCount
        self.unverifiedTaskCount = unverifiedTaskCount
        self.verifiedTaskCount = verifiedTaskCount
        self.issueCount = issueCount
        self.nextTask = nextTask
        self.recentEvidenceCount = recentEvidenceCount
    }
}

public struct AirframeDashboardStatusRow: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let symbol: String
    public let status: AirframeWorkStatus
    public let count: Int
    public let workItems: [AirframeWorkItem]

    public init(
        id: String,
        title: String,
        symbol: String,
        status: AirframeWorkStatus,
        count: Int,
        workItems: [AirframeWorkItem]
    ) {
        self.id = id
        self.title = title
        self.symbol = symbol
        self.status = status
        self.count = count
        self.workItems = workItems
    }
}

public struct AirframeDashboardStatusTile: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let kind: AirframeWorkItemKind
    public let rows: [AirframeDashboardStatusRow]

    public init(
        id: String,
        title: String,
        kind: AirframeWorkItemKind,
        rows: [AirframeDashboardStatusRow]
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.rows = rows
    }
}

public struct AirframeDashboardStatusSummary: Codable, Equatable, Sendable {
    public let tiles: [AirframeDashboardStatusTile]

    public init(tiles: [AirframeDashboardStatusTile]) {
        self.tiles = tiles
    }

    public init(records: [AirframeLocalWorkRecord]) {
        let workItemsByKind = Dictionary(grouping: records.map(\.workItem), by: \.kind)
        self.tiles = [
            Self.tile(
                id: "epics",
                title: "Epics",
                kind: .epic,
                workItems: workItemsByKind[.epic, default: []],
                statuses: [
                    (.proposed, "Proposed", "🔵"),
                    (.draft, "Draft", "🔵"),
                    (.backlog, "Backlog", "⚪"),
                    (.active, "Active", "🟡"),
                    (.complete, "Complete", "🟢"),
                    (.closed, "Closed", "✅")
                ]
            ),
            Self.tile(
                id: "sprints",
                title: "Sprints",
                kind: .sprint,
                workItems: workItemsByKind[.sprint, default: []],
                statuses: [
                    (.backlog, "Backlog", "⚪"),
                    (.planning, "Planning", "🔵"),
                    (.active, "Active", "🟡"),
                    (.review, "Review", "🟣"),
                    (.closed, "Closed", "✅")
                ]
            ),
            Self.tile(
                id: "tasks",
                title: "Tasks",
                kind: .task,
                workItems: workItemsByKind[.task, default: []],
                statuses: [
                    (.backlog, "Backlog", "⚪"),
                    (.active, "Active", "🟡"),
                    (.implementedNotVerified, "Implemented", "🟢"),
                    (.implementedVerified, "Verified", "✅"),
                    (.closed, "Closed", "✅")
                ]
            ),
            Self.tile(
                id: "issues",
                title: "Issues",
                kind: .issue,
                workItems: workItemsByKind[.issue, default: []],
                statuses: [
                    (.backlog, "Backlog", "⚪"),
                    (.active, "In Progress", "🟡"),
                    (.implementedNotVerified, "Resolved", "🟢"),
                    (.implementedVerified, "Verified", "✅"),
                    (.closed, "Closed", "✅")
                ]
            )
        ]
    }

    public static var empty: AirframeDashboardStatusSummary {
        AirframeDashboardStatusSummary(records: [])
    }

    private static func tile(
        id: String,
        title: String,
        kind: AirframeWorkItemKind,
        workItems: [AirframeWorkItem],
        statuses: [(AirframeWorkStatus, String, String)]
    ) -> AirframeDashboardStatusTile {
        let itemsByStatus = Dictionary(grouping: workItems, by: \.status)
        let rows = statuses.map { status, title, symbol in
            let matchingItems = itemsByStatus[status, default: []]
                .sorted { $0.id.rawValue < $1.id.rawValue }
            return AirframeDashboardStatusRow(
                id: "\(id)-\(status.rawValue)",
                title: title,
                symbol: symbol,
                status: status,
                count: matchingItems.count,
                workItems: matchingItems
            )
        }
        return AirframeDashboardStatusTile(id: id, title: title, kind: kind, rows: rows)
    }
}

public struct AirframeBackendReference: Codable, Equatable, Sendable {
    public let kind: String
    public let location: String

    public init(kind: String, location: String) {
        self.kind = kind
        self.location = location
    }
}
