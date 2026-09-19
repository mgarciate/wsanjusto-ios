//
//  ChartViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import Foundation
import FirebaseDatabase

protocol MeasuresLoading: Sendable {
    func fetchMeasures(limit: UInt) async throws -> [Measure]
}

enum MeasuresLoadingState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case failed
}

struct UITestMeasuresLoader: MeasuresLoading {
    enum LoaderError: Error {
        case expected
    }

    let scenario: UITestScenario

    func fetchMeasures(limit: UInt) async throws -> [Measure] {
        switch scenario {
        case .success:
            Array(Measure.dummyData.prefix(Int(limit)))
        case .empty:
            []
        case .error:
            throw LoaderError.expected
        }
    }
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

@MainActor
class ChartViewModel: ObservableObject {
    private static let defaultDate = "-"
    private static let defaultTemperature = "- ºC"
    @Published var measures = [Measure]()
    @Published private(set) var loadingState: MeasuresLoadingState = .idle
    var isLoading: Bool { loadingState == .loading }
    @Published var selectedDate: String = ChartViewModel.defaultDate
    @Published var selectedTemperature: String = ChartViewModel.defaultTemperature
    var domainMeasuresFrom: Double = 0.0
    var domainMeasuresTo: Double = 0.0
    private let measuresLoader: any MeasuresLoading
    private var fetchTask: Task<Void, Never>?

    init(measuresLoader: any MeasuresLoading = FirebaseMeasuresLoader()) {
        self.measuresLoader = measuresLoader
    }

    @discardableResult
    func fetchData() -> Task<Void, Never> {
        fetchTask?.cancel()
        clear()
        loadingState = .loading
        let task = Task { @MainActor [weak self, measuresLoader] in
            do {
                let measures = try await measuresLoader.fetchMeasures(limit: 150)
                try Task.checkCancellation()
                self?.update(measures: measures)
                self?.loadingState = measures.isEmpty ? .empty : .loaded
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                self?.update(measures: [])
                self?.loadingState = .failed
            }
        }
        fetchTask = task
        return task
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
