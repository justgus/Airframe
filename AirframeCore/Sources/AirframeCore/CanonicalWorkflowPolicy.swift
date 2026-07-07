import Foundation

public struct AirframeCanonicalWorkflowPolicyCatalog: Codable, Equatable, Sendable {
    public let definitions: [AirframeCanonicalWorkflowDefinitionRecord]
    public let transitions: [AirframeCanonicalWorkflowTransitionRecord]

    public init(
        definitions: [AirframeCanonicalWorkflowDefinitionRecord],
        transitions: [AirframeCanonicalWorkflowTransitionRecord]
    ) {
        self.definitions = definitions
        self.transitions = transitions
    }

    public func definition(for kind: AirframeWorkItemKind) -> AirframeCanonicalWorkflowDefinitionRecord? {
        definitions.first { $0.workItemKind == kind }
    }

    public func transitions(for kind: AirframeWorkItemKind) -> [AirframeCanonicalWorkflowTransitionRecord] {
        transitions
            .filter { $0.workItemKind == kind }
            .sorted { $0.id.rawValue < $1.id.rawValue }
    }

    public func transition(
        for kind: AirframeWorkItemKind,
        from fromStatus: AirframeWorkStatus,
        to toStatus: AirframeWorkStatus
    ) -> AirframeCanonicalWorkflowTransitionRecord? {
        transitions.first {
            $0.workItemKind == kind &&
            $0.fromStatus == fromStatus &&
            $0.toStatus == toStatus
        }
    }

    public static let airframeDefault = AirframeCanonicalWorkflowPolicyCatalog.makeAirframeDefault()

    private static func makeAirframeDefault() -> AirframeCanonicalWorkflowPolicyCatalog {
        let transitions = [
            taskTransition(.backlog, .active, "OP-ACTIVATE-TASK"),
            taskTransition(.active, .implementedNotVerified, "OP-READY-FOR-VERIFICATION"),
            humanVerificationTransition(kind: .task),
            taskTransition(.implementedVerified, .closed, "OP-CLOSE-TASK"),
            taskTransition(.active, .backlog, "OP-RETURN-TASK-TO-BACKLOG"),

            issueTransition(.backlog, .active, "OP-ACTIVATE-ISSUE"),
            issueTransition(.active, .implementedNotVerified, "OP-RESOLVE-ISSUE"),
            humanVerificationTransition(kind: .issue),
            issueTransition(.implementedVerified, .closed, "OP-CLOSE-ISSUE"),
            issueTransition(.active, .backlog, "OP-RETURN-ISSUE-TO-BACKLOG"),

            sprintTransition(.backlog, .planning, "OP-PLAN-SPRINT"),
            sprintTransition(.planning, .active, "OP-ACTIVATE-SPRINT"),
            sprintTransition(.active, .review, "OP-REVIEW-SPRINT"),
            sprintCloseTransition(),
            sprintReturnToBacklogTransition(from: .active),
            sprintReturnToBacklogTransition(from: .review),

            epicTransition(.proposed, .draft, "OP-DRAFT-EPIC"),
            epicTransition(.draft, .backlog, "OP-BACKLOG-EPIC"),
            epicTransition(.backlog, .active, "OP-ACTIVATE-EPIC"),
            epicTransition(.active, .complete, "OP-COMPLETE-EPIC"),
            epicCloseTransition(),
            epicTransition(.active, .backlog, "OP-RETURN-EPIC-TO-BACKLOG"),
            epicTransition(.complete, .backlog, "OP-RETURN-COMPLETE-EPIC-TO-BACKLOG")
        ]

        return AirframeCanonicalWorkflowPolicyCatalog(
            definitions: [
                definition(
                    id: "WF-TASK",
                    kind: .task,
                    statuses: [.backlog, .active, .implementedNotVerified, .implementedVerified, .closed],
                    transitions: transitions
                ),
                definition(
                    id: "WF-ISSUE",
                    kind: .issue,
                    statuses: [.backlog, .active, .implementedNotVerified, .implementedVerified, .closed],
                    transitions: transitions
                ),
                definition(
                    id: "WF-SPRINT",
                    kind: .sprint,
                    statuses: [.backlog, .planning, .active, .review, .closed],
                    transitions: transitions
                ),
                definition(
                    id: "WF-EPIC",
                    kind: .epic,
                    statuses: [.proposed, .draft, .backlog, .active, .complete, .closed],
                    transitions: transitions
                )
            ],
            transitions: transitions
        )
    }

    private static func definition(
        id: String,
        kind: AirframeWorkItemKind,
        statuses: [AirframeWorkStatus],
        transitions: [AirframeCanonicalWorkflowTransitionRecord]
    ) -> AirframeCanonicalWorkflowDefinitionRecord {
        AirframeCanonicalWorkflowDefinitionRecord(
            id: AirframeID(id),
            workItemKind: kind,
            allowedStatuses: statuses,
            transitionIDs: transitions
                .filter { $0.workItemKind == kind }
                .map(\.id)
                .sorted { $0.rawValue < $1.rawValue }
        )
    }

