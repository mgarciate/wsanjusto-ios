import Foundation
import Testing
@testable import wsanjusto_ios

struct AppLaunchConfigurationTests {
    @Test func usesProductionDefaultsWithoutUITestArguments() {
        let configuration = AppLaunchConfiguration(arguments: ["wsanjusto-ios"])

        #expect(!configuration.isUITesting)
        #expect(!configuration.skipSplash)
        #expect(configuration.uiTestScenario == .success)
    }

    @Test func parsesUITestScenario() {
        let configuration = AppLaunchConfiguration(arguments: [
            "wsanjusto-ios",
            "-UITesting",
            "-UITestingSkipSplash",
            "-UITestingScenario",
            "error"
        ])

        #expect(configuration.isUITesting)
        #expect(configuration.skipSplash)
        #expect(configuration.uiTestScenario == .error)
    }
}

@MainActor
struct AuthenticationServiceTests {
    @Test func startsStateListenerOnlyOnce() {
        var startCount = 0
        let service = AuthenticationService(
            isEnabled: false,
            stateListenerStarter: { startCount += 1 }
        )

        service.start()
        service.start()

        #expect(startCount == 1)
    }
}

struct ArraySafeSubscriptTests {
    @Test func returnsElementAtValidIndex() {
        let values = ["first", "second"]

        #expect(values[safe: 1] == "second")
    }

    @Test func returnsNilForInvalidIndices() {
        let values = ["value"]

        #expect(values[safe: -1] == nil)
        #expect(values[safe: 1] == nil)
    }
}

struct MeasureParsingTests {
    @Test func buildsMeasureFromCompleteDictionary() throws {
        var dictionary = makeMeasureDictionary()
        dictionary["sensorHumidity1"] = 105.0
        dictionary["winddir"] = 270
        dictionary["shortPhrase"] = "Despejado"

        let measure = try #require(Measure.build(from: dictionary))

        #expect(measure.createdAt == 1_700_000_000)
        #expect(measure.sensorHumidity1 == 99)
        #expect(measure.windDir == 270)
        #expect(measure.shortPhrase == "Despejado")
    }

    @Test func buildsMeasureWithoutOptionalFields() throws {
        let measure = try #require(Measure.build(from: makeMeasureDictionary()))

        #expect(measure.dewpoint == nil)
        #expect(measure.iconCode == nil)
        #expect(measure.sunriseTimeLocal == nil)
    }

    @Test func rejectsDictionaryMissingRequiredField() {
        var dictionary = makeMeasureDictionary()
        dictionary.removeValue(forKey: "pressure1")

        #expect(Measure.build(from: dictionary) == nil)
    }

    @Test func formatsDatesWithInjectedLocaleAndTimeZone() throws {
        let measure = try #require(Measure.build(from: makeMeasureDictionary()))
        let utc = try #require(TimeZone(secondsFromGMT: 0))

        #expect(measure.formattedDate(
            format: "dd/MM/yyyy HH:mm",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: utc
        ) == "14/11/2023 22:13")
        #expect(measure.formattedDate(
            format: "EEEE, dd MMMM HH:mm",
            locale: Locale(identifier: "es_ES"),
            timeZone: utc
        ) == "martes, 14 noviembre 22:13")
    }
}

struct ForecastTests {
    @Test func returnsNoDaysWhenRequiredDataIsMissing() {
        let forecast = Forecast(forecast5days: nil)

        #expect(forecast.toDays().isEmpty)
    }

