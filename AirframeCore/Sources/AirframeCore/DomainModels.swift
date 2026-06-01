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
    case backlog
    case active
    case implementedNotVerified
    case implementedVerified
    case closed
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

public struct AirframeActor: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let displayName: String
    public let role: String

    public init(id: AirframeID, displayName: String, role: String) {
        self.id = id
        self.displayName = displayName
        self.role = role
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

public struct AirframeVerificationGate: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let name: String
    public let requiredActorRole: String

    public init(id: AirframeID, name: String, requiredActorRole: String) {
        self.id = id
        self.name = name
        self.requiredActorRole = requiredActorRole
    }
}

public struct AirframeAuditEvent: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let actorID: AirframeID
    public let action: String
    public let workItemID: AirframeID?

    public init(id: AirframeID, actorID: AirframeID, action: String, workItemID: AirframeID?) {
        self.id = id
        self.actorID = actorID
        self.action = action
        self.workItemID = workItemID
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

public struct AirframeBackendReference: Codable, Equatable, Sendable {
    public let kind: String
    public let location: String

    public init(kind: String, location: String) {
        self.kind = kind
        self.location = location
    }
}
