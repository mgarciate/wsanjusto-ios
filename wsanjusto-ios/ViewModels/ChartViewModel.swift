//
//  ChartViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import Foundation
import FirebaseDatabase

protocol MeasuresLoading {
    func fetchMeasures(limit: UInt) async throws -> [Measure]
}

struct FirebaseMeasuresLoader: MeasuresLoading {
    func fetchMeasures(limit: UInt) async throws -> [Measure] {
        try await withCheckedThrowingContinuation { continuation in
            Database.database()
                .reference()
                .child("measures")
                .queryOrdered(byChild: "orderByDate")
                .queryLimited(toFirst: limit)
                .observeSingleEvent(
                    of: .value,
                    with: { snapshot in
                        let measures = snapshot.children.compactMap { child in
                            Measure.build(with: child as? DataSnapshot)
                        }
                        continuation.resume(returning: measures)
                    },
                    withCancel: { error in
                        continuation.resume(throwing: error)
                    }
                )
        }
    }
}

class ChartViewModel: ObservableObject {
    private static let defaultDate = "-"
    private static let defaultTemperature = "- ºC"
    @Published var measures = [Measure]()
    @Published var isLoading = false
    @Published var selectedDate: String = ChartViewModel.defaultDate
    @Published var selectedTemperature: String = ChartViewModel.defaultTemperature
    var domainMeasuresFrom: Double = 0.0
    var domainMeasuresTo: Double = 0.0
    private let measuresLoader: any MeasuresLoading

    init(measuresLoader: any MeasuresLoading = FirebaseMeasuresLoader()) {
        self.measuresLoader = measuresLoader
    }

    func fetchData() {
        clear()
        isLoading = true
        Task { @MainActor [weak self] in
            guard let self else { return }
            defer { isLoading = false }
            do {
                update(measures: try await measuresLoader.fetchMeasures(limit: 150))
            } catch {
                update(measures: [])
            }
        }
    }
    
    func update(measures: [Measure]) {
        self.measures = measures
        domainMeasuresFrom = (measures.map(\.sensorTemperature1).min() ?? 0) - 2
        domainMeasuresTo = (measures.map(\.sensorTemperature1).max() ?? 50) + 2
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
