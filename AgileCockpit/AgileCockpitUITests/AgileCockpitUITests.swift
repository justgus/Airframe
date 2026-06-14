import XCTest

final class AgileCockpitUITests: XCTestCase {
    func testAppLaunches() throws {
        let app = launchApp()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(element("agile-cockpit-title", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("agile-cockpit-backend-status", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("agile-cockpit-configuration-status", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("agile-cockpit-active-sprint", in: app).waitForExistence(timeout: 5))
    }

    func testAppRelaunchesForPrimaryWorkflowSmoke() throws {
        let app = launchApp()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(element("agile-cockpit-dashboard", in: app).waitForExistence(timeout: 5))
    }

    func testVerificationWorkflowControlsAreAccessible() throws {
        let app = launchApp()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

        selectNavigationItem("verification", in: app)

        XCTAssertTrue(element("agile-cockpit-verification", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Verification Queue"].firstMatch.waitForExistence(timeout: 5))
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

    private func labeledElement(_ label: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@", label))
            .firstMatch
    }

    private func selectNavigationItem(_ identifier: String, in app: XCUIApplication) {
        app.activate()
        let navItem = element("agile-cockpit-nav-\(identifier)", in: app)
        XCTAssertTrue(navItem.waitForExistence(timeout: 5))
        navItem.click()
    }
}
