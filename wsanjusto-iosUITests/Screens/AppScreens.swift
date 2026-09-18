import XCTest

@MainActor
struct MainScreen {
    let app: XCUIApplication

    private var tabBar: XCUIElement {
        app.tabBars.firstMatch
    }

    func waitUntilVisible() -> Bool {
        tabBar.waitForExistence(timeout: 5)
    }

    func hasAllTabs() -> Bool {
        ["Temperatura", "Gráfico", "Histórico", "Acerca de"]
            .allSatisfy { tabBar.buttons[$0].exists }
    }

    func openChart() {
        tabBar.buttons["Gráfico"].tap()
    }

    func openHistory() {
        tabBar.buttons["Histórico"].tap()
    }

    func openAbout() {
        tabBar.buttons["Acerca de"].tap()
    }
}

@MainActor
struct DashboardScreen {
    let app: XCUIApplication

    func waitForTemperature() -> Bool {
        app.staticTexts["dashboard.temperature"].waitForExistence(timeout: 5)
    }

    var hasRefreshButton: Bool {
        app.buttons["dashboard.refresh"].exists
    }

    func revealReservoir() -> Bool {
        scrollVertically(to: app.staticTexts["dashboard.reservoir.title"])
    }

    var reservoirMaxCapacity: String {
        app.staticTexts["dashboard.reservoir.maxCapacity"].label
    }

    var reservoirPercentage: String {
        app.staticTexts["dashboard.reservoir.percentage"].label
    }

    var reservoirCurrentVolume: String {
        app.staticTexts["dashboard.reservoir.currentVolume"].label
    }

    func revealForecast() -> Bool {
        scrollVertically(to: app.staticTexts["dashboard.forecast.title"])
    }

    func revealLastForecast() -> Bool {
        guard revealForecast() else { return false }

        let lastTemperature = app.staticTexts[
            "dashboard.forecast.temperature.last"
        ]
        let forecastScroll = app.scrollViews["dashboard.forecast.scroll"]
        for _ in 0..<5 where !lastTemperature.isHittable {
            forecastScroll.swipeLeft()
        }
        return lastTemperature.isHittable
    }

    var firstForecastTemperature: String {
        app.staticTexts["dashboard.forecast.temperature.first"].label
    }

    var firstForecastPrecipitation: String {
        app.staticTexts["dashboard.forecast.precipitation.first"].label
    }

    var lastForecastTemperature: String {
        app.staticTexts["dashboard.forecast.temperature.last"].label
    }

    var lastForecastPrecipitation: String {
        app.staticTexts["dashboard.forecast.precipitation.last"].label
    }

    private func scrollVertically(to element: XCUIElement) -> Bool {
        for _ in 0..<8 where !element.isHittable {
            app.swipeUp()
        }
        return element.isHittable
    }
}

@MainActor
struct ChartScreen {
    let app: XCUIApplication

    func waitForLoadedContent() -> Bool {
        app.staticTexts["chart.selectedTemperature"].waitForExistence(timeout: 5)
    }

    func waitForEmptyState() -> Bool {
        app.staticTexts["chart.empty"].waitForExistence(timeout: 5)
    }

    func waitForErrorState() -> Bool {
        app.staticTexts["chart.error"].waitForExistence(timeout: 5)
    }

    var selectedTemperature: String {
        app.staticTexts["chart.selectedTemperature"].label
    }

    var isLoading: Bool {
        app.staticTexts["chart.loading"].exists
    }
}

@MainActor
struct HistoryScreen {
    let app: XCUIApplication

    func waitForFirstRow() -> Bool {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "history.row."))
            .firstMatch
            .waitForExistence(timeout: 5)
    }

    func waitForEmptyState() -> Bool {
        app.staticTexts["history.empty"].waitForExistence(timeout: 5)
    }

    func waitForErrorState() -> Bool {
        app.staticTexts["history.error"].waitForExistence(timeout: 5)
    }
}

@MainActor
struct AboutScreen {
    let app: XCUIApplication

    func waitForVersion() -> Bool {
        app.staticTexts["about.version"].waitForExistence(timeout: 5)
    }

    var version: String {
        app.staticTexts["about.version"].label
    }
}
