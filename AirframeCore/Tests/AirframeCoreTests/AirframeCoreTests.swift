import Testing
import AirframeCore

@Test func coreInfoProvidesBaselineIdentity() {
    let info = AirframeCoreInfo.current

    #expect(info.name == "AirframeCore")
    #expect(info.version == "0.1.0")
    #expect(info.summary == "AirframeCore 0.1.0")
}
