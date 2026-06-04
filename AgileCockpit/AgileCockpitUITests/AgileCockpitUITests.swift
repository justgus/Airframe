import XCTest

final class AgileCockpitUITests: XCTestCase {
    func testAppLaunches() throws {
        let app = launchApp()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(element("agile-cockpit-title", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("agile-cockpit-backend-status", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("agile-cockpit-configuration-status", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Sprint None"].firstMatch.waitForExistence(timeout: 5))
    }

    func testAppRelaunchesForPrimaryWorkflowSmoke() throws {
        let app = launchApp()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(element("agile-cockpit-dashboard", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Active"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Ready"].firstMatch.waitForExistence(timeout: 5))
    }

    func testVerificationWorkflowControlsAreAccessible() throws {
        let app = launchApp()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

        selectNavigationItem("Verification", in: app)

        XCTAssertTrue(element("agile-cockpit-verification", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Verification Queue"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Harden CLI output and error contracts"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Accept"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Reject"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Request More Evidence"].firstMatch.waitForExistence(timeout: 5))
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        app.activate()
        return app
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier].firstMatch
    }

    private func selectNavigationItem(_ title: String, in app: XCUIApplication) {
        let button = app.buttons[title].firstMatch
        if button.waitForExistence(timeout: 2) {
            button.click()
            return
        }

        let text = app.staticTexts[title].firstMatch
        if text.waitForExistence(timeout: 2) {
            text.click()
        }
    }
}