    @Test func includesTodayBeforeTwoPM() throws {
        let now = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 13))
        let forecast = makeForecast()

        let days = forecast.toDays(
            dateProvider: FixedDateProvider(fixedNow: now),
            calendar: utcCalendar
        )

        #expect(days.count == 3)
        #expect(days[0].tempMin == 10)
        #expect(days[0].tempMax == 20)
        #expect(days[0].precipitation == 0.5)
        #expect(days[0].iconCode == 32)
        #expect(utcCalendar.component(.day, from: days[0].date) == 18)
    }

    @Test func startsWithTomorrowAtOrAfterTwoPM() throws {
        let now = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 14))
        let forecast = makeForecast()

        let days = forecast.toDays(
            dateProvider: FixedDateProvider(fixedNow: now),
            calendar: utcCalendar
        )

        #expect(days.count == 2)
        #expect(days[0].tempMin == 11)
        #expect(days[0].tempMax == 21)
        #expect(days[0].precipitation == 0)
        #expect(days[0].iconCode == 40)
        #expect(utcCalendar.component(.day, from: days[0].date) == 19)
    }

    @Test func skipsDaysWithoutTemperatures() throws {
        let now = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 10))
        let data = Forecast5Day(
            calendarDayTemperatureMax: [20, nil, 22],
            calendarDayTemperatureMin: [10, 11, 12],
            temperatureMax: nil,
            temperatureMin: nil,
            narrative: nil,
            qpf: [0, 0, 0],
            qpfSnow: nil,
            sunriseTimeLocal: nil,
            sunsetTimeLocal: nil,
            iconCode: nil
        )

        let days = Forecast(forecast5days: data).toDays(
            dateProvider: FixedDateProvider(fixedNow: now),
            calendar: utcCalendar
        )

        #expect(days.count == 2)
        #expect(days.map(\.tempMax) == [20, 22])
    }

    @Test func fallsBackToNightIcon() throws {
        let now = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 10))
        let data = Forecast5Day(
            calendarDayTemperatureMax: [20],
            calendarDayTemperatureMin: [10],
            temperatureMax: nil,
            temperatureMin: nil,
            narrative: nil,
            qpf: [0],
            qpfSnow: nil,
            sunriseTimeLocal: nil,
            sunsetTimeLocal: nil,
            iconCode: [nil, 31]
        )

        let days = Forecast(forecast5days: data).toDays(
            dateProvider: FixedDateProvider(fixedNow: now),
            calendar: utcCalendar
        )

        #expect(days.first?.iconCode == 31)
    }
}

@MainActor
struct DashboardViewModelTests {
    @Test(arguments: weatherIconMappingCases)
    func mapsWeatherIconsForDayAndNight(testCase: WeatherIconMappingCase) throws {
        let midday = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 12))
        let night = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 20))
        let mapper = WeatherPresentationMapper()
        let measure = try #require(makeMeasure(
            iconCode: testCase.iconCode,
            sunriseTimeLocal: "2026-09-18T06:00:00Z",
            sunsetTimeLocal: "2026-09-18T18:00:00Z"
        ))

        #expect(mapper.backgroundImageName(for: measure, at: midday) == testCase.dayImageName)
        #expect(mapper.backgroundImageName(for: measure, at: night) == testCase.nightImageName)
    }

    @Test func usesDayFallbackForUnknownIconAndInvalidTimes() throws {
        let midday = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 12))
        let measure = try #require(makeMeasure(
            iconCode: 999,
            sunriseTimeLocal: "invalid",
            sunsetTimeLocal: "invalid"
        ))

        let imageName = WeatherPresentationMapper()
            .backgroundImageName(for: measure, at: midday)

        #expect(imageName == "weather_dashboard_6")
    }

    @Test func detectsNightBeforeSunriseAndAfterSunset() throws {
        let beforeSunrise = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 4))
        let afterSunset = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 20))
        let sunrise = "2026-09-18T06:00:00Z"
        let sunset = "2026-09-18T18:00:00Z"

        let morningViewModel = DashboardViewModel(
            dateProvider: FixedDateProvider(fixedNow: beforeSunrise)
        )
        let eveningViewModel = DashboardViewModel(
            dateProvider: FixedDateProvider(fixedNow: afterSunset)
        )

        #expect(morningViewModel.isNightTime(
            sunriseTimeLocal: sunrise,
            sunsetTimeLocal: sunset
        ))
        #expect(eveningViewModel.isNightTime(
            sunriseTimeLocal: sunrise,
            sunsetTimeLocal: sunset
        ))
    }

    @Test func detectsDayBetweenSunriseAndSunset() throws {
        let midday = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 12))
        let viewModel = DashboardViewModel(
            dateProvider: FixedDateProvider(fixedNow: midday)
        )

        #expect(!viewModel.isNightTime(
            sunriseTimeLocal: "2026-09-18T06:00:00Z",
            sunsetTimeLocal: "2026-09-18T18:00:00Z"
        ))
    }

    @Test func selectsDayAndNightBackgrounds() throws {
        let midday = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 12))
        let night = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 20))
        let measure = try #require(makeMeasure(
            iconCode: 32,
            sunriseTimeLocal: "2026-09-18T06:00:00Z",
            sunsetTimeLocal: "2026-09-18T18:00:00Z"
        ))

        let dayViewModel = DashboardViewModel(
            dateProvider: FixedDateProvider(fixedNow: midday)
        )
        let nightViewModel = DashboardViewModel(
            dateProvider: FixedDateProvider(fixedNow: night)
        )

        #expect(dayViewModel.calculateWeatherBackgroundImageName(for: measure) == "weather_dashboard_6")
        #expect(nightViewModel.calculateWeatherBackgroundImageName(for: measure) == "weather_dashboard_7")
    }

    @Test func updatesMeasureAndUsesNormalizedProgress() throws {
        let now = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 12))
        let measure = try #require(makeMeasure(
            temperature: 80,
            humidity: 120,
            iconCode: 32
        ))
        let viewModel = DashboardViewModel(
            dateProvider: FixedDateProvider(fixedNow: now)
        )

        viewModel.update(measure: measure)

        #expect(viewModel.measure.uid == measure.uid)
        #expect(viewModel.progressTempValue == 1)
        #expect(viewModel.progressHumValue == 0.99)
        #expect(viewModel.weatherBackgroundImageName == "weather_dashboard_6")
    }

    @Test func refreshRestoresPreviousStateUsingInjectedScheduler() throws {
        let now = try #require(makeUTCDate(year: 2026, month: 9, day: 18, hour: 12))
        let measure = try #require(makeMeasure(temperature: 20, humidity: 50))
        var scheduledDelay: TimeInterval?
        let viewModel = DashboardViewModel(
            dateProvider: FixedDateProvider(fixedNow: now),
            schedule: { delay, action in
                scheduledDelay = delay
                action()
            }
        )
        viewModel.update(measure: measure)

        viewModel.refreshData()

        #expect(scheduledDelay == 1)
        #expect(viewModel.measure.uid == measure.uid)
        #expect(viewModel.progressTempValue == 0.5)
        #expect(viewModel.progressHumValue == 0.5)
    }
}

