import Foundation

class HistoricalViewModel: ObservableObject {
    @Published var measures = [Measure]()
    @Published private(set) var loadingState: MeasuresLoadingState = .idle
    var isLoading: Bool { loadingState == .loading }
    private let measuresLoader: any MeasuresLoading

    init(measuresLoader: any MeasuresLoading = FirebaseMeasuresLoader()) {
        self.measuresLoader = measuresLoader
    }

    func fetchData() {
        loadingState = .loading
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                measures = try await measuresLoader.fetchMeasures(limit: 100)
                loadingState = measures.isEmpty ? .empty : .loaded
            } catch {
                measures = []
                loadingState = .failed
            }
        }
    }
}
