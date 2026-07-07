import Foundation

public struct AirframePlanDecisionResult: Equatable, Sendable {
    public let plan: AirframeCanonicalImplementationPlanRecord
    public let decisionRecord: AirframeCanonicalPlanDecisionRecord
    public let auditEvent: AirframeAuditEvent

    public init(
        plan: AirframeCanonicalImplementationPlanRecord,
        decisionRecord: AirframeCanonicalPlanDecisionRecord,
        auditEvent: AirframeAuditEvent
    ) {
        self.plan = plan
        self.decisionRecord = decisionRecord
        self.auditEvent = auditEvent
    }
}

public struct AirframePlanReviewService: Sendable {
    private let authorityEvaluator: AirframeAuthorityEvaluator
    private let auditFactory: AirframeAuditEventFactory

    public init(
        authorityEvaluator: AirframeAuthorityEvaluator = AirframeAuthorityEvaluator(),
        auditFactory: AirframeAuditEventFactory = AirframeAuditEventFactory()
    ) {
        self.authorityEvaluator = authorityEvaluator
        self.auditFactory = auditFactory
    }

    public func decide(
        planID: AirframeID,
        outcome: AirframeCanonicalPlanDecisionState,
        note: String? = nil,
        context: AirframeCertifiedContext?,
        targetProjectID: AirframeID,
        repository: AirframeCanonicalStoreRepository,
        decisionID: AirframeID? = nil,
        auditID: AirframeID? = nil,
        decidedAt: Date = Date()
    ) throws -> AirframePlanDecisionResult {
        guard outcome != .pending else {
            throw AirframeBackendError.invalidTransition(from: .draft, to: .draft)
        }
        guard let existingPlan = try repository.store.load(
            AirframeCanonicalImplementationPlanRecord.self,
            id: planID
        ) else {
            throw AirframeBackendError.missingWorkItem(planID)
        }

        let operation = AirframeOperation(
            id: operationID(for: outcome),
            category: .planDecision
        )
        let authorityDecision = authorityEvaluator.evaluate(
            context: context,
            operation: operation,
            targetProjectID: targetProjectID
        )
        guard authorityDecision.isAllowed else {
            if case .requiresConfirmation(let reason) = authorityDecision {
                throw AirframeBackendError.requiresConfirmation(reason)
            }
            throw AirframeBackendError.authorityDenied(authorityDecision.reason)
        }

        let eventID = auditID ?? AirframeID("AUD-PLAN-\(planID.rawValue)-\(outcome.rawValue.uppercased())")
        let auditEvent = auditFactory.makeEvent(
            id: eventID,
            context: context,
            action: operation.id.rawValue,
            workItemID: planID,
            decision: authorityDecision,
            targetProjectID: targetProjectID,
            timestamp: decidedAt
        )
        let decisionRecord = AirframeCanonicalPlanDecisionRecord(
            id: decisionID ?? AirframeID("PD-\(planID.rawValue)-\(outcome.rawValue.uppercased())"),
            planID: planID,
            outcome: outcome,
            decidedByActorID: context?.actor.id ?? AirframeID("ACTOR-UNCERTIFIED"),
            decidedAt: decidedAt,
            auditEventID: auditEvent.id,
            note: note
        )
        let updatedPlan = AirframeCanonicalImplementationPlanRecord(
            id: existingPlan.id,
            title: existingPlan.title,
            summary: existingPlan.summary,
            proposedByActorID: existingPlan.proposedByActorID,
            targetEpicID: existingPlan.targetEpicID,
            targetSprintID: existingPlan.targetSprintID,
            targetTaskIDs: existingPlan.targetTaskIDs,
            decisionState: outcome,
            scope: existingPlan.scope,
            fileChanges: existingPlan.fileChanges,
            commands: existingPlan.commands,
            externalEffects: existingPlan.externalEffects,
            verificationCriteria: existingPlan.verificationCriteria,
            auditEventIDs: mergedIDs(existingPlan.auditEventIDs, [auditEvent.id]),
            evidenceIDs: existingPlan.evidenceIDs,
            notes: note.map { existingPlan.notes + [$0] } ?? existingPlan.notes,
            metadata: existingPlan.metadata
        )

        try repository.store.save(updatedPlan)
        try repository.store.save(decisionRecord)
        try repository.store.save(
            AirframeCanonicalAuditEventRecord(
                event: auditEvent,
                beforeRecordID: existingPlan.id,
                afterRecordID: updatedPlan.id
            )
        )

        return AirframePlanDecisionResult(
            plan: updatedPlan,
            decisionRecord: decisionRecord,
            auditEvent: auditEvent
        )
    }

    private func operationID(for outcome: AirframeCanonicalPlanDecisionState) -> AirframeID {
        switch outcome {
        case .pending:
            AirframeID("OP-HUMAN-PLAN-PENDING")
        case .approved:
            AirframeID("OP-HUMAN-APPROVE-PLAN")
        case .deferred:
            AirframeID("OP-HUMAN-DEFER-PLAN")
        case .rejected:
            AirframeID("OP-HUMAN-REJECT-PLAN")
        }
    }

    private func mergedIDs(_ existing: [AirframeID], _ additions: [AirframeID]) -> [AirframeID] {
        (existing + additions).reduce(into: [AirframeID]()) { result, id in
            if !result.contains(id) {
                result.append(id)
            }
        }
    }
}