@MainActor
struct ChartViewModelTests {
    @Test func selectsAndClearsMeasure() throws {
        let measure = try #require(makeMeasure(temperature: 19.5))
        let viewModel = ChartViewModel()

        viewModel.select(measure: measure)

        #expect(viewModel.selectedDate == measure.dateString)
        #expect(viewModel.selectedValue == "19.50 °C")

        viewModel.clear()

        #expect(viewModel.selectedDate == "-")
        #expect(viewModel.selectedValue == "- °C")
    }

    @Test func calculatesDomainWithPadding() throws {
        let cold = try #require(makeMeasure(temperature: 5))
        let warm = try #require(makeMeasure(temperature: 22))
        let viewModel = ChartViewModel()

        viewModel.update(measures: [cold, warm])

        #expect(viewModel.measures.count == 2)
        #expect(viewModel.chartDomain == 3...24)
    }

    @Test func usesDefaultDomainForEmptyMeasures() {
        let viewModel = ChartViewModel()

        viewModel.update(measures: [])

        #expect(viewModel.measures.isEmpty)
        #expect(viewModel.chartDomain == -2...52)
    }

    @Test func changesMetricAndFormatsItsSelectedValue() throws {
        let measure = try #require(makeMeasure(windSpeed: 8.25, precipitation: 1.5))
        let viewModel = ChartViewModel()
        viewModel.update(measures: [measure])

        viewModel.selectedMetric = .windSpeed
        viewModel.select(measure: measure)

        #expect(viewModel.selectedValue == "8.25 km/h")
        #expect(viewModel.chartDomain == 0...9.25)

        viewModel.selectedMetric = .precipitation

        #expect(viewModel.selectedDate == "-")
        #expect(viewModel.selectedValue == "- mm")
        #expect(viewModel.chartDomain == 0...2.5)
    }

    @Test func omitsMeasuresWithoutTheSelectedMetric() throws {
        let available = try #require(makeMeasure(windSpeed: 12))
        let unavailable = try #require(makeMeasure(uid: 43))
        let viewModel = ChartViewModel()
        viewModel.update(measures: [available, unavailable])

        viewModel.selectedMetric = .windSpeed

        #expect(viewModel.chartData.count == 1)
        #expect(viewModel.chartData.first?.measure.uid == available.uid)
        #expect(viewModel.chartData.first?.value == 12)
    }

