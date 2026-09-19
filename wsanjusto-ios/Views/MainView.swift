import SwiftUI

struct MainView: View {
    @StateObject private var dashboardViewModel: DashboardViewModel
    @ObservedObject private var authenticationService: AuthenticationService
    @StateObject private var chartViewModel: ChartViewModel
    @StateObject private var historicalViewModel: HistoricalViewModel
    private let isUITesting: Bool

    init(
        authenticationService: AuthenticationService = AuthenticationService(isEnabled: false),
        isUITesting: Bool = false,
        uiTestScenario: UITestScenario = .success
    ) {
        self.isUITesting = isUITesting
        let dashboardViewModel = DashboardViewModel()
        if isUITesting {
            dashboardViewModel.update(measure: .uiTestDashboard)
            dashboardViewModel.forecast = ForecastDay.uiTestForecast
        }
        _dashboardViewModel = StateObject(wrappedValue: dashboardViewModel)
        self.authenticationService = authenticationService

        let measuresLoader: any MeasuresLoading = isUITesting
            ? UITestMeasuresLoader(scenario: uiTestScenario)
            : FirebaseMeasuresLoader()
        _chartViewModel = StateObject(
            wrappedValue: ChartViewModel(measuresLoader: measuresLoader)
        )
        _historicalViewModel = StateObject(
            wrappedValue: HistoricalViewModel(measuresLoader: measuresLoader)
        )

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        TabView {
            DashboardView(
                viewModel: dashboardViewModel,
                authService: authenticationService,
                loadRemoteData: !isUITesting
            )
            .tabItem {
                Image(systemName: "thermometer")
                Text("Temperatura")
            }

            ChartView(viewModel: chartViewModel)
                .tabItem {
                    Image("timeline")
                    Text("Gráfico")
                }

            HistoricalView(viewModel: historicalViewModel)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Histórico")
                }

            AboutView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("Acerca de")
                }
        }
        .accessibilityIdentifier("main.tabView")
        .accentColor(Color("PrimaryColor"))
    }
}

private extension Measure {
    static let uiTestDashboard = Measure(
        createdAt: 1_800_000_000,
        indexArduino: 1,
        orderByDate: 1_800_000_000,
        realFeel: 18.5,
        sensorHumidity1: 62,
        sensorTemperature1: 19.5,
        sensorTemperature2: 19,
        pressure1: 1_018,
        uid: 1,
        dewpoint: 11,
        precipTotal: 1.25,
        uv: 3,
        windSpeed: 8,
        windGust: 14,
        windDir: 270,
        airQualityIndex: 24,
        airQualityCategory: "Buena",
        villamecaActual: 9.35,
        villamecaWeeklyVolumeVariation: 0.4,
        villamecaLastYear: 8.5,
        iconCode: 32,
        shortPhrase: "Despejado",
        sunriseTimeLocal: nil,
        sunsetTimeLocal: nil
    )
}

private extension ForecastDay {
    static let uiTestForecast: [ForecastDay] = (0..<5).map { index in
        ForecastDay(
            date: Date(timeIntervalSince1970: TimeInterval(1_800_000_000 + (index * 86_400))),
            tempMin: 1 + index,
            tempMax: 11 + index,
            precipitation: Double(index) + 0.5,
            qpfSnow: nil,
            iconCode: 32,
            narrative: "Previsión día \(index + 1)"
        )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
