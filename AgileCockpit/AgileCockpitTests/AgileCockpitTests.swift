import Testing
import AirframeCore
@testable import AgileCockpit

@Test func agileCockpitLinksAirframeCore() {
    #expect(AirframeCoreInfo.current.summary == "AirframeCore 0.1.0")
}

@Test func agileCockpitSampleContextIsAvailable() throws {
    let model = try AgileCockpitContextModel.sample()

    #expect(model.context.workspaceName == "Airframe")
    #expect(model.context.projectName == "Agile Airframe")
    #expect(model.context.project.activeSprintID == AirframeID("SP-005"))
}

@Test func agileCockpitShowsAuthorityAndAuditData() throws {
    let model = try AgileCockpitContextModel.sample()

    #expect(model.actionSummaries.count == 2)
    #expect(model.actionSummaries[0].statusText == "Allowed")
    #expect(model.actionSummaries[1].statusText == "Denied")
    #expect(model.actionSummaries[1].decision.reason == .authorityClassNotPermitted)
    #expect(model.auditEvents.count == 1)
    #expect(model.auditEvents[0].reason == .authorityClassNotPermitted)
}
