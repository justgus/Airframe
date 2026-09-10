import Foundation

public enum AirframePlanMaterializationError: Error {
    case approvalRequired, emptyStructure, invalidStructure(String)
}

extension AirframeCanonicalStoreRepository {
    /// Materializes exactly the records reviewed with the plan. No caller-supplied
    /// overrides can alter the structure after the human decision.
    public func materializePlan(_ id: AirframeID) throws -> [AirframeID] {
        try store.transaction {
            guard let plan = try store.load(AirframeCanonicalImplementationPlanRecord.self, id: id) else {
                throw AirframeBackendError.missingWorkItem(id)
            }
            guard plan.decisionState == .approved else { throw AirframePlanMaterializationError.approvalRequired }
            guard let work = plan.proposedWork, !work.isEmpty else { throw AirframePlanMaterializationError.emptyStructure }
            let ids = work.map { $0.workItem.id }
            guard Set(ids).count == ids.count else { throw AirframePlanMaterializationError.invalidStructure("Duplicate IDs") }
            let order: [AirframeWorkItemKind: Int] = [.epic: 0, .sprint: 1, .task: 2, .issue: 3]
            for record in work {
                let item = record.workItem
                let prefix: [AirframeWorkItemKind: String] = [.epic: "EP-", .sprint: "SP-", .task: "T-", .issue: "I-"]
                guard item.id.rawValue.hasPrefix(prefix[item.kind]!), item.id.rawValue.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "-" }), !item.title.isEmpty,
                      item.githubIssue == nil else { throw AirframePlanMaterializationError.invalidStructure("Invalid work identity") }
                let statuses: [AirframeWorkItemKind: Set<AirframeWorkStatus>] = [.epic: [.proposed, .draft, .backlog], .sprint: [.backlog, .planning], .task: [.backlog, .active], .issue: [.backlog, .active]]
                guard statuses[item.kind]!.contains(item.status) else { throw AirframePlanMaterializationError.invalidStructure("Unsupported initial status") }
            }
            for record in work.sorted(by: { order[$0.workItem.kind]! < order[$1.workItem.kind]! }) {
                try createWorkRecord(record)
            }
            return ids
        }
    }
}
