import Foundation

class HistoricalViewModel: ObservableObject {
    @Published var measures = [Measure]()
    @Published var isLoading = false
    private let measuresLoader: any MeasuresLoading

    init(measuresLoader: any MeasuresLoading = FirebaseMeasuresLoader()) {
        self.measuresLoader = measuresLoader
    }

    func fetchData() {
        isLoading = true
        Task { @MainActor [weak self] in
            guard let self else { return }
            defer { isLoading = false }
            do {
                measures = try await measuresLoader.fetchMeasures(limit: 100)
            } catch {
                measures = []
            }
        }
    }
}
