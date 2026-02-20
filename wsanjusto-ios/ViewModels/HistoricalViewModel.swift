//
//  HistoricalViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import Observation

@MainActor
@Observable
final class HistoricalViewModel {
    private static let measureLimit = 100
    
    private let repository: MeasureRepository
    
    var measures = [Measure]()
    
    init(repository: MeasureRepository = FirebaseMeasureRepository()) {
        self.repository = repository
    }

    func fetchData() {
        Task {
            measures = await repository.fetchMeasures(limit: Self.measureLimit)
        }
    }
    
    func setMeasures(_ measures: [Measure]) {
        self.measures = measures
    }
}
