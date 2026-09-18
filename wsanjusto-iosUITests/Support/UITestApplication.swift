import XCTest

enum UITestScenario: String {
    case success
    case empty
    case error
}

@MainActor
func launchApplication(scenario: UITestScenario = .success) -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments += [
        "-UITesting",
        "-UITestingSkipSplash",
        "-UITestingScenario",
        scenario.rawValue
    ]
    app.launch()
    return app
}

@MainActor
func attachFailureScreenshot(
    from app: XCUIApplication,
    to testCase: XCTestCase
) {
    guard testCase.testRun?.hasSucceeded == false else { return }

    let screenshot = XCTAttachment(screenshot: app.screenshot())
    screenshot.name = "Failure screenshot"
    screenshot.lifetime = .keepAlways
    testCase.add(screenshot)
}
