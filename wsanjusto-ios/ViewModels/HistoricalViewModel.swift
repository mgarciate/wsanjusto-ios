import Foundation

@MainActor
class HistoricalViewModel: ObservableObject {
    @Published var measures = [Measure]()
    @Published private(set) var loadingState: MeasuresLoadingState = .idle
    var isLoading: Bool { loadingState == .loading }
    private let measuresLoader: any MeasuresLoading
    private var fetchTask: Task<Void, Never>?

    init(measuresLoader: any MeasuresLoading = FirebaseMeasuresLoader()) {
        self.measuresLoader = measuresLoader
    }

    func fetchData() {
        fetchTask?.cancel()
        loadingState = .loading
        fetchTask = Task { @MainActor [weak self, measuresLoader] in
            do {
                let measures = try await measuresLoader.fetchMeasures(limit: 100)
                try Task.checkCancellation()
                self?.measures = measures
                self?.loadingState = measures.isEmpty ? .empty : .loaded
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                self?.measures = []
                self?.loadingState = .failed
            }
        }
    }
}
