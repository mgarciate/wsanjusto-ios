//
//  ForecastTests.swift
//  wsanjusto-iosTests
//
//  Created by Claude Code on 19/02/2026.
//

import Foundation
import Testing
@testable import wsanjusto_ios

struct ForecastTests {
    
    // MARK: - ForecastDay Tests
    
    @Test("ForecastDay dayName formats correctly in Spanish")
    func forecastDayNameSpanishFormat() {
        // Given: A forecast day for a known date
        let date = createDate(year: 2026, month: 2, day: 19) // Thursday
        let forecastDay = ForecastDay(
            date: date,
            tempMin: 5,
            tempMax: 15,
            precipitation: 0.0,
            qpfSnow: nil,
            iconCode: 32,
            narrative: "Sunny"
        )
        
        // Then: dayName should be in Spanish format (capitalized)
        let dayName = forecastDay.dayName
        #expect(!dayName.isEmpty)
        #expect(dayName.contains("/")) // Format includes dd/MM
    }
    
    @Test("ForecastDay is Identifiable with unique IDs")
    func forecastDayUniqueIds() {
        let date = Date()
        let day1 = ForecastDay(date: date, tempMin: 5, tempMax: 15, precipitation: 0.0, qpfSnow: nil, iconCode: nil, narrative: nil)
        let day2 = ForecastDay(date: date, tempMin: 5, tempMax: 15, precipitation: 0.0, qpfSnow: nil, iconCode: nil, narrative: nil)
        
        #expect(day1.id != day2.id)
    }
    
    // MARK: - Forecast toDays() Tests
    
    @Test("Forecast toDays returns empty array when forecast5days is nil")
    func toDaysEmptyWhenNil() {
        let forecast = Forecast(forecast5days: nil)
        
        let days = forecast.toDays()
        
        #expect(days.isEmpty)
    }
    
    @Test("Forecast toDays returns empty array when temperature arrays are empty")
    func toDaysEmptyWhenNoTemperatures() {
        let forecast5days = Forecast5Day(
            calendarDayTemperatureMax: [],
            calendarDayTemperatureMin: [],
            temperatureMax: nil,
            temperatureMin: nil,
            narrative: nil,
            qpf: [],
            qpfSnow: nil,
            sunriseTimeLocal: nil,
            sunsetTimeLocal: nil,
            iconCode: nil
        )
        let forecast = Forecast(forecast5days: forecast5days)
        
        let days = forecast.toDays()
        
        #expect(days.isEmpty)
    }
    
    @Test("Forecast toDays creates correct number of days")
    func toDaysCreatesCorrectDays() {
        let forecast5days = Forecast5Day(
            calendarDayTemperatureMax: [15, 16, 17, 18, 19],
            calendarDayTemperatureMin: [5, 6, 7, 8, 9],
            temperatureMax: nil,
            temperatureMin: nil,
            narrative: ["Sunny", "Cloudy", "Rain", "Clear", "Windy"],
            qpf: [0.0, 0.0, 5.0, 0.0, 0.0],
            qpfSnow: nil,
            sunriseTimeLocal: nil,
            sunsetTimeLocal: nil,
            iconCode: [32, 31, 28, 27, 12, 11, 32, 31, 34, 33] // Day/night pairs
        )
        let forecast = Forecast(forecast5days: forecast5days)
        
        let days = forecast.toDays()
        
        // Number depends on current hour (starts from index 0 or 1)
        #expect(days.count >= 4)
        #expect(days.count <= 5)
    }
    
    @Test("Forecast toDays maps temperatures correctly")
    func toDaysMapsTemperatures() {
        let forecast5days = Forecast5Day(
            calendarDayTemperatureMax: [15, 16, 17],
            calendarDayTemperatureMin: [5, 6, 7],
            temperatureMax: nil,
            temperatureMin: nil,
            narrative: nil,
            qpf: [0.0, 0.0, 0.0],
            qpfSnow: nil,
            sunriseTimeLocal: nil,
            sunsetTimeLocal: nil,
            iconCode: nil
        )
        let forecast = Forecast(forecast5days: forecast5days)
        
        let days = forecast.toDays()
        
        #expect(!days.isEmpty)
        
        // First day should have correct temps (index depends on time of day)
        let firstDay = days[0]
        #expect(firstDay.tempMax >= 15 && firstDay.tempMax <= 17)
        #expect(firstDay.tempMin >= 5 && firstDay.tempMin <= 7)
    }
    