    @Test func ordersPointsAndOmitsInvalidWeatherValues() throws {
        let latest = try #require(makeMeasure(timestamp: 300, windSpeed: 18))
        let earliest = try #require(makeMeasure(timestamp: 100, uid: 43, windSpeed: 5))
        let negative = try #require(makeMeasure(timestamp: 200, uid: 44, windSpeed: -1))
        let viewModel = ChartViewModel()
        viewModel.update(measures: [latest, negative, earliest])

        viewModel.selectedMetric = .windSpeed

        #expect(viewModel.chartData.map(\.measure.uid) == [earliest.uid, latest.uid])
        #expect(viewModel.chartDomain == 0...19.8)
    }

    @Test func clearsSelectionWhenMeasureHasNoValueForMetric() throws {
        let wind = try #require(makeMeasure(windSpeed: 12))
        let missingWind = try #require(makeMeasure(uid: 43))
        let viewModel = ChartViewModel()
        viewModel.selectedMetric = .windSpeed
        viewModel.select(measure: wind)

        viewModel.select(measure: missingWind)

        #expect(viewModel.selectedDate == "-")
        #expect(viewModel.selectedValue == "- km/h")
    }

    @Test func findsClosestAvailableDataPointRegardlessOfOrdering() throws {
        let latest = try #require(makeMeasure(timestamp: 300, windSpeed: 18))
        let earliest = try #require(makeMeasure(timestamp: 100, uid: 43, windSpeed: 5))
        let unavailable = try #require(makeMeasure(timestamp: 250, uid: 44))
        let viewModel = ChartViewModel()
        viewModel.update(measures: [latest, earliest, unavailable])
        viewModel.selectedMetric = .windSpeed

        let point = viewModel.closestDataPoint(
            to: Date(timeIntervalSince1970: 260)
        )

        #expect(point?.measure.uid == latest.uid)
        #expect(point?.value == 18)
    }
}

@MainActor
struct MeasuresLoadingViewModelTests {
    @Test func chartUsesTheExpectedLimit() async {
        let loader = RecordingMeasuresLoader(result: .success([]))
        let chartViewModel = ChartViewModel(measuresLoader: loader)

        await chartViewModel.fetchData().value

        #expect(await loader.requestedLimits() == [150])
    }

    @Test func chartClearsSelectionWhenFetching() async throws {
        let measure = try #require(makeMeasure(temperature: 19.5))
        let loader = StubMeasuresLoader(result: .success([measure]))
        let viewModel = ChartViewModel(measuresLoader: loader)
        viewModel.select(measure: measure)

        let task = viewModel.fetchData()

        #expect(viewModel.selectedDate == "-")
        #expect(viewModel.selectedValue == "- °C")
        await task.value
    }

    @Test func chartEmptyResponseProducesEmptyState() async {
        let loader = StubMeasuresLoader(result: .success([]))
        let chartViewModel = ChartViewModel(measuresLoader: loader)

        await chartViewModel.fetchData().value

        #expect(chartViewModel.measures.isEmpty)
        #expect(chartViewModel.loadingState == .empty)
    }

    @Test func chartFetchesMeasuresAndStopsLoading() async throws {
        let measure = try #require(makeMeasure(temperature: 17))
        let loader = StubMeasuresLoader(result: .success([measure]))
        let viewModel = ChartViewModel(measuresLoader: loader)

        viewModel.fetchData()
        let didFinish = await waitUntilFinished(viewModel: viewModel)

        #expect(didFinish)
        #expect(viewModel.measures.count == 1)
        #expect(viewModel.chartDomain == 15...19)
        #expect(!viewModel.isLoading)
        #expect(viewModel.loadingState == .loaded)
    }

    @Test func chartClearsMeasuresAfterLoadingError() async throws {
        let previous = try #require(makeMeasure(temperature: 17))
        let loader = StubMeasuresLoader(result: .failure(TestError.expected))
        let viewModel = ChartViewModel(measuresLoader: loader)
        viewModel.update(measures: [previous])

        viewModel.fetchData()
        let didFinish = await waitUntilFinished(viewModel: viewModel)

        #expect(didFinish)
        #expect(viewModel.measures.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(viewModel.loadingState == .failed)
    }

