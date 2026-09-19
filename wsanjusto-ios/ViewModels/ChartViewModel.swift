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

enum ChartMetric: String, CaseIterable, Identifiable, Sendable {
    case temperature
    case windSpeed
    case precipitation

    var id: Self { self }

    var title: String {
        switch self {
        case .temperature:
            "Temperatura"
        case .windSpeed:
            "Viento"
        case .precipitation:
            "Precipitación"
        }
    }

    var unit: String {
        switch self {
        case .temperature:
            "°C"
        case .windSpeed:
            "km/h"
        case .precipitation:
            "mm"
        }
    }

    func value(from measure: Measure) -> Double? {
        let value: Double?
        switch self {
        case .temperature:
            value = measure.sensorTemperature1
        case .windSpeed:
            value = measure.windSpeed
        case .precipitation:
            value = measure.precipTotal
        }

        guard let value, value.isFinite else { return nil }
        guard self == .temperature || value >= 0 else { return nil }
        return value
    }

    func formattedValue(_ value: Double?) -> String {
        guard let value else { return "- \(unit)" }
        return String(format: "%.2f %@", value, unit)
    }
}

struct ChartDataPoint: Identifiable, Sendable {
    let measure: Measure
    let date: Date
    let value: Double
    let displayedWindDirection: Int?

    var id: UUID { measure.id }
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
class MeasuresLoadingViewModel: ObservableObject {
    @Published var measures = [Measure]()
    @Published private(set) var loadingState: MeasuresLoadingState = .idle
    var isLoading: Bool { loadingState == .loading }

    private let measuresLoader: any MeasuresLoading
    private var fetchTask: Task<Void, Never>?

    init(measuresLoader: any MeasuresLoading = FirebaseMeasuresLoader()) {
        self.measuresLoader = measuresLoader
    }

    @discardableResult
    func fetchMeasures(limit: UInt) -> Task<Void, Never> {
        fetchTask?.cancel()
        prepareForFetch()
        loadingState = .loading

        let task = Task { @MainActor [weak self, measuresLoader] in
            do {
                let measures = try await measuresLoader.fetchMeasures(limit: limit)
                try Task.checkCancellation()
                self?.apply(measures: measures)
                self?.loadingState = measures.isEmpty ? .empty : .loaded
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                self?.apply(measures: [])
                self?.loadingState = .failed
            }
        }
        fetchTask = task
        return task
    }

    func prepareForFetch() {}

    func apply(measures: [Measure]) {
        self.measures = measures
    }
}

@MainActor
final class ChartViewModel: MeasuresLoadingViewModel {
    private static let defaultDate = "-"
    private static let calmWindSpeedThreshold = 0.5
    @Published private var selectedMeasure: Measure?
    @Published var selectedMetric: ChartMetric = .temperature {
        didSet {
            guard selectedMetric != oldValue else { return }
            clear()
        }
    }

    var selectedDate: String {
        selectedMeasure?.dateString ?? ChartViewModel.defaultDate
    }

    var selectedValue: String {
        selectedMetric.formattedValue(
            selectedMeasure.flatMap(selectedMetric.value(from:))
        )
    }

    var chartData: [ChartDataPoint] {
        measures.compactMap { measure in
            guard let value = selectedMetric.value(from: measure) else { return nil }
            return ChartDataPoint(
                measure: measure,
                date: Date(timeIntervalSince1970: TimeInterval(measure.createdAt)),
                value: value,
                displayedWindDirection: displayedWindDirection(for: measure, value: value)
            )
        }
        .sorted { $0.measure.createdAt < $1.measure.createdAt }
    }

    private func displayedWindDirection(for measure: Measure, value: Double) -> Int? {
        guard selectedMetric == .windSpeed,
              value > Self.calmWindSpeedThreshold,
              let windDirection = measure.windDir,
              (0...360).contains(windDirection) else {
            return nil
        }
        return windDirection % 360
    }

    var chartDomain: ClosedRange<Double> {
        let values = chartData.map(\.value)

        switch selectedMetric {
        case .temperature:
            return ((values.min() ?? 0) - 2)...((values.max() ?? 50) + 2)
        case .windSpeed, .precipitation:
            let maximum = values.max() ?? 0
            return 0...(maximum + max(maximum * 0.1, 1))
        }
    }

    @discardableResult
    func fetchData() -> Task<Void, Never> {
        fetchMeasures(limit: 150)
    }

    override func prepareForFetch() {
        clear()
    }

    override func apply(measures: [Measure]) {
        update(measures: measures)
    }

    func update(measures: [Measure]) {
        super.apply(measures: measures)
    }

    func select(measure: Measure) {
        guard selectedMetric.value(from: measure) != nil else {
            clear()
            return
        }
        selectedMeasure = measure
    }

    func closestDataPoint(to date: Date) -> ChartDataPoint? {
        let timestamp = date.timeIntervalSince1970
        return chartData.min {
            abs(TimeInterval($0.measure.createdAt) - timestamp)
                < abs(TimeInterval($1.measure.createdAt) - timestamp)
        }
    }
    
    func clear() {
        selectedMeasure = nil
    }

}
