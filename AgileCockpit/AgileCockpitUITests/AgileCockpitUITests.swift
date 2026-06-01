import XCTest

final class AgileCockpitUITests: XCTestCase {
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Agile Cockpit"].waitForExistence(timeout: 5))
    }
}
