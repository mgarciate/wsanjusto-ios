//
//  DashboardDataTests.swift
//  wsanjusto-iosTests
//
//  Created by Claude Code on 20/02/2026.
//

import Foundation
import Testing
@testable import wsanjusto_ios

struct DashboardDataTests {
    
    // MARK: - Codable Tests
    
    @Test("DashboardData can be encoded and decoded")
    func codableConformance() throws {
        let measure = createMeasure()
        let forecast = Forecast(forecast5days: createForecast5Day())
        let dashboardData = DashboardData(current: measure, forecast: forecast)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(dashboardData)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DashboardData.self, from: data)
        
        #expect(decoded.current?.sensorTemperature1 == measure.sensorTemperature1)
        #expect(decoded.forecast != nil)
    }
    
    @Test("DashboardData handles nil current")
    func handlesNilCurrent() throws {
        let forecast = Forecast(forecast5days: createForecast5Day())
        let dashboardData = DashboardData(current: nil, forecast: forecast)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(dashboardData)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DashboardData.self, from: data)
        
        #expect(decoded.current == nil)
        #expect(decoded.forecast != nil)
    }
    
    @Test("DashboardData handles nil forecast")
    func handlesNilForecast() throws {
        let measure = createMeasure()
        let dashboardData = DashboardData(current: measure, forecast: nil)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(dashboardData)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DashboardData.self, from: data)
        
        #expect(decoded.current != nil)
        #expect(decoded.forecast == nil)
    }
    
    @Test("DashboardData handles both nil")
    func handlesBothNil() throws {
        let dashboardData = DashboardData(current: nil, forecast: nil)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(dashboardData)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DashboardData.self, from: data)
        
        #expect(decoded.current == nil)
        #expect(decoded.forecast == nil)
    }
    
    @Test("DashboardData preserves all measure fields")
    func preservesMeasureFields() throws {
        let measure = createMeasure(
            sensorTemperature1: 25.5,
            sensorHumidity1: 65.0,
            iconCode: 32,
            sunriseTimeLocal: "2026-02-20T07:30:00+0100",
            sunsetTimeLocal: "2026-02-20T18:30:00+0100"
        )
        let dashboardData = DashboardData(current: measure, forecast: nil)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(dashboardData)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DashboardData.self, from: data)
        
        #expect(decoded.current?.sensorTemperature1 == 25.5)
        #expect(decoded.current?.sensorHumidity1 == 65.0)
        #expect(decoded.current?.iconCode == 32)
        #expect(decoded.current?.sunriseTimeLocal == "2026-02-20T07:30:00+0100")
        #expect(decoded.current?.sunsetTimeLocal == "2026-02-20T18:30:00+0100")
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
    
    private func createForecast5Day() -> Forecast5Day {
        Forecast5Day(
            calendarDayTemperatureMax: [15, 18, 20],
            calendarDayTemperatureMin: [5, 8, 10],
            temperatureMax: [15, 18, 20],
            temperatureMin: [5, 8, 10],
            narrative: ["Sunny", "Cloudy", "Rain"],
            qpf: [0.0, 2.5, 5.0],
            qpfSnow: [0.0, 0.0, 1.0],
            sunriseTimeLocal: ["07:30", "07:29", "07:28"],
            sunsetTimeLocal: ["18:30", "18:31", "18:32"],
            iconCode: [32, 26, 12]
        )
    }
}
