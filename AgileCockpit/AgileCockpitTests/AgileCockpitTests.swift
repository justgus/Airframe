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
    #expect(model.context.project.activeSprintID == AirframeID("SP-002"))
}
