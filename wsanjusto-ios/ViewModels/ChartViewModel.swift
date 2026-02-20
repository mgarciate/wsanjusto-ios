//
//  ChartViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import Foundation
import Observation

@MainActor
@Observable
final class ChartViewModel {
    private static let defaultDate = "-"
    private static let defaultTemperature = "- ºC"
    private static let measureLimit = 150
    
    private let repository: MeasureRepository
    
    var measures = [Measure]()
    var isLoading = false
    var selectedDate: String = ChartViewModel.defaultDate
    var selectedTemperature: String = ChartViewModel.defaultTemperature
    var domainMeasuresFrom: Double = 0.0
    var domainMeasuresTo: Double = 0.0
    
    init(repository: MeasureRepository = FirebaseMeasureRepository()) {
        self.repository = repository
    }
    
    func fetchData() {
        clear()
        isLoading = true
        Task {
            let fetchedMeasures = await repository.fetchMeasures(limit: Self.measureLimit)
            self.isLoading = false
            self.setMeasures(fetchedMeasures)
        }
    }
    
    func setMeasures(_ measures: [Measure]) {
        self.measures = measures
        self.domainMeasuresFrom = (measures.map { $0.sensorTemperature1 }.min() ?? 0) - 2
        self.domainMeasuresTo = (measures.map { $0.sensorTemperature1 }.max() ?? 50) + 2
    }
    
    func select(measure: Measure) {
        selectedDate = measure.dateString
        selectedTemperature = String(format: "%.2f °C", measure.sensorTemperature1)
    }
    
    func clear() {
        selectedDate = ChartViewModel.defaultDate
        selectedTemperature = ChartViewModel.defaultTemperature
    }
}
