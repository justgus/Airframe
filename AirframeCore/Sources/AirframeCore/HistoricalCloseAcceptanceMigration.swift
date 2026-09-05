import Foundation

public struct AirframeHistoricalCloseAcceptanceMigrationPreview: Equatable, Sendable {
    public let eligibleEpicIDs: [AirframeID]
    public let eligibleCriterionIDs: [AirframeID]

    public var criterionCount: Int { eligibleCriterionIDs.count }
}

public enum AirframeHistoricalCloseAcceptanceMigrationError: Error, Equatable, Sendable {
    case ineligibleEpicIDs([AirframeID])
}

public struct AirframeHistoricalCloseAcceptanceMigration: Sendable {
    public static let approvedHistoricalEpicIDs = Set(
        (1...8).map { AirframeID(String(format: "EP-%03d", $0)) }
    )

    public init() {}

    public func preview(
        epics: [AirframeCanonicalEpicRecord],
        criteria: [AirframeCanonicalAcceptanceCriterionRecord]
    ) -> AirframeHistoricalCloseAcceptanceMigrationPreview {
        let eligibleEpicIDs = Set(epics.compactMap { epic in
            let id = epic.workItem.id
            return epic.workItem.status == .closed && Self.approvedHistoricalEpicIDs.contains(id) ? id : nil
        })
        let criterionIDs = criteria.compactMap { criterion in
            eligibleEpicIDs.contains(criterion.ownerID) && criterion.disposition == .unverified
                ? criterion.id
                : nil
        }
        return AirframeHistoricalCloseAcceptanceMigrationPreview(
            eligibleEpicIDs: eligibleEpicIDs.sorted { $0.rawValue < $1.rawValue },
            eligibleCriterionIDs: criterionIDs.sorted { $0.rawValue < $1.rawValue }
        )
    }

    public func migrate(
        epics: [AirframeCanonicalEpicRecord],
        criteria: [AirframeCanonicalAcceptanceCriterionRecord],
        explicitlyApprovedEpicIDs: Set<AirframeID>
    ) throws -> [AirframeCanonicalAcceptanceCriterionRecord] {
        let preview = preview(epics: epics, criteria: criteria)
        let eligibleIDs = Set(preview.eligibleEpicIDs)
        let ineligibleIDs = explicitlyApprovedEpicIDs.subtracting(eligibleIDs)
        guard ineligibleIDs.isEmpty else {
            throw AirframeHistoricalCloseAcceptanceMigrationError.ineligibleEpicIDs(
                ineligibleIDs.sorted { $0.rawValue < $1.rawValue }
            )
        }
        return criteria.map { criterion in
            guard explicitlyApprovedEpicIDs.contains(criterion.ownerID),
                  criterion.disposition == .unverified else {
                return criterion
            }
            return AirframeCanonicalAcceptanceCriterionRecord(
                id: criterion.id,
                ownerID: criterion.ownerID,
                text: criterion.text,
                disposition: .grandfatheredHistoricalClose,
                evidenceIDs: criterion.evidenceIDs,
                metadata: criterion.metadata
            )
        }
    }
}