    private static func taskTransition(
        _ fromStatus: AirframeWorkStatus,
        _ toStatus: AirframeWorkStatus,
        _ operationID: String
    ) -> AirframeCanonicalWorkflowTransitionRecord {
        transition(
            id: "WF-TASK-\(fromStatus.rawValue)-\(toStatus.rawValue)",
            kind: .task,
            from: fromStatus,
            to: toStatus,
            operationID: operationID,
            category: .workflowTransition,
            authorities: [.humanOwner, .humanMaintainer, .llmAgent, .automation]
        )
    }

    private static func issueTransition(
        _ fromStatus: AirframeWorkStatus,
        _ toStatus: AirframeWorkStatus,
        _ operationID: String
    ) -> AirframeCanonicalWorkflowTransitionRecord {
        transition(
            id: "WF-ISSUE-\(fromStatus.rawValue)-\(toStatus.rawValue)",
            kind: .issue,
            from: fromStatus,
            to: toStatus,
            operationID: operationID,
            category: .workflowTransition,
            authorities: [.humanOwner, .humanMaintainer, .llmAgent, .automation]
        )
    }

    private static func sprintTransition(
        _ fromStatus: AirframeWorkStatus,
        _ toStatus: AirframeWorkStatus,
        _ operationID: String
    ) -> AirframeCanonicalWorkflowTransitionRecord {
        transition(
            id: "WF-SPRINT-\(fromStatus.rawValue)-\(toStatus.rawValue)",
            kind: .sprint,
            from: fromStatus,
            to: toStatus,
            operationID: operationID,
            category: .workflowTransition,
            authorities: [.humanOwner, .humanMaintainer, .llmAgent, .automation]
        )
    }

    private static func epicTransition(
        _ fromStatus: AirframeWorkStatus,
        _ toStatus: AirframeWorkStatus,
        _ operationID: String
    ) -> AirframeCanonicalWorkflowTransitionRecord {
        transition(
            id: "WF-EPIC-\(fromStatus.rawValue)-\(toStatus.rawValue)",
            kind: .epic,
            from: fromStatus,
            to: toStatus,
            operationID: operationID,
            category: .workflowTransition,
            authorities: [.humanOwner, .humanMaintainer, .llmAgent, .automation]
        )
    }

    private static func humanVerificationTransition(
        kind: AirframeWorkItemKind
    ) -> AirframeCanonicalWorkflowTransitionRecord {
        transition(
            id: "WF-\(kind.rawValue.uppercased())-implementedNotVerified-implementedVerified",
            kind: kind,
            from: .implementedNotVerified,
            to: .implementedVerified,
            operationID: "OP-HUMAN-VERIFY-\(kind.rawValue.uppercased())",
            category: .humanAcceptance,
            authorities: [.humanOwner, .humanReviewer],
            preconditions: ["Work item is ready for human verification."],
            sideEffects: ["Record human verification evidence."]
        )
    }

    private static func sprintCloseTransition() -> AirframeCanonicalWorkflowTransitionRecord {
        transition(
            id: "WF-SPRINT-review-closed",
            kind: .sprint,
            from: .review,
            to: .closed,
            operationID: "OP-CLOSE-SPRINT",
            category: .sprintControl,
            authorities: [.humanOwner, .humanMaintainer],
            preconditions: ["All assigned Tasks and Issues are verified or explicitly carried forward."],
            sideEffects: ["Archive Sprint record.", "Update Sprint indexes."]
        )
    }

    private static func sprintReturnToBacklogTransition(
        from fromStatus: AirframeWorkStatus
    ) -> AirframeCanonicalWorkflowTransitionRecord {
        transition(
            id: "WF-SPRINT-\(fromStatus.rawValue)-backlog",
            kind: .sprint,
            from: fromStatus,
            to: .backlog,
            operationID: "OP-RETURN-SPRINT-TO-BACKLOG",
            category: .sprintControl,
            authorities: [.humanOwner, .humanMaintainer],
            preconditions: ["Planning priorities changed and a human approved returning the Sprint to Backlog."],
            sideEffects: ["Clear active Sprint pointer when the returned Sprint is current.", "Update Sprint indexes."]
        )
    }

    private static func epicCloseTransition() -> AirframeCanonicalWorkflowTransitionRecord {
        transition(
            id: "WF-EPIC-complete-closed",
            kind: .epic,
            from: .complete,
            to: .closed,
            operationID: "OP-CLOSE-EPIC",
            category: .epicControl,
            authorities: [.humanOwner, .humanMaintainer],
            preconditions: ["All Epic acceptance criteria are verified."],
            sideEffects: ["Archive Epic record.", "Update Epic indexes."]
        )
    }

    private static func transition(
        id: String,
        kind: AirframeWorkItemKind,
        from fromStatus: AirframeWorkStatus,
        to toStatus: AirframeWorkStatus,
        operationID: String,
        category: AirframeOperationCategory,
        authorities: [AirframeAuthorityClass],
        preconditions: [String] = [],
        sideEffects: [String] = []
    ) -> AirframeCanonicalWorkflowTransitionRecord {
        AirframeCanonicalWorkflowTransitionRecord(
            id: AirframeID(id),
            workItemKind: kind,
            fromStatus: fromStatus,
            toStatus: toStatus,
            operation: AirframeOperation(
                id: AirframeID(operationID),
                category: category,
                requiresConfirmation: category == .sprintControl || category == .epicControl
            ),
            requiredAuthorityClasses: authorities,
            preconditions: preconditions,
            sideEffects: sideEffects
        )
    }
}
