import XCTest

final class WSanJustoSmokeUITests: XCTestCase {
    @MainActor
    func testMainNavigationAndDashboard() {
        let app = launchApplication()
        defer { finishTesting(app) }
        let mainScreen = MainScreen(app: app)
        let dashboardScreen = DashboardScreen(app: app)

        XCTAssertTrue(mainScreen.waitUntilVisible())
        XCTAssertTrue(mainScreen.hasAllTabs())
        XCTAssertTrue(dashboardScreen.waitForTemperature())
        XCTAssertTrue(dashboardScreen.hasRefreshButton)
    }

    @MainActor
    func testDashboardShowsReservoirCapacityAfterScrolling() {
        let app = launchApplication()
        defer { finishTesting(app) }
        let dashboardScreen = DashboardScreen(app: app)

        XCTAssertTrue(dashboardScreen.revealReservoir())
        XCTAssertEqual(dashboardScreen.reservoirMaxCapacity, "18.7 hm³")
        XCTAssertEqual(dashboardScreen.reservoirPercentage, "50%")
        XCTAssertEqual(dashboardScreen.reservoirCurrentVolume, "9.3 hm³")
    }

    @MainActor
    func testDashboardShowsLastForecastAfterScrolling() {
        let app = launchApplication()
        defer { finishTesting(app) }
        let dashboardScreen = DashboardScreen(app: app)

        XCTAssertTrue(dashboardScreen.revealForecast())
        XCTAssertEqual(dashboardScreen.firstForecastTemperature, "1° | 11°")
        XCTAssertEqual(dashboardScreen.firstForecastPrecipitation, "0.50 mm")
        XCTAssertTrue(dashboardScreen.revealLastForecast())
        XCTAssertEqual(dashboardScreen.lastForecastTemperature, "5° | 15°")
        XCTAssertEqual(dashboardScreen.lastForecastPrecipitation, "4.50 mm")
    }

    @MainActor
    func testChartLoadsFixtureData() {
        let app = launchApplication()
        defer { finishTesting(app) }
        MainScreen(app: app).openChart()
        let chartScreen = ChartScreen(app: app)

        XCTAssertTrue(chartScreen.waitForLoadedContent())
        XCTAssertEqual(chartScreen.selectedTemperature, "- ºC")
        XCTAssertFalse(chartScreen.isLoading)
    }

    @MainActor
    func testHistoryLoadsFixtureData() {
        let app = launchApplication()
        defer { finishTesting(app) }
        MainScreen(app: app).openHistory()
        let historyScreen = HistoryScreen(app: app)

        XCTAssertTrue(historyScreen.waitForFirstRow())
        XCTAssertTrue(historyScreen.revealSecondPage())
    }

    @MainActor
    func testAboutShowsApplicationVersion() {
        let app = launchApplication()
        defer { finishTesting(app) }
        MainScreen(app: app).openAbout()
        let aboutScreen = AboutScreen(app: app)

        XCTAssertTrue(aboutScreen.waitForVersion())
        XCTAssertTrue(aboutScreen.version.hasPrefix("Versión "))
    }

    @MainActor
    private func finishTesting(_ app: XCUIApplication) {
        attachFailureScreenshot(from: app, to: self)
        app.terminate()
    }
}

final class WSanJustoStateUITests: XCTestCase {
    @MainActor
    func testChartEmptyState() {
        let app = launchApplication(scenario: .empty)
        defer { finishTesting(app) }

        MainScreen(app: app).openChart()

        XCTAssertTrue(ChartScreen(app: app).waitForEmptyState())
    }

    @MainActor
    func testChartErrorState() {
        let app = launchApplication(scenario: .error)
        defer { finishTesting(app) }

        MainScreen(app: app).openChart()

        XCTAssertTrue(ChartScreen(app: app).waitForErrorState())
    }

    @MainActor
    func testHistoryEmptyState() {
        let app = launchApplication(scenario: .empty)
        defer { finishTesting(app) }

        MainScreen(app: app).openHistory()

        XCTAssertTrue(HistoryScreen(app: app).waitForEmptyState())
    }

    @MainActor
    func testHistoryErrorState() {
        let app = launchApplication(scenario: .error)
        defer { finishTesting(app) }

        MainScreen(app: app).openHistory()

        XCTAssertTrue(HistoryScreen(app: app).waitForErrorState())
    }

    @MainActor
    private func finishTesting(_ app: XCUIApplication) {
        attachFailureScreenshot(from: app, to: self)
        app.terminate()
    }
}
