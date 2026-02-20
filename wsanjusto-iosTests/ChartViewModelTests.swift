//
//  ChartViewModelTests.swift
//  wsanjusto-iosTests
//
//  Created by Claude Code on 19/02/2026.
//

import Foundation
import Testing
@testable import wsanjusto_ios

@MainActor
struct ChartViewModelTests {
    
    // MARK: - Initial State Tests
    
    @Test("Initial state has default values")
    func initialState() async {
        let viewModel = ChartViewModel()
        
        #expect(viewModel.measures.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.selectedDate == "-")
        #expect(viewModel.selectedTemperature == "- ºC")
        #expect(viewModel.domainMeasuresFrom == 0.0)
        #expect(viewModel.domainMeasuresTo == 0.0)
    }
    
    // MARK: - Select Measure Tests
    
    @Test("Selecting a measure updates selectedDate and selectedTemperature")
    func selectMeasure() async {
        let viewModel = ChartViewModel()
        let measure = createMeasure(
            createdAt: 1771503000, // Known timestamp
            sensorTemperature1: 22.5
        )
        
        viewModel.select(measure: measure)
        
        #expect(viewModel.selectedTemperature == "22.50 °C")
        #expect(!viewModel.selectedDate.isEmpty)
        #expect(viewModel.selectedDate != "-")
    }
    
    @Test("Selecting different measures updates values correctly")
    func selectDifferentMeasures() async {
        let viewModel = ChartViewModel()
        
        let measure1 = createMeasure(sensorTemperature1: 15.0)
        let measure2 = createMeasure(sensorTemperature1: 30.5)
        
        viewModel.select(measure: measure1)
        #expect(viewModel.selectedTemperature == "15.00 °C")
        
        viewModel.select(measure: measure2)
        #expect(viewModel.selectedTemperature == "30.50 °C")
    }
    
    @Test("Selected temperature formats with 2 decimal places")
    func temperatureFormatting() async {
        let viewModel = ChartViewModel()
        
        let measure = createMeasure(sensorTemperature1: 18.123456)
        viewModel.select(measure: measure)
        
        #expect(viewModel.selectedTemperature == "18.12 °C")
    }
    
    // MARK: - Clear Tests
    
    @Test("Clear resets selectedDate and selectedTemperature to defaults")
    func clearResetsToDefaults() async {
        let viewModel = ChartViewModel()
        let measure = createMeasure(sensorTemperature1: 25.0)
        
        viewModel.select(measure: measure)
        #expect(viewModel.selectedTemperature != "- ºC")
        
        viewModel.clear()
        
        #expect(viewModel.selectedDate == "-")
        #expect(viewModel.selectedTemperature == "- ºC")
    }
    
    // MARK: - Domain Calculation Tests
    
    @Test("Domain is calculated correctly from measures")
    func domainCalculation() async {
        let viewModel = ChartViewModel()
        let measures = [
            createMeasure(sensorTemperature1: 10.0),
            createMeasure(sensorTemperature1: 20.0),
            createMeasure(sensorTemperature1: 15.0)
        ]
        
        viewModel.setMeasures(measures)
        
        // Min is 10, so domainFrom = 10 - 2 = 8
        // Max is 20, so domainTo = 20 + 2 = 22
        #expect(viewModel.domainMeasuresFrom == 8.0)
        #expect(viewModel.domainMeasuresTo == 22.0)
    }
    
    @Test("Domain with single measure")
    func domainWithSingleMeasure() async {
        let viewModel = ChartViewModel()
        let measures = [createMeasure(sensorTemperature1: 25.0)]
        
        viewModel.setMeasures(measures)
        
        #expect(viewModel.domainMeasuresFrom == 23.0) // 25 - 2
        #expect(viewModel.domainMeasuresTo == 27.0)   // 25 + 2
    }
    
    @Test("Domain with negative temperatures")
    func domainWithNegativeTemperatures() async {
        let viewModel = ChartViewModel()
        let measures = [
            createMeasure(sensorTemperature1: -5.0),
            createMeasure(sensorTemperature1: 5.0)
        ]
        
        viewModel.setMeasures(measures)
        
        #expect(viewModel.domainMeasuresFrom == -7.0) // -5 - 2
        #expect(viewModel.domainMeasuresTo == 7.0)    // 5 + 2
    }
    
    @Test("Domain with empty measures uses defaults")
    func domainWithEmptyMeasures() async {
        let viewModel = ChartViewModel()
        
        viewModel.setMeasures([])
        
        // Default: min = 0 - 2 = -2, max = 50 + 2 = 52
        #expect(viewModel.domainMeasuresFrom == -2.0)
        #expect(viewModel.domainMeasuresTo == 52.0)
    }
    
    // MARK: - Measures Storage Tests
    
    @Test("Setting measures updates the measures array")
    func settingMeasures() async {
        let viewModel = ChartViewModel()
        let measures = [
            createMeasure(sensorTemperature1: 10.0),
            createMeasure(sensorTemperature1: 20.0)
        ]
        
        viewModel.setMeasures(measures)
        
        #expect(viewModel.measures.count == 2)
    }
    
    // MARK: - Helper Methods
    
    private func createMeasure(
        createdAt: Int = Int(Date().timeIntervalSince1970),
        sensorTemperature1: Double = 20.0
    ) -> Measure {
        Measure(
            createdAt: createdAt,
            indexArduino: 0,
            orderByDate: -createdAt,
            realFeel: sensorTemperature1,
            sensorHumidity1: 50.0,
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
