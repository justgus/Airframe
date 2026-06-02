import AirframeCore
import SwiftUI

struct AgileCockpitContextModel {
    let coreInfo: AirframeCoreInfo
    let context: AirframeProjectContext
    let actionSummaries: [AgileCockpitActionSummary]
    let auditEvents: [AirframeAuditEvent]

    init(
        coreInfo: AirframeCoreInfo = .current,
        context: AirframeProjectContext,
        actionSummaries: [AgileCockpitActionSummary] = [],
        auditEvents: [AirframeAuditEvent] = []
    ) {
        self.coreInfo = coreInfo
        self.context = context
        self.actionSummaries = actionSummaries
        self.auditEvents = auditEvents
    }

    static func sample() throws -> AgileCockpitContextModel {
        let context = try AirframeConfigurationLoader().loadSampleContext()
        let certifiedContext = try AirframeCertifiedContext.agentDemoContext(projectID: context.project.id)
        let humanOnlyOperation = AirframeOperation(
            id: AirframeID("OP-ACCEPT-WORK"),
            category: .humanAcceptance
        )
        let evidenceOperation = AirframeOperation(
            id: AirframeID("OP-ATTACH-EVIDENCE"),
            category: .evidence
        )
        let evaluator = AirframeAuthorityEvaluator()
        let humanOnlyDecision = evaluator.evaluate(
            context: certifiedContext,
            operation: humanOnlyOperation,
            targetProjectID: context.project.id
        )
        let evidenceDecision = evaluator.evaluate(
            context: certifiedContext,
            operation: evidenceOperation,
            targetProjectID: context.project.id
        )
        var auditStore = AirframeAuditEventStore()
        auditStore.record(
            id: AirframeID("AUD-DEMO-0001"),
            context: certifiedContext,
            action: humanOnlyOperation.id.rawValue,
            workItemID: AirframeID("T-0013"),
            decision: humanOnlyDecision,
            targetProjectID: context.project.id,
            timestamp: Date(timeIntervalSince1970: 0)
        )

        return AgileCockpitContextModel(
            context: context,
            actionSummaries: [
                AgileCockpitActionSummary(
                    title: "Attach Evidence",
                    decision: evidenceDecision
                ),
                AgileCockpitActionSummary(
                    title: "Accept Work",
                    decision: humanOnlyDecision
                )
            ],
            auditEvents: auditStore.events
        )
    }
}

struct AgileCockpitActionSummary: Equatable {
    let title: String
    let decision: AirframeAuthorityDecision

    var statusText: String {
        switch decision {
        case .allowed:
            "Allowed"
        case .requiresConfirmation:
            "Needs Confirmation"
        case .denied:
            "Denied"
        }
    }
}

private extension AirframeCertifiedContext {
    static func agentDemoContext(projectID: AirframeID) throws -> AirframeCertifiedContext {
        let actor = AirframeActor(
            id: AirframeID("ACTOR-LLM"),
            displayName: "AICockpit Agent",
            authorityClass: .llmAgent,
            credentialSource: .configuredIdentity
        )
        let credential = AirframeCredentialContext(
            credentialID: AirframeID("CRED-AGILECOCKPIT-DEMO"),
            actorID: actor.id,
            credentialSource: .configuredIdentity,
            executionProjectID: projectID,
            allowedProjectIDs: [projectID]
        )

        return try AirframeCertifiedContext(
            actor: actor,
            credential: credential,
            targetProjectID: projectID
        )
    }
}

struct ContentView: View {
    let model: AgileCockpitContextModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Agile Cockpit")
                .font(.title)
                .accessibilityIdentifier("agile-cockpit-title")
            Text(model.context.workspaceName)
                .font(.headline)
                .accessibilityIdentifier("agile-cockpit-workspace")
            Text(model.context.projectName)
                .font(.subheadline)
                .accessibilityIdentifier("agile-cockpit-project")
            Text("Active Sprint: \(model.context.project.activeSprintID?.rawValue ?? "None")")
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("agile-cockpit-active-sprint")
            Text(model.coreInfo.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("agile-cockpit-core-summary")
            Divider()
            Text("Authority")
                .font(.headline)
            ForEach(model.actionSummaries, id: \.title) { action in
                HStack {
                    Text(action.title)
                    Spacer()
                    Text(action.statusText)
                        .foregroundStyle(action.decision.isAllowed ? .green : .red)
                    Text(action.decision.reason.rawValue)
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("agile-cockpit-action-\(action.title)")
            }
            Divider()
            Text("Audit")
                .font(.headline)
            ForEach(model.auditEvents, id: \.id.rawValue) { event in
                Text("\(event.id.rawValue) \(event.action) \(event.reason?.rawValue ?? "unknown")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("agile-cockpit-audit-\(event.id.rawValue)")
            }
        }
        .padding(24)
        .frame(minWidth: 520, minHeight: 360)
    }
}

#Preview {
    ContentView(
        model: try! AgileCockpitContextModel.sample()
    )
}
