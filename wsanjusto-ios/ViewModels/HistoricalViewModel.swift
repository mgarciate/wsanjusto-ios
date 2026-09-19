import Foundation

@MainActor
final class HistoricalViewModel: MeasuresLoadingViewModel {
    @discardableResult
    func fetchData() -> Task<Void, Never> {
        fetchMeasures(limit: 100)
    }
}
