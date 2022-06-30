//
//  MainViewViewModel.swift
//  wsanjustowatchos WatchKit Extension
//
//  Created by mgarciate on 12/6/22.
//

import Foundation

final class MainViewModel: ObservableObject {
    @Published var measure: Measure = Measure.dummyData[0]
    @Published var isLoading: Bool = false
    
    func loadData() {
        print("*** loadData")
        isLoading = true
        Task {
            do {
                let measure = try await NetworkService<Measure>().get(endpoint: "weather/current")
                DispatchQueue.main.async { [weak self] in
                    self?.measure = measure
                }
            } catch {
                print("Error", error)
            }
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
