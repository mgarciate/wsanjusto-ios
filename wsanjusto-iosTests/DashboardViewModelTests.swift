//
//  DashboardViewModelTests.swift
//  wsanjusto-iosTests
//
//  Created by Claude Code on 19/02/2026.
//

import Foundation
import Testing
@testable import wsanjusto_ios

@MainActor
struct DashboardViewModelTests {
    
    // MARK: - Weather Background Image Tests
    
    @Test("Weather background shows sunny day image for clear weather during daytime")
    func weatherBackgroundSunnyDay() async {
        // Given: A measure with sunny iconCode (32) during daytime
        let measure = createMeasure(
            iconCode: 32,
            sunriseTimeLocal: "2026-02-19T07:30:00+0100",
            sunsetTimeLocal: "2026-02-19T19:00:00+0100"
        )
        
        // When: ViewModel is at noon (daytime)
        let noonDate = createDate(hour: 12, minute: 0)
        let viewModel = DashboardViewModel(dateProvider: FixedDateProvider(fixedNow: noonDate))
        
        // Simulate update
        viewModel.update(measure: measure)
        
        // Then: Should show sunny day background (suffix 6)
        #expect(viewModel.weatherBackgroundImageName == "weather_dashboard_6")
    }
    
    @Test("Weather background shows night image for clear weather after sunset")
    func weatherBackgroundClearNight() async {
        // Given: A measure with clear night iconCode (31) after sunset
        let measure = createMeasure(
            iconCode: 31,
            sunriseTimeLocal: "2026-02-19T07:30:00+0100",
            sunsetTimeLocal: "2026-02-19T18:00:00+0100"
        )
        
        // When: ViewModel is at 9 PM (after sunset)
        let nightDate = createDate(hour: 21, minute: 0)
        let viewModel = DashboardViewModel(dateProvider: FixedDateProvider(fixedNow: nightDate))
        
        viewModel.update(measure: measure)
        
        // Then: Should show night background (suffix 7)
        #expect(viewModel.weatherBackgroundImageName == "weather_dashboard_7")
    }
    
    @Test("Weather background shows rainy image for rain iconCode")
    func weatherBackgroundRainy() async {
        // Given: A measure with rainy iconCode (12 = rain)
        let measure = createMeasure(
            iconCode: 12,
            sunriseTimeLocal: "2026-02-19T07:30:00+0100",
            sunsetTimeLocal: "2026-02-19T19:00:00+0100"
        )
        
        // When: ViewModel is at noon (daytime)
        let noonDate = createDate(hour: 12, minute: 0)
        let viewModel = DashboardViewModel(dateProvider: FixedDateProvider(fixedNow: noonDate))
        
        viewModel.update(measure: measure)
        
        // Then: Should show rainy background (suffix 0)
        #expect(viewModel.weatherBackgroundImageName == "weather_dashboard_0")
    }
    
    @Test("Weather background shows night rainy image for rain after sunset")
    func weatherBackgroundRainyNight() async {
        // Given: A measure with rainy iconCode (12) after sunset
        let measure = createMeasure(
            iconCode: 12,
            sunriseTimeLocal: "2026-02-19T07:30:00+0100",
            sunsetTimeLocal: "2026-02-19T18:00:00+0100"
        )
        
        // When: ViewModel is at night
        let nightDate = createDate(hour: 21, minute: 0)
        let viewModel = DashboardViewModel(dateProvider: FixedDateProvider(fixedNow: nightDate))
        
        viewModel.update(measure: measure)
        
        // Then: Should show night rainy background (0 transforms to 5 at night)
        #expect(viewModel.weatherBackgroundImageName == "weather_dashboard_5")
    }
    
    @Test("Weather background shows snowy image for snow iconCode")
    func weatherBackgroundSnowy() async {
        // Given: A measure with snow iconCode (13 = snow)
        let measure = createMeasure(
            iconCode: 13,
            sunriseTimeLocal: "2026-02-19T07:30:00+0100",
            sunsetTimeLocal: "2026-02-19T19:00:00+0100"
        )
        
        let noonDate = createDate(hour: 12, minute: 0)
        let viewModel = DashboardViewModel(dateProvider: FixedDateProvider(fixedNow: noonDate))
        
        viewModel.update(measure: measure)
        
        // Then: Should show snowy background (suffix 1)
        #expect(viewModel.weatherBackgroundImageName == "weather_dashboard_1")
    }
    
    @Test("Weather background defaults to day image when iconCode is nil during daytime")
    func weatherBackgroundDefaultDay() async {
        // Given: A measure with no iconCode during daytime
        let measure = createMeasure(
            iconCode: nil,
            sunriseTimeLocal: "2026-02-19T07:30:00+0100",
            sunsetTimeLocal: "2026-02-19T19:00:00+0100"
        )
        
        let noonDate = createDate(hour: 12, minute: 0)
        let viewModel = DashboardViewModel(dateProvider: FixedDateProvider(fixedNow: noonDate))
        
        viewModel.update(measure: measure)
        
        // Then: Should show default day background (suffix 6)
        #expect(viewModel.weatherBackgroundImageName == "weather_dashboard_6")
    }
    