    @Test func chartIgnoresFailureFromSupersededRequest() async throws {
        let latestMeasure = try #require(makeMeasure(temperature: 23))
        let loader = ControlledMeasuresLoader()
        let viewModel = ChartViewModel(measuresLoader: loader)

        let supersededTask = viewModel.fetchData()
        let firstRequestStarted = await loader.waitForRequestCount(1)
        try #require(firstRequestStarted)
        let latestTask = viewModel.fetchData()
        let secondRequestStarted = await loader.waitForRequestCount(2)
        try #require(secondRequestStarted)

        await loader.resumeRequest(at: 1, with: .success([latestMeasure]))
        await latestTask.value
        await loader.resumeRequest(at: 0, with: .failure(TestError.expected))
        await supersededTask.value

        #expect(viewModel.measures.first?.sensorTemperature1 == 23)
        #expect(viewModel.loadingState == .loaded)
    }

}

@MainActor
struct HistoricalViewModelTests {
    @Test func loadsTheFirstPageWithFiftyEntries() async throws {
        let measure = try #require(makeMeasure(uid: 1))
        let loader = RecordingHistoricalLoader(results: [
            .success(page(measures: [measure], hasMore: false))
        ])
        let viewModel = HistoricalViewModel(loader: loader)

        await viewModel.fetchData().value

        #expect(viewModel.measures.map(\.uid) == [1])
        #expect(viewModel.loadingState == .loaded)
        #expect(!viewModel.hasMore)
        #expect(await loader.requestedLimits() == [50])
        #expect(await loader.requestedCursors() == [nil])
    }

    @Test func emptyFirstPageProducesEmptyState() async {
        let loader = RecordingHistoricalLoader(results: [
            .success(page(measures: [], hasMore: false))
        ])
        let viewModel = HistoricalViewModel(loader: loader)

        await viewModel.fetchData().value

        #expect(viewModel.measures.isEmpty)
        #expect(viewModel.loadingState == .empty)
    }

    @Test func failedFirstPageProducesFailedState() async {
        let loader = RecordingHistoricalLoader(results: [.failure(TestError.expected)])
        let viewModel = HistoricalViewModel(loader: loader)

        await viewModel.fetchData().value

        #expect(viewModel.measures.isEmpty)
        #expect(viewModel.loadingState == .failed)
    }

    @Test func appendsTheNextPageUsingThePreviousCursor() async throws {
        let first = try #require(makeMeasure(uid: 1))
        let second = try #require(makeMeasure(uid: 2))
        let cursor = HistoricalPageCursor(orderByDate: 100, key: "first")
        let loader = RecordingHistoricalLoader(results: [
            .success(page(measures: [first], cursor: cursor, hasMore: true)),
            .success(page(measures: [second], hasMore: false))
        ])
        let viewModel = HistoricalViewModel(loader: loader)

        await viewModel.fetchData().value
        await viewModel.loadNextPage()?.value

        #expect(viewModel.measures.map(\.uid) == [1, 2])
        #expect(await loader.requestedLimits() == [50, 50])
        #expect(await loader.requestedCursors() == [nil, cursor])
        #expect(!viewModel.hasMore)
    }

    @Test func removesDuplicatesAtPageBoundaries() async throws {
        let first = try #require(makeMeasure(uid: 1))
        let second = try #require(makeMeasure(uid: 2))
        let cursor = HistoricalPageCursor(orderByDate: 100, key: "first")
        let loader = RecordingHistoricalLoader(results: [
            .success(page(measures: [first], cursor: cursor, hasMore: true)),
            .success(page(measures: [first, second], hasMore: false))
        ])
        let viewModel = HistoricalViewModel(loader: loader)

        await viewModel.fetchData().value
        await viewModel.loadNextPage()?.value

        #expect(viewModel.measures.map(\.uid) == [1, 2])
    }

    @Test func removesDuplicatesWithinTheSamePage() async throws {
        let first = try #require(makeMeasure(uid: 1))
        let duplicate = try #require(makeMeasure(temperature: 24, uid: 1))
        let loader = RecordingHistoricalLoader(results: [
            .success(page(measures: [first, duplicate], hasMore: false))
        ])
        let viewModel = HistoricalViewModel(loader: loader)

        await viewModel.fetchData().value

        #expect(viewModel.measures.map(\.uid) == [1])
        #expect(viewModel.measures.first?.sensorTemperature1 == 19.5)
    }

