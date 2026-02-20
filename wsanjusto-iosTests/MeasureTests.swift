//
//  MeasureTests.swift
//  wsanjusto-iosTests
//
//  Created by Claude Code on 19/02/2026.
//

import Foundation
import Testing
@testable import wsanjusto_ios

struct MeasureTests {
    
    // MARK: - Date String Formatting Tests
    
    @Test("dateString formats date correctly")
    func dateStringFormat() {
        // Given: A measure with a known timestamp (Feb 19, 2026 12:30:00 UTC)
        let timestamp = 1771503000 // This is approximately 2026-02-19 12:30:00 UTC
        let measure = createMeasure(createdAt: timestamp)
        
        // Then: dateString should be formatted as dd/MM/yyyy HH:mm
        let dateString = measure.dateString
        #expect(dateString.contains("/"))
        #expect(dateString.count == 16) // "dd/MM/yyyy HH:mm" = 16 chars
    }
    
    @Test("shortDateString formats date correctly")
    func shortDateStringFormat() {
        // Given: A measure with a known timestamp
        let timestamp = 1771503000
        let measure = createMeasure(createdAt: timestamp)
        
        // Then: shortDateString should be formatted as dd/MM/yy
        let shortDate = measure.shortDateString
        #expect(shortDate.contains("/"))
        #expect(shortDate.count == 8) // "dd/MM/yy" = 8 chars
    }
    
    @Test("shortTimeString formats time correctly")
    func shortTimeStringFormat() {
        // Given: A measure with a known timestamp
        let timestamp = 1771503000
        let measure = createMeasure(createdAt: timestamp)
        
        // Then: shortTimeString should be formatted as HH:mm
        let timeString = measure.shortTimeString
        #expect(timeString.contains(":"))
        #expect(timeString.count == 5) // "HH:mm" = 5 chars
    }
    
    @Test("lastUpdateString formats with Spanish locale")
    func lastUpdateStringSpanishLocale() {
        // Given: A measure with a known timestamp
        let timestamp = 1771503000
        let measure = createMeasure(createdAt: timestamp)
        
        // Then: lastUpdateString should contain Spanish day names
        let updateString = measure.lastUpdateString
        #expect(!updateString.isEmpty)
        // Should contain comma and space (format: "EEEE, dd MMMM HH:mm")
        #expect(updateString.contains(","))
    }
    
    // MARK: - Dummy Data Tests
    
    @Test("dummyData returns valid measure")
    func dummyDataIsValid() {
        let dummyMeasures = Measure.dummyData
        
        #expect(!dummyMeasures.isEmpty)
        #expect(dummyMeasures.count == 1)
        
        let dummy = dummyMeasures[0]
        #expect(dummy.createdAt == 0)
        #expect(dummy.sensorTemperature1 == 0)
        #expect(dummy.sensorHumidity1 == 0)
    }
    
    // MARK: - Identifiable Conformance
    
    @Test("Each measure has unique ID")
    func uniqueIdentifiers() {
        let measure1 = createMeasure(createdAt: 100)
        let measure2 = createMeasure(createdAt: 100)
        
        // Even with same data, IDs should be unique
        #expect(measure1.id != measure2.id)
    }
    
    // MARK: - Codable Conformance
    
    @Test("Measure can be encoded and decoded")
    func codableConformance() throws {
        // Given: A measure with all fields
        let original = createMeasure(
            createdAt: 1771503000,
            sensorTemperature1: 22.5,
            sensorHumidity1: 65.0
        )
        
        // When: Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Measure.self, from: data)
        
        // Then: Values should match (except ID which is generated)
        #expect(decoded.createdAt == original.createdAt)
        #expect(decoded.sensorTemperature1 == original.sensorTemperature1)
        #expect(decoded.sensorHumidity1 == original.sensorHumidity1)
        #expect(decoded.realFeel == original.realFeel)
        #expect(decoded.pressure1 == original.pressure1)
    }
    
    @Test("Measure decodes with optional fields as nil")
    func decodesWithNilOptionals() throws {
        // Given: JSON with minimal required fields
        let json = """
        {
            "createdAt": 1771503000,
            "indexArduino": 0,
            "orderByDate": 0,
            "realFeel": 20.0,
            "sensorHumidity1": 50.0,
            "sensorTemperature1": 22.0,
            "sensorTemperature2": 21.0,
            "pressure1": 1013.0,
            "uid": 1
        }
        """.data(using: .utf8)!
        
        // When: Decode
        let decoder = JSONDecoder()
        let measure = try decoder.decode(Measure.self, from: json)
        
        // Then: Optional fields should be nil
        #expect(measure.dewpoint == nil)
        #expect(measure.precipTotal == nil)
        #expect(measure.uv == nil)
        #expect(measure.windSpeed == nil)
        #expect(measure.iconCode == nil)
        #expect(measure.sunriseTimeLocal == nil)
        #expect(measure.sunsetTimeLocal == nil)
    }
    
    // MARK: - Helper Methods
    
    private func createMeasure(
        createdAt: Int = 0,
        sensorTemperature1: Double = 20.0,
        sensorHumidity1: Double = 50.0
    ) -> Measure {
        Measure(
            createdAt: createdAt,
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
            iconCode: nil,
            shortPhrase: nil,
            sunriseTimeLocal: nil,
            sunsetTimeLocal: nil
        )
    }
}