    @Test("Weather background defaults to night image when iconCode is nil at night")
    func weatherBackgroundDefaultNight() async {
        // Given: A measure with no iconCode at night
        let measure = createMeasure(
            iconCode: nil,
            sunriseTimeLocal: "2026-02-19T07:30:00+0100",
            sunsetTimeLocal: "2026-02-19T18:00:00+0100"
        )
        
        let nightDate = createDate(hour: 21, minute: 0)
        let viewModel = DashboardViewModel(dateProvider: FixedDateProvider(fixedNow: nightDate))
        
        viewModel.update(measure: measure)
        
        // Then: Should show default night background (suffix 7)
        #expect(viewModel.weatherBackgroundImageName == "weather_dashboard_7")
    }
    
    // MARK: - Progress Value Tests
    
    @Test("Progress values are calculated correctly from measure")
    func progressValuesCalculation() async {
        // Given: A measure with specific temperature and humidity
        let measure = createMeasure(
            sensorTemperature1: 20.0,
            sensorHumidity1: 50.0
        )
        
        let viewModel = DashboardViewModel()
        
        // When: Update with the measure
        viewModel.update(measure: measure)
        
        // Then: Progress values should be calculated correctly
        #expect(viewModel.progressTempValue == 0.5) // 20/40 = 0.5
        #expect(viewModel.progressHumValue == 0.5)  // 50/100 = 0.5
    }
    
    @Test("Progress values are capped at 1.0 for high values")
    func progressValuesCappedAtMax() async {
        // Given: A measure with temperature > 40 and humidity > 100
        let measure = createMeasure(
            sensorTemperature1: 50.0,
            sensorHumidity1: 120.0
        )
        
        let viewModel = DashboardViewModel()
        
        viewModel.update(measure: measure)
        
        // Then: Progress values should be capped at 1.0
        #expect(viewModel.progressTempValue == 1.0)
        #expect(viewModel.progressHumValue == 1.0)
    }
    
    // MARK: - Night Time Detection Tests
    
    @Test("Detects night time when current time is before sunrise")
    func nightTimeBeforeSunrise() async {
        // Given: Current time is 6 AM, sunrise at 7:30 AM
        let measure = createMeasure(
            iconCode: 32, // sunny
            sunriseTimeLocal: "2026-02-19T07:30:00+0100",
            sunsetTimeLocal: "2026-02-19T18:00:00+0100"
        )
        
        let earlyMorning = createDate(hour: 6, minute: 0)
        let viewModel = DashboardViewModel(dateProvider: FixedDateProvider(fixedNow: earlyMorning))
        
        viewModel.update(measure: measure)
        
        // Then: Should use night transformation (sunny 32 -> 6 -> 7 at night)
        #expect(viewModel.weatherBackgroundImageName == "weather_dashboard_7")
    }
    
    @Test("Detects daytime when current time is between sunrise and sunset")
    func daytimeBetweenSunriseAndSunset() async {
        // Given: Current time is noon
        let measure = createMeasure(
            iconCode: 32, // sunny
            sunriseTimeLocal: "2026-02-19T07:30:00+0100",
            sunsetTimeLocal: "2026-02-19T18:00:00+0100"
        )
        
        let noon = createDate(hour: 12, minute: 0)
        let viewModel = DashboardViewModel(dateProvider: FixedDateProvider(fixedNow: noon))
        
        viewModel.update(measure: measure)
        
        // Then: Should use day background (sunny = 6)
        #expect(viewModel.weatherBackgroundImageName == "weather_dashboard_6")
    }
    
    // MARK: - Helper Methods
    
    private func createMeasure(
        sensorTemperature1: Double = 20.0,
        sensorHumidity1: Double = 50.0,
        iconCode: Int? = nil,
        sunriseTimeLocal: String? = nil,
        sunsetTimeLocal: String? = nil
    ) -> Measure {
        Measure(
            createdAt: Int(Date().timeIntervalSince1970),
            indexArduino: 0,
            orderByDate: 0,
            realFeel: sensorTemperature1,
            sensorHumidity1: sensorHumidity1,
            sensorTemperature1: sensorTemperature1,
            sensorTemperature2: sensorTemperature1,
            pressure1: 1013.0,
            uid: 1,
            dewpoint: 15.0,
            precipTotal: 0.0,
            uv: 3.0,
            windSpeed: 10.0,
            windGust: 15.0,
            windDir: 180,
            airQualityIndex: 50,
            airQualityCategory: "Good",
            villamecaActual: 13.3,
            villamecaWeeklyVolumeVariation: 0.5,
            villamecaLastYear: 12.8,
            iconCode: iconCode,
            shortPhrase: nil,
            sunriseTimeLocal: sunriseTimeLocal,
            sunsetTimeLocal: sunsetTimeLocal
        )
    }
    
    private func createDate(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 19
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(identifier: "Europe/Madrid")
        return Calendar.current.date(from: components)!
    }
}
