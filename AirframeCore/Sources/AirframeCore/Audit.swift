import Foundation

public struct AirframeAuditEventFactory: Sendable {
    public init() {}

    public func makeEvent(
        id: AirframeID,
        context: AirframeCertifiedContext?,
        action: String,
        workItemID: AirframeID?,
        decision: AirframeAuthorityDecision,
        targetProjectID: AirframeID,
        timestamp: Date = Date()
    ) -> AirframeAuditEvent {
        AirframeAuditEvent(
            id: id,
            actorID: context?.actor.id ?? AirframeID("ACTOR-UNCERTIFIED"),
            action: action,
            workItemID: workItemID,
            decision: decision,
            targetProjectID: targetProjectID,
            timestamp: timestamp
        )
    }
}

public struct AirframeAuditEventStore: Sendable {
    public private(set) var events: [AirframeAuditEvent]
    private let factory: AirframeAuditEventFactory

    public init(
        events: [AirframeAuditEvent] = [],
        factory: AirframeAuditEventFactory = AirframeAuditEventFactory()
    ) {
        self.events = events
        self.factory = factory
    }

    @discardableResult
    public mutating func record(
        id: AirframeID,
        context: AirframeCertifiedContext?,
        action: String,
        workItemID: AirframeID?,
        decision: AirframeAuthorityDecision,
        targetProjectID: AirframeID,
        timestamp: Date = Date()
    ) -> AirframeAuditEvent {
        let event = factory.makeEvent(
            id: id,
            context: context,
            action: action,
            workItemID: workItemID,
            decision: decision,
            targetProjectID: targetProjectID,
            timestamp: timestamp
        )
        events.append(event)
        return event
    }
}
