//
//  HistoricalViewModelTests.swift
//  wsanjusto-iosTests
//
//  Created by Claude Code on 19/02/2026.
//

import Foundation
import Testing
@testable import wsanjusto_ios

@MainActor
struct HistoricalViewModelTests {
    
    // MARK: - Initial State Tests
    
    @Test("Initial state has empty measures array")
    func initialState() async {
        let viewModel = HistoricalViewModel()
        
        #expect(viewModel.measures.isEmpty)
    }
    
    // MARK: - Measures Storage Tests
    
    @Test("Setting measures updates the measures array")
    func settingMeasures() async {
        let viewModel = HistoricalViewModel()
        let measures = [
            createMeasure(sensorTemperature1: 10.0),
            createMeasure(sensorTemperature1: 20.0),
            createMeasure(sensorTemperature1: 15.0)
        ]
        
        viewModel.setMeasures(measures)
        
        #expect(viewModel.measures.count == 3)
    }
    
    @Test("Measures preserve order")
    func measuresPreserveOrder() async {
        let viewModel = HistoricalViewModel()
        let measures = [
            createMeasure(sensorTemperature1: 10.0),
            createMeasure(sensorTemperature1: 20.0),
            createMeasure(sensorTemperature1: 30.0)
        ]
        
        viewModel.setMeasures(measures)
        
        #expect(viewModel.measures[0].sensorTemperature1 == 10.0)
        #expect(viewModel.measures[1].sensorTemperature1 == 20.0)
        #expect(viewModel.measures[2].sensorTemperature1 == 30.0)
    }
    
    @Test("Setting empty measures clears the array")
    func settingEmptyMeasures() async {
        let viewModel = HistoricalViewModel()
        
        // First set some measures
        viewModel.setMeasures([
            createMeasure(sensorTemperature1: 10.0)
        ])
        #expect(viewModel.measures.count == 1)
        
        // Then clear
        viewModel.setMeasures([])
        #expect(viewModel.measures.isEmpty)
    }
    
    @Test("Measures contain all data fields")
    func measuresContainAllFields() async {
        let viewModel = HistoricalViewModel()
        let measure = createMeasure(
            createdAt: 1771503000,
            sensorTemperature1: 22.5,
            sensorHumidity1: 65.0
        )
        
        viewModel.setMeasures([measure])
        
        let storedMeasure = viewModel.measures[0]
        #expect(storedMeasure.createdAt == 1771503000)
        #expect(storedMeasure.sensorTemperature1 == 22.5)
        #expect(storedMeasure.sensorHumidity1 == 65.0)
    }
    
    @Test("Can store large number of measures")
    func canStoreManyMeasures() async {
        let viewModel = HistoricalViewModel()
        let measures = (0..<100).map { index in
            createMeasure(sensorTemperature1: Double(index))
        }
        
        viewModel.setMeasures(measures)
        
        #expect(viewModel.measures.count == 100)
    }
    
    // MARK: - Helper Methods
    
    private func createMeasure(
        createdAt: Int = Int(Date().timeIntervalSince1970),
        sensorTemperature1: Double = 20.0,
        sensorHumidity1: Double = 50.0
    ) -> Measure {
        Measure(
            createdAt: createdAt,
            indexArduino: 0,
            orderByDate: -createdAt,
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
