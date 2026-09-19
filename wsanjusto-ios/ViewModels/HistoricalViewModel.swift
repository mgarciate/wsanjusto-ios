import Foundation
import FirebaseDatabase

struct HistoricalPageCursor: Equatable, Sendable {
    let orderByDate: Int
    let key: String
}

struct HistoricalPage: Sendable {
    let measures: [Measure]
    let nextCursor: HistoricalPageCursor?
    let hasMore: Bool
}

protocol HistoricalMeasuresLoading: Sendable {
    func fetchPage(
        limit: UInt,
        after cursor: HistoricalPageCursor?
    ) async throws -> HistoricalPage
}

struct FirebaseHistoricalMeasuresLoader: HistoricalMeasuresLoading {
    func fetchPage(
        limit: UInt,
        after cursor: HistoricalPageCursor?
    ) async throws -> HistoricalPage {
        try await withCheckedThrowingContinuation { continuation in
            let orderedQuery = Database.database()
                .reference()
                .child("measures")
                .queryOrdered(byChild: "orderByDate")
            let paginatedQuery: DatabaseQuery
            if let cursor {
                paginatedQuery = orderedQuery.queryStarting(
                    afterValue: cursor.orderByDate,
                    childKey: cursor.key
                )
            } else {
                paginatedQuery = orderedQuery
            }

            paginatedQuery
                .queryLimited(toFirst: limit + 1)
                .observeSingleEvent(
                    of: .value,
                    with: { snapshot in
                        let snapshots = snapshot.children.compactMap {
                            $0 as? DataSnapshot
                        }
                        let pageSnapshots = Array(snapshots.prefix(Int(limit)))
                        let measures = pageSnapshots.compactMap {
                            Measure.build(with: $0)
                        }
                        let nextCursor: HistoricalPageCursor? = pageSnapshots.last.flatMap { snapshot in
                            guard let value = snapshot.value as? [String: Any],
                                  let orderByDate = value["orderByDate"] as? Int else {
                                return nil
                            }
                            return HistoricalPageCursor(
                                orderByDate: orderByDate,
                                key: snapshot.key
                            )
                        }
                        continuation.resume(
                            returning: HistoricalPage(
                                measures: measures,
                                nextCursor: nextCursor,
                                hasMore: snapshots.count > Int(limit)
                            )
                        )
                    },
                    withCancel: { error in
                        continuation.resume(throwing: error)
                    }
                )
        }
    }
}

struct UITestHistoricalMeasuresLoader: HistoricalMeasuresLoading {
    enum LoaderError: Error {
        case expected
    }

    let scenario: UITestScenario

    func fetchPage(
        limit: UInt,
        after cursor: HistoricalPageCursor?
    ) async throws -> HistoricalPage {
        switch scenario {
        case .success:
            let startIndex = cursor.flatMap { Int($0.key) }.map { $0 + 1 } ?? 0
            let allMeasures = Self.fixtureMeasures
            let endIndex = min(startIndex + Int(limit), allMeasures.count)
            let measures = startIndex < endIndex
                ? Array(allMeasures[startIndex..<endIndex])
                : []
            let nextIndex = endIndex - 1
            let nextCursor = measures.isEmpty
                ? nil
                : HistoricalPageCursor(
                    orderByDate: measures[measures.count - 1].orderByDate,
                    key: String(nextIndex)
                )
            return HistoricalPage(
                measures: measures,
                nextCursor: nextCursor,
                hasMore: endIndex < allMeasures.count
            )
        case .empty:
            return HistoricalPage(measures: [], nextCursor: nil, hasMore: false)
        case .error:
            throw LoaderError.expected
        }
    }

    private static let fixtureMeasures: [Measure] = (0..<75).map { index in
        Measure(
            createdAt: 1_800_000_000 - (index * 3_600),
            indexArduino: index,
            orderByDate: index,
            realFeel: 18.5,
            sensorHumidity1: 62,
            sensorTemperature1: 19.5,
            sensorTemperature2: 19,
            pressure1: 1_018,
            uid: index + 1,
            dewpoint: 11,
            precipTotal: 1.25,
            uv: 3,
            windSpeed: 8,
            windGust: 14,
            windDir: 270,
            airQualityIndex: 24,
            airQualityCategory: "Buena",
            villamecaActual: 9.35,
            villamecaWeeklyVolumeVariation: 0.4,
            villamecaLastYear: 8.5,
            iconCode: 32,
            shortPhrase: "Despejado",
            sunriseTimeLocal: nil,
            sunsetTimeLocal: nil
        )
    }
}

@MainActor
final class HistoricalViewModel: ObservableObject {
    static let pageSize: UInt = 50

    @Published private(set) var measures = [Measure]()
    @Published private(set) var loadingState: MeasuresLoadingState = .idle
    @Published private(set) var isLoadingPage = false
    @Published private(set) var pageLoadFailed = false
    @Published private(set) var hasMore = true

    var isLoading: Bool {
        loadingState == .loading || isLoadingPage
    }

    private let loader: any HistoricalMeasuresLoading
    private var nextCursor: HistoricalPageCursor?
    private var fetchTask: Task<Void, Never>?

    init(loader: any HistoricalMeasuresLoading = FirebaseHistoricalMeasuresLoader()) {
        self.loader = loader
    }

    @discardableResult
    func fetchData() -> Task<Void, Never> {
        fetchTask?.cancel()
        measures = []
        nextCursor = nil
        hasMore = true
        pageLoadFailed = false
        isLoadingPage = false
        loadingState = .loading

        let task = makePageTask(isInitialPage: true, cursor: nil)
        fetchTask = task
        return task
    }

    @discardableResult
    func loadNextPage() -> Task<Void, Never>? {
        guard loadingState == .loaded, hasMore, !isLoadingPage else {
            return nil
        }

        pageLoadFailed = false
        isLoadingPage = true
        let task = makePageTask(isInitialPage: false, cursor: nextCursor)
        fetchTask = task
        return task
    }

    private func makePageTask(
        isInitialPage: Bool,
        cursor: HistoricalPageCursor?
    ) -> Task<Void, Never> {
        Task { @MainActor [weak self, loader] in
            do {
                let page = try await loader.fetchPage(
                    limit: Self.pageSize,
                    after: cursor
                )
                try Task.checkCancellation()
                self?.apply(page: page, isInitialPage: isInitialPage)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                self?.applyFailure(isInitialPage: isInitialPage)
            }
        }
    }

    private func apply(page: HistoricalPage, isInitialPage: Bool) {
        var loadedUIDs = isInitialPage ? Set<Int>() : Set(measures.map(\.uid))
        let uniqueMeasures = page.measures.filter {
            loadedUIDs.insert($0.uid).inserted
        }
        if isInitialPage {
            measures = uniqueMeasures
        } else {
            measures.append(contentsOf: uniqueMeasures)
        }

        nextCursor = page.nextCursor
        hasMore = page.hasMore && page.nextCursor != nil
        isLoadingPage = false
        pageLoadFailed = false
        loadingState = measures.isEmpty ? .empty : .loaded
    }

    private func applyFailure(isInitialPage: Bool) {
        isLoadingPage = false
        if isInitialPage {
            measures = []
            hasMore = false
            loadingState = .failed
        } else {
            pageLoadFailed = true
        }
    }
}