    @Test func preservesLoadedEntriesAndCanRetryAfterPageFailure() async throws {
        let first = try #require(makeMeasure(uid: 1))
        let second = try #require(makeMeasure(uid: 2))
        let cursor = HistoricalPageCursor(orderByDate: 100, key: "first")
        let loader = RecordingHistoricalLoader(results: [
            .success(page(measures: [first], cursor: cursor, hasMore: true)),
            .failure(TestError.expected),
            .success(page(measures: [second], hasMore: false))
        ])
        let viewModel = HistoricalViewModel(loader: loader)

        await viewModel.fetchData().value
        await viewModel.loadNextPage()?.value

        #expect(viewModel.measures.map(\.uid) == [1])
        #expect(viewModel.pageLoadFailed)
        #expect(viewModel.loadingState == .loaded)

        await viewModel.loadNextPage()?.value

        #expect(viewModel.measures.map(\.uid) == [1, 2])
        #expect(!viewModel.pageLoadFailed)
    }

    @Test func doesNotRequestAnotherPageAfterTheEnd() async {
        let loader = RecordingHistoricalLoader(results: [
            .success(page(measures: [], hasMore: false))
        ])
        let viewModel = HistoricalViewModel(loader: loader)

        await viewModel.fetchData().value
        let nextTask = viewModel.loadNextPage()

        #expect(nextTask == nil)
        #expect(await loader.requestedLimits() == [50])
    }

    @Test func refreshReplacesPreviouslyLoadedPages() async throws {
        let first = try #require(makeMeasure(uid: 1))
        let replacement = try #require(makeMeasure(uid: 3))
        let loader = RecordingHistoricalLoader(results: [
            .success(page(measures: [first], hasMore: false)),
            .success(page(measures: [replacement], hasMore: false))
        ])
        let viewModel = HistoricalViewModel(loader: loader)

        await viewModel.fetchData().value
        await viewModel.fetchData().value

        #expect(viewModel.measures.map(\.uid) == [3])
    }

    @Test func ignoresConcurrentPageRequests() async throws {
        let first = try #require(makeMeasure(uid: 1))
        let second = try #require(makeMeasure(uid: 2))
        let cursor = HistoricalPageCursor(orderByDate: 100, key: "first")
        let loader = ControlledHistoricalLoader()
        let viewModel = HistoricalViewModel(loader: loader)

        let initialTask = viewModel.fetchData()
        try #require(await loader.waitForRequestCount(1))
        #expect(viewModel.loadNextPage() == nil)
        await loader.resumeRequest(
            at: 0,
            with: .success(page(measures: [first], cursor: cursor, hasMore: true))
        )
        await initialTask.value

        let nextTask = try #require(viewModel.loadNextPage())
        try #require(await loader.waitForRequestCount(2))
        #expect(viewModel.loadNextPage() == nil)
        await loader.resumeRequest(
            at: 1,
            with: .success(page(measures: [second], hasMore: false))
        )
        await nextTask.value

        #expect(viewModel.measures.map(\.uid) == [1, 2])
        #expect(await loader.requestCount() == 2)
    }

    @Test func ignoresFailureFromASupersededRefresh() async throws {
        let latestMeasure = try #require(makeMeasure(uid: 2))
        let loader = ControlledHistoricalLoader()
        let viewModel = HistoricalViewModel(loader: loader)

        let supersededTask = viewModel.fetchData()
        try #require(await loader.waitForRequestCount(1))
        let latestTask = viewModel.fetchData()
        try #require(await loader.waitForRequestCount(2))

        await loader.resumeRequest(
            at: 1,
            with: .success(page(measures: [latestMeasure], hasMore: false))
        )
        await latestTask.value
        await loader.resumeRequest(at: 0, with: .failure(TestError.expected))
        await supersededTask.value

        #expect(viewModel.measures.map(\.uid) == [2])
        #expect(viewModel.loadingState == .loaded)
    }
}