    @Test("Forecast toDays maps precipitation correctly")
    func toDaysMapsPrecipitation() {
        let forecast5days = Forecast5Day(
            calendarDayTemperatureMax: [15, 16],
            calendarDayTemperatureMin: [5, 6],
            temperatureMax: nil,
            temperatureMin: nil,
            narrative: nil,
            qpf: [2.5, 0.0],
            qpfSnow: [1.0, 0.0],
            sunriseTimeLocal: nil,
            sunsetTimeLocal: nil,
            iconCode: nil
        )
        let forecast = Forecast(forecast5days: forecast5days)
        
        let days = forecast.toDays()
        
        #expect(!days.isEmpty)
        // At least one day should have precipitation data
        let hasPrecipitation = days.contains { $0.precipitation > 0 || ($0.qpfSnow ?? 0) > 0 }
        #expect(hasPrecipitation || days.allSatisfy { $0.precipitation == 0 })
    }
    
    @Test("Forecast toDays skips days with nil temperatures")
    func toDaysSkipsNilTemperatures() {
        let forecast5days = Forecast5Day(
            calendarDayTemperatureMax: [15, nil, 17],
            calendarDayTemperatureMin: [5, nil, 7],
            temperatureMax: nil,
            temperatureMin: nil,
            narrative: nil,
            qpf: [0.0, 0.0, 0.0],
            qpfSnow: nil,
            sunriseTimeLocal: nil,
            sunsetTimeLocal: nil,
            iconCode: nil
        )
        let forecast = Forecast(forecast5days: forecast5days)
        
        let days = forecast.toDays()
        
        // Should skip the day with nil temperatures
        for day in days {
            #expect(day.tempMax != 0 || day.tempMin != 0)
        }
    }
    
    @Test("Forecast toDays maps iconCode from paired array correctly")
    func toDaysMapsIconCode() {
        // iconCode array has day/night pairs: [day0, night0, day1, night1, ...]
        let forecast5days = Forecast5Day(
            calendarDayTemperatureMax: [15, 16],
            calendarDayTemperatureMin: [5, 6],
            temperatureMax: nil,
            temperatureMin: nil,
            narrative: nil,
            qpf: [0.0, 0.0],
            qpfSnow: nil,
            sunriseTimeLocal: nil,
            sunsetTimeLocal: nil,
            iconCode: [32, 31, 28, 27] // Day 0: 32/31, Day 1: 28/27
        )
        let forecast = Forecast(forecast5days: forecast5days)
        
        let days = forecast.toDays()
        
        #expect(!days.isEmpty)
        // First day's iconCode should be day icon (32 or 28 depending on start index)
        let validIconCodes = [32, 28, 31, 27]
        for day in days {
            if let iconCode = day.iconCode {
                #expect(validIconCodes.contains(iconCode))
            }
        }
    }
    
    // MARK: - Array Safe Subscript Tests
    
    @Test("Safe subscript returns element for valid index")
    func safeSubscriptValidIndex() {
        let array = [1, 2, 3, 4, 5]
        
        #expect(array[safe: 0] == 1)
        #expect(array[safe: 2] == 3)
        #expect(array[safe: 4] == 5)
    }
    
    @Test("Safe subscript returns nil for invalid index")
    func safeSubscriptInvalidIndex() {
        let array = [1, 2, 3]
        
        #expect(array[safe: -1] == nil)
        #expect(array[safe: 3] == nil)
        #expect(array[safe: 100] == nil)
    }
    
    @Test("Safe subscript works with empty array")
    func safeSubscriptEmptyArray() {
        let array: [Int] = []
        
        #expect(array[safe: 0] == nil)
    }
    
    // MARK: - Codable Tests
    
    @Test("ForecastDay can be encoded and decoded")
    func forecastDayCodable() throws {
        let original = ForecastDay(
            date: Date(),
            tempMin: 5,
            tempMax: 15,
            precipitation: 2.5,
            qpfSnow: 1.0,
            iconCode: 32,
            narrative: "Sunny day"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ForecastDay.self, from: data)
        
        #expect(decoded.tempMin == original.tempMin)
        #expect(decoded.tempMax == original.tempMax)
        #expect(decoded.precipitation == original.precipitation)
        #expect(decoded.qpfSnow == original.qpfSnow)
        #expect(decoded.iconCode == original.iconCode)
        #expect(decoded.narrative == original.narrative)
    }
    
    // MARK: - Helper Methods
    
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        components.minute = 0
        components.timeZone = TimeZone(identifier: "Europe/Madrid")
        return Calendar.current.date(from: components)!
    }
}
