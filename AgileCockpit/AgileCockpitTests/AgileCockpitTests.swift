import Testing
import AirframeCore
@testable import AgileCockpit

@Test func agileCockpitLinksAirframeCore() {
    #expect(AirframeCoreInfo.current.summary == "AirframeCore 0.1.0")
}

@MainActor
@Test func agileCockpitSampleDashboardContextIsAvailable() throws {
    let model = try AgileCockpitDashboardModel.sample()

    #expect(model.context.workspaceName == "Airframe")
    #expect(model.context.projectName == "Agile Airframe")
    #expect(model.context.project.activeSprintID == nil)
    #expect(model.context.project.activeEpicID == nil)
    #expect(model.projectStatusText.contains("justgus/Airframe"))
    #expect(model.backendStatusText.contains("github-fixture"))
    #expect(model.backendStatusText.contains("GitHub issue mapping on"))
    #expect(model.configurationDiagnostics.status == .ok)
    #expect(model.configurationStatusText == "Configuration ok | 1 project(s)")
}

@MainActor
@Test func agileCockpitBuildsDashboardSectionsFromCoreBackend() throws {
    let model = try AgileCockpitDashboardModel.sample()

    #expect(model.summary.activeTaskCount == 1)
    #expect(model.summary.unverifiedTaskCount == 1)
    #expect(model.summary.verifiedTaskCount == 1)
    #expect(model.summary.nextTask?.id == AirframeID("T-0041"))
    #expect(model.readyRecords.map(\.workItem.id).contains(AirframeID("T-0042")))
    #expect(model.upcomingRecords.map(\.workItem.id).contains(AirframeID("T-0045")))
    #expect(model.statusMessage == "Loaded github-fixture Airframe workspace.")
}

@MainActor
@Test func agileCockpitExposesVerificationPacketEvidenceAndActions() throws {
    let model = try AgileCockpitDashboardModel.sample()

    model.selectedWorkItemID = AirframeID("T-0042")

    #expect(model.selectedPacket?.workItem.id == AirframeID("T-0042"))
    #expect(model.selectedPacket?.existingEvidence.first?.id == AirframeID("EV-0042-001"))

    model.requestMoreEvidenceForSelectedWork()

    #expect(model.summary.unverifiedTaskCount == 0)
    #expect(model.activeRecords.map(\.workItem.id).contains(AirframeID("T-0042")))
    #expect(model.auditRows.last?.action == "OP-HUMAN-REQUEST-EVIDENCE")
}

@MainActor
@Test func agileCockpitAcceptsReadyWorkThroughCoreBackend() throws {
    let model = try AgileCockpitDashboardModel.sample()

    model.selectedWorkItemID = AirframeID("T-0042")
    model.acceptSelectedWork()

    #expect(model.verifiedRecords.map(\.workItem.id).contains(AirframeID("T-0042")))
    #expect(model.summary.verifiedTaskCount == 2)
    #expect(model.statusMessage.contains("T-0042 accepted"))
}

@MainActor
@Test func agileCockpitShowsSprintEpicMetricsAndAuditRows() throws {
    let model = try AgileCockpitDashboardModel.sample()

    #expect(model.sprintRecords.count == 0)
    #expect(model.epicRecords.count == 0)
    #expect(model.metrics.map(\.id) == ["active", "ready", "verified", "issues", "evidence"])
    #expect(model.auditRows.first?.action == "OP-READ-DASHBOARD")
}
