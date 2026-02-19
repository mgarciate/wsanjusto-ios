//
//  MainViewViewModel.swift
//  wsanjustowatchos WatchKit Extension
//
//  Created by mgarciate on 12/6/22.
//

import Foundation
import Observation

@MainActor
@Observable
final class MainViewModel {
    var measure: Measure = Measure.dummyData[0]
    var isLoading: Bool = false
    
    func loadData() {
        print("*** loadData")
        isLoading = true
        Task {
            do {
                let measure = try await NetworkService<Measure>().get(endpoint: "weather/current")
                self.measure = measure
            } catch {
                print("Error", error)
            }
            self.isLoading = false
        }
    }
}