struct DashboardDataParsingTests {
    @Test func buildsCurrentMeasureAndForecast() throws {
        let forecastDictionary: [String: Any] = [
            "calendarDayTemperatureMax": [20, 21],
            "calendarDayTemperatureMin": [10, 11],
            "qpf": [0.0, 1.5],
            "iconCode": [32, 31, 40, 39]
        ]
        let dictionary: [String: Any] = [
            "current": makeMeasureDictionary(),
            "forecast": ["forecast5days": forecastDictionary]
        ]

        let dashboard = try #require(DashboardData.build(from: dictionary))

        #expect(dashboard.current?.uid == 42)
        #expect(dashboard.forecast?.forecast5days?.calendarDayTemperatureMax == [20, 21])
    }

    @Test func buildsEmptyDashboardFromEmptyDictionary() throws {
        let dashboard = try #require(DashboardData.build(from: [:]))

        #expect(dashboard.current == nil)
        #expect(dashboard.forecast == nil)
    }
}

private enum TestError: Error {
    case expected
}

private struct StubMeasuresLoader: MeasuresLoading {
    let result: Result<[Measure], Error>

    func fetchMeasures(limit: UInt) async throws -> [Measure] {
        try result.get()
    }
}

private actor RecordingMeasuresLoader: MeasuresLoading {
    let result: Result<[Measure], Error>
    private var limits: [UInt] = []

    init(result: Result<[Measure], Error>) {
        self.result = result
    }

    func fetchMeasures(limit: UInt) throws -> [Measure] {
        limits.append(limit)
        return try result.get()
    }

    func requestedLimits() -> [UInt] {
        limits
    }
}

private actor ControlledMeasuresLoader: MeasuresLoading {
    private var continuations: [CheckedContinuation<[Measure], Error>] = []

    func fetchMeasures(limit: UInt) async throws -> [Measure] {
        try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func waitForRequestCount(_ count: Int) async -> Bool {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(5))
        while continuations.count < count {
            guard clock.now < deadline else { return false }
            await Task.yield()
        }
        return true
    }

    func resumeRequest(at index: Int, with result: Result<[Measure], Error>) {
        continuations[index].resume(with: result)
    }
}

private actor RecordingHistoricalLoader: HistoricalMeasuresLoading {
    private let results: [Result<HistoricalPage, Error>]
    private var limits: [UInt] = []
    private var cursors: [HistoricalPageCursor?] = []

    init(results: [Result<HistoricalPage, Error>]) {
        self.results = results
    }

    func fetchPage(
        limit: UInt,
        after cursor: HistoricalPageCursor?
    ) async throws -> HistoricalPage {
        let requestIndex = limits.count
        limits.append(limit)
        cursors.append(cursor)
        return try results[requestIndex].get()
    }

    func requestedLimits() -> [UInt] {
        limits
    }

    func requestedCursors() -> [HistoricalPageCursor?] {
        cursors
    }
}

private actor ControlledHistoricalLoader: HistoricalMeasuresLoading {
    private var continuations: [CheckedContinuation<HistoricalPage, Error>] = []

    func fetchPage(
        limit: UInt,
        after cursor: HistoricalPageCursor?
    ) async throws -> HistoricalPage {
        try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func waitForRequestCount(_ count: Int) async -> Bool {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(5))
        while continuations.count < count {
            guard clock.now < deadline else { return false }
            await Task.yield()
        }
        return true
    }

    func resumeRequest(
        at index: Int,
        with result: Result<HistoricalPage, Error>
    ) {
        continuations[index].resume(with: result)
    }

    func requestCount() -> Int {
        continuations.count
    }
}

private func page(
    measures: [Measure],
    cursor: HistoricalPageCursor? = nil,
    hasMore: Bool
) -> HistoricalPage {
    HistoricalPage(measures: measures, nextCursor: cursor, hasMore: hasMore)
}

@MainActor
private func waitUntilFinished(viewModel: ChartViewModel) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: .seconds(5))
    while viewModel.isLoading {
        guard clock.now < deadline else { return false }
        await Task.yield()
    }
    return true
}

@MainActor
private func waitUntilFinished(viewModel: HistoricalViewModel) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: .seconds(5))
    while viewModel.isLoading {
        guard clock.now < deadline else { return false }
        await Task.yield()
    }
    return true
}

private let utcCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
}()

private func makeUTCDate(
    year: Int,
    month: Int,
    day: Int,
    hour: Int
) -> Date? {
    utcCalendar.date(
        from: DateComponents(
            timeZone: utcCalendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour
        )
    )
}

