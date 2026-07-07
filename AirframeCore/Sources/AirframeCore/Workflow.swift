import Foundation

public struct AirframeWorkflowTransition: Codable, Equatable, Sendable {
    public let workItemID: AirframeID
    public let kind: AirframeWorkItemKind
    public let fromStatus: AirframeWorkStatus
    public let toStatus: AirframeWorkStatus
    public let operation: AirframeOperation

    public init(
        workItemID: AirframeID,
        kind: AirframeWorkItemKind,
        fromStatus: AirframeWorkStatus,
        toStatus: AirframeWorkStatus,
        operation: AirframeOperation
    ) {
        self.workItemID = workItemID
        self.kind = kind
        self.fromStatus = fromStatus
        self.toStatus = toStatus
        self.operation = operation
    }
}

public enum AirframeWorkflowReasonCode: String, Codable, Equatable, Sendable {
    case allowed
    case invalidTransition
    case authorityDenied
    case requiresConfirmation
}

public enum AirframeWorkflowDecision: Codable, Equatable, Sendable {
    case allowed
    case requiresConfirmation(authorityReason: AirframeAuthorityReasonCode)
    case denied(reason: AirframeWorkflowReasonCode, authorityReason: AirframeAuthorityReasonCode?)

    public var isAllowed: Bool {
        if case .allowed = self {
            return true
        }
        return false
    }
}

public struct AirframeWorkflowTransitionEvaluator: Sendable {
    private let authorityEvaluator: AirframeAuthorityEvaluator

    public init(authorityEvaluator: AirframeAuthorityEvaluator = AirframeAuthorityEvaluator()) {
        self.authorityEvaluator = authorityEvaluator
    }

    public func evaluate(
        context: AirframeCertifiedContext?,
        transition: AirframeWorkflowTransition,
        targetProjectID: AirframeID
    ) -> AirframeWorkflowDecision {
        guard isValidTransition(
            kind: transition.kind,
            from: transition.fromStatus,
            to: transition.toStatus
        ) else {
            return .denied(reason: .invalidTransition, authorityReason: nil)
        }

        let authorityDecision = authorityEvaluator.evaluate(
            context: context,
            operation: transition.operation,
            targetProjectID: targetProjectID
        )

        switch authorityDecision {
        case .allowed:
            return .allowed
        case .requiresConfirmation(let reason):
            return .requiresConfirmation(authorityReason: reason)
        case .denied(let reason):
            return .denied(reason: .authorityDenied, authorityReason: reason)
        }
    }

    private func isValidTransition(
        kind: AirframeWorkItemKind,
        from: AirframeWorkStatus,
        to: AirframeWorkStatus
    ) -> Bool {
        switch kind {
        case .task:
            switch (from, to) {
            case (.backlog, .active),
                 (.active, .implementedNotVerified),
                 (.implementedNotVerified, .implementedVerified),
                 (.implementedVerified, .closed),
                 (.active, .backlog):
                true
            default:
                false
            }
        case .issue:
            switch (from, to) {
            case (.backlog, .active),
                 (.active, .implementedNotVerified),
                 (.implementedNotVerified, .implementedVerified),
                 (.implementedVerified, .closed),
                 (.active, .backlog),
                 (.implementedNotVerified, .active),
                 (.implementedNotVerified, .backlog):
                true
            default:
                false
            }
        case .sprint:
            switch (from, to) {
            case (.backlog, .planning),
                 (.planning, .active),
                 (.active, .review),
                 (.active, .backlog),
                 (.review, .closed),
                 (.review, .backlog):
                true
            default:
                false
            }
        case .epic:
            switch (from, to) {
            case (.proposed, .draft),
                 (.draft, .backlog),
                 (.backlog, .active),
                 (.active, .complete),
                 (.complete, .closed),
                 (.active, .backlog),
                 (.complete, .backlog):
                true
            default:
                false
            }
        }
    }
}
