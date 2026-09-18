import Foundation
import Testing
@testable import wsanjusto_ios

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

struct DashboardViewModelTests {
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

struct ChartViewModelTests {
    @Test func selectsAndClearsMeasure() throws {
        let measure = try #require(makeMeasure(temperature: 19.5))
        let viewModel = ChartViewModel()

        viewModel.select(measure: measure)

        #expect(viewModel.selectedDate == measure.dateString)
        #expect(viewModel.selectedTemperature == "19.50 °C")

        viewModel.clear()

        #expect(viewModel.selectedDate == "-")
        #expect(viewModel.selectedTemperature == "- ºC")
    }

    @Test func calculatesDomainWithPadding() throws {
        let cold = try #require(makeMeasure(temperature: 5))
        let warm = try #require(makeMeasure(temperature: 22))
        let viewModel = ChartViewModel()

        viewModel.update(measures: [cold, warm])

        #expect(viewModel.measures.count == 2)
        #expect(viewModel.domainMeasuresFrom == 3)
        #expect(viewModel.domainMeasuresTo == 24)
    }

    @Test func usesDefaultDomainForEmptyMeasures() {
        let viewModel = ChartViewModel()

        viewModel.update(measures: [])

        #expect(viewModel.measures.isEmpty)
        #expect(viewModel.domainMeasuresFrom == -2)
        #expect(viewModel.domainMeasuresTo == 52)
    }
}

struct MeasuresLoadingViewModelTests {
    @Test func chartFetchesMeasuresAndStopsLoading() async throws {
        let measure = try #require(makeMeasure(temperature: 17))
        let loader = StubMeasuresLoader(result: .success([measure]))
        let viewModel = ChartViewModel(measuresLoader: loader)

        viewModel.fetchData()
        await waitUntilFinished(viewModel: viewModel)

        #expect(viewModel.measures.count == 1)
        #expect(viewModel.domainMeasuresFrom == 15)
        #expect(viewModel.domainMeasuresTo == 19)
        #expect(!viewModel.isLoading)
    }

    @Test func chartClearsMeasuresAfterLoadingError() async throws {
        let previous = try #require(makeMeasure(temperature: 17))
        let loader = StubMeasuresLoader(result: .failure(TestError.expected))
        let viewModel = ChartViewModel(measuresLoader: loader)
        viewModel.update(measures: [previous])

        viewModel.fetchData()
        await waitUntilFinished(viewModel: viewModel)

        #expect(viewModel.measures.isEmpty)
        #expect(!viewModel.isLoading)
    }

    @Test func historicalFetchesMeasuresAndStopsLoading() async throws {
        let measure = try #require(makeMeasure())
        let loader = StubMeasuresLoader(result: .success([measure]))
        let viewModel = HistoricalViewModel(measuresLoader: loader)

        viewModel.fetchData()
        await waitUntilFinished(viewModel: viewModel)

        #expect(viewModel.measures.count == 1)
        #expect(!viewModel.isLoading)
    }

    @Test func historicalClearsMeasuresAfterLoadingError() async {
        let loader = StubMeasuresLoader(result: .failure(TestError.expected))
        let viewModel = HistoricalViewModel(measuresLoader: loader)

        viewModel.fetchData()
        await waitUntilFinished(viewModel: viewModel)

        #expect(viewModel.measures.isEmpty)
        #expect(!viewModel.isLoading)
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

private func waitUntilFinished(viewModel: ChartViewModel) async {
    while viewModel.isLoading {
        await Task.yield()
    }
}

private func waitUntilFinished(viewModel: HistoricalViewModel) async {
    while viewModel.isLoading {
        await Task.yield()
    }
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
    iconCode: Int? = nil,
    sunriseTimeLocal: String? = nil,
    sunsetTimeLocal: String? = nil
) -> Measure? {
    var dictionary = makeMeasureDictionary()
    dictionary["sensorTemperature1"] = temperature
    dictionary["sensorHumidity1"] = humidity
    dictionary["iconCode"] = iconCode
    dictionary["sunriseTimeLocal"] = sunriseTimeLocal
    dictionary["sunsetTimeLocal"] = sunsetTimeLocal
    return Measure.build(from: dictionary)
}

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