private func makeMeasureDictionary() -> [String: Any] {
    [
        "createdAt": 1_700_000_000,
        "indexArduino": 7,
        "orderByDate": 1_700_000_000,
        "realFeel": 18.5,
        "sensorHumidity1": 65.0,
        "sensorTemperature1": 19.5,
        "sensorTemperature2": 20.0,
        "pressure1": 1_015.0,
        "uid": 42
    ]
}

private func makeMeasure(
    temperature: Double = 19.5,
    humidity: Double = 65,
    timestamp: Int = 1_700_000_000,
    uid: Int = 42,
    windSpeed: Double? = nil,
    precipitation: Double? = nil,
    iconCode: Int? = nil,
    sunriseTimeLocal: String? = nil,
    sunsetTimeLocal: String? = nil
) -> Measure? {
    var dictionary = makeMeasureDictionary()
    dictionary["sensorTemperature1"] = temperature
    dictionary["sensorHumidity1"] = humidity
    dictionary["createdAt"] = timestamp
    dictionary["uid"] = uid
    dictionary["windSpeed"] = windSpeed
    dictionary["precipTotal"] = precipitation
    dictionary["iconCode"] = iconCode
    dictionary["sunriseTimeLocal"] = sunriseTimeLocal
    dictionary["sunsetTimeLocal"] = sunsetTimeLocal
    return Measure.build(from: dictionary)
}

struct WeatherIconMappingCase: Sendable {
    let iconCode: Int
    let dayImageName: String
    let nightImageName: String
}

private let weatherIconMappingCases = [
    WeatherIconMappingCase(iconCode: 8, dayImageName: "weather_dashboard_0", nightImageName: "weather_dashboard_5"),
    WeatherIconMappingCase(iconCode: 13, dayImageName: "weather_dashboard_1", nightImageName: "weather_dashboard_12"),
    WeatherIconMappingCase(iconCode: 28, dayImageName: "weather_dashboard_2", nightImageName: "weather_dashboard_4"),
    WeatherIconMappingCase(iconCode: 20, dayImageName: "weather_dashboard_3", nightImageName: "weather_dashboard_4"),
    WeatherIconMappingCase(iconCode: 27, dayImageName: "weather_dashboard_2", nightImageName: "weather_dashboard_4"),
    WeatherIconMappingCase(iconCode: 45, dayImageName: "weather_dashboard_0", nightImageName: "weather_dashboard_5"),
    WeatherIconMappingCase(iconCode: 32, dayImageName: "weather_dashboard_6", nightImageName: "weather_dashboard_7"),
    WeatherIconMappingCase(iconCode: 31, dayImageName: "weather_dashboard_6", nightImageName: "weather_dashboard_7"),
    WeatherIconMappingCase(iconCode: 39, dayImageName: "weather_dashboard_8", nightImageName: "weather_dashboard_5"),
    WeatherIconMappingCase(iconCode: 3, dayImageName: "weather_dashboard_9", nightImageName: "weather_dashboard_14"),
    WeatherIconMappingCase(iconCode: 37, dayImageName: "weather_dashboard_10", nightImageName: "weather_dashboard_14"),
    WeatherIconMappingCase(iconCode: 19, dayImageName: "weather_dashboard_11", nightImageName: "weather_dashboard_7"),
    WeatherIconMappingCase(iconCode: 46, dayImageName: "weather_dashboard_1", nightImageName: "weather_dashboard_12"),
    WeatherIconMappingCase(iconCode: 5, dayImageName: "weather_dashboard_13", nightImageName: "weather_dashboard_5"),
    WeatherIconMappingCase(iconCode: 47, dayImageName: "weather_dashboard_9", nightImageName: "weather_dashboard_14")
]

private func makeForecast() -> Forecast {
    Forecast(
        forecast5days: Forecast5Day(
            calendarDayTemperatureMax: [20, 21, 22],
            calendarDayTemperatureMin: [10, 11, 12],
            temperatureMax: nil,
            temperatureMin: nil,
            narrative: ["Hoy", nil, "Pasado mañana"],
            qpf: [0.5, nil, 2.0],
            qpfSnow: [nil, nil, 0.2],
            sunriseTimeLocal: nil,
            sunsetTimeLocal: nil,
            iconCode: [32, 31, nil, 40, 28, 27]
        )
    )
}
