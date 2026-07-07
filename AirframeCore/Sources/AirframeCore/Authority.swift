import Foundation

public enum AirframeOperationCategory: String, Codable, Equatable, Sendable {
    case read
    case proposal
    case evidence
    case workflowTransition
    case humanAcceptance
    case planDecision
    case sprintControl
    case epicControl
    case policyConfiguration
    case destructive
}

public struct AirframeOperation: Codable, Equatable, Sendable {
    public let id: AirframeID
    public let category: AirframeOperationCategory
    public let requiresConfirmation: Bool

    public init(
        id: AirframeID,
        category: AirframeOperationCategory,
        requiresConfirmation: Bool = false
    ) {
        self.id = id
        self.category = category
        self.requiresConfirmation = requiresConfirmation
    }
}

public enum AirframeAuthorityReasonCode: String, Codable, Equatable, Sendable {
    case allowed
    case requiresConfirmation
    case uncertifiedContext
    case projectScopeMismatch
    case authorityClassNotPermitted
    case destructiveOperationDenied
}

public enum AirframeAuthorityDecision: Codable, Equatable, Sendable {
    case allowed(reason: AirframeAuthorityReasonCode = .allowed)
    case requiresConfirmation(reason: AirframeAuthorityReasonCode = .requiresConfirmation)
    case denied(reason: AirframeAuthorityReasonCode)

    public var isAllowed: Bool {
        if case .allowed = self {
            return true
        }
        return false
    }

    public var reason: AirframeAuthorityReasonCode {
        switch self {
        case .allowed(let reason), .requiresConfirmation(let reason), .denied(let reason):
            reason
        }
    }
}

public struct AirframeAuthorityEvaluator: Sendable {
    public init() {}

    public func evaluate(
        context: AirframeCertifiedContext?,
        operation: AirframeOperation,
        targetProjectID: AirframeID
    ) -> AirframeAuthorityDecision {
        guard let context else {
            return .denied(reason: .uncertifiedContext)
        }

        guard context.targetProjectID == targetProjectID else {
            return .denied(reason: .projectScopeMismatch)
        }

        guard isPermitted(context.actor.authorityClass, for: operation.category) else {
            if operation.category == .destructive {
                return .denied(reason: .destructiveOperationDenied)
            }
            return .denied(reason: .authorityClassNotPermitted)
        }

        if operation.requiresConfirmation {
            return .requiresConfirmation()
        }

        return .allowed()
    }

    private func isPermitted(
        _ authorityClass: AirframeAuthorityClass,
        for category: AirframeOperationCategory
    ) -> Bool {
        switch authorityClass {
        case .humanOwner:
            category != .destructive
        case .humanMaintainer:
            switch category {
            case .read, .proposal, .evidence, .workflowTransition, .sprintControl, .epicControl:
                true
            case .humanAcceptance, .planDecision, .policyConfiguration, .destructive:
                false
            }
        case .humanReviewer:
            switch category {
            case .read, .evidence, .humanAcceptance, .planDecision:
                true
            case .proposal, .workflowTransition, .sprintControl, .epicControl, .policyConfiguration, .destructive:
                false
            }
        case .llmAgent:
            switch category {
            case .read, .proposal, .evidence, .workflowTransition:
                true
            case .humanAcceptance, .planDecision, .sprintControl, .epicControl, .policyConfiguration, .destructive:
                false
            }
        case .automation:
            switch category {
            case .read, .proposal, .evidence, .workflowTransition:
                true
            case .humanAcceptance, .planDecision, .sprintControl, .epicControl, .policyConfiguration, .destructive:
                false
            }
        case .readOnlyObserver:
            category == .read
        case .unknown:
            false
        }
    }
}
