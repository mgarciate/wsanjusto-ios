//
//  MainViewViewModel.swift
//  wsanjustowatchos WatchKit Extension
//
//  Created by mgarciate on 12/6/22.
//

import Foundation

@MainActor
final class MainViewModel: ObservableObject {
    @Published var measure: Measure = Measure.dummyData[0]
    @Published var isLoading: Bool = false
    private var loadTask: Task<Void, Never>?
    
    func loadData() {
        print("*** loadData")
        loadTask?.cancel()
        isLoading = true
        loadTask = Task { @MainActor [weak self] in
            do {
                let measure = try await NetworkService<Measure>().get(endpoint: "weather/current")
                try Task.checkCancellation()
                self?.measure = measure
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                print("Error", error)
            }
            self?.isLoading = false
        }
    }
}
