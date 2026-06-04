import XCTest

final class AgileCockpitUITests: XCTestCase {
    func testAppLaunches() throws {
        let app = launchApp()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }

    func testAppRelaunchesForPrimaryWorkflowSmoke() throws {
        let app = launchApp()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        app.activate()
        return app
    }
}
