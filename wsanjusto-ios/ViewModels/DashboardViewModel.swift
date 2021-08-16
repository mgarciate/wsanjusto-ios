//
//  DashboardViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import FirebaseDatabase

class DashboardViewModel: ObservableObject {
    @Published var measure = Measure.dummyData[0]
    @Published var progressTempValue = 0.0
    @Published var progressHumValue = 0.0
    private var isRefreshing = false
    
    func fetchData() {
        let ref = Database.database().reference()
        ref.child("measures").queryOrdered(byChild: "orderByDate").queryLimited(toFirst: 1).observe(.value) { [weak self] snapshot in
            snapshot.children.forEach { child in
                guard let currentData = Measure.build(with: child as? DataSnapshot) else {
                    return
                }
                #if DEBUG
                print("*** CURRENT DATA \(currentData)")
                #endif
                self?.update(measure: currentData)
                // Only want the 1st value
                return
            }
        }
    }
    
    func refreshData() {
        guard !isRefreshing else { return }
        isRefreshing = true
        progressTempValue = 0
        progressHumValue = 0
        let previousMeasure = measure
        measure = Measure.dummyData[0]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.update(measure: previousMeasure)
            self.isRefreshing = false
        }
    }
    
    private func update(measure: Measure) {
        self.progressTempValue = min(measure.sensorTemperature1 / 40, 1.0)
        self.progressHumValue = min(measure.sensorHumidity1 / 100, 1.0)
        self.measure = measure
    }
}
