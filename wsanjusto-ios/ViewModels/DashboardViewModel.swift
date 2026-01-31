//
//  DashboardViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import FirebaseDatabase
import WidgetKit

class DashboardViewModel: ObservableObject {
    @Published var measure = Measure.dummyData[0]
    @Published var forecast: [ForecastDay] = []
    @Published var progressTempValue = 0.0
    @Published var progressHumValue = 0.0
    private var isRefreshing = false
    
    func fetchData() {
        let ref = Database.database().reference()
        
        // Fetch dashboard data (includes current measure + forecast)
        ref.child("dashboard").observe(.value) { [weak self] snapshot in
            guard let dashboardData = DashboardData.build(with: snapshot) else {
                return
            }
            
            #if DEBUG
            print("*** DASHBOARD DATA \(dashboardData)")
            #endif
            
            // Update current measurement
            if let current = dashboardData.current {
                self?.update(measure: current)
            }
            
            // Update forecast
            if let forecast = dashboardData.forecast {
                self?.forecast = forecast.toDays()
            }
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func refreshData() {
        guard !isRefreshing else { return }
        isRefreshing = true
        progressTempValue = 0
        progressHumValue = 0
        let previousMeasure = measure
        let previousForecast = forecast
        measure = Measure.dummyData[0]
        forecast = []
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.update(measure: previousMeasure)
            self.forecast = previousForecast
            self.isRefreshing = false
        }
    }
    
    private func update(measure: Measure) {
        self.progressTempValue = min(measure.sensorTemperature1 / 40, 1.0)
        self.progressHumValue = min(measure.sensorHumidity1 / 100, 1.0)
        self.measure = measure
    }
}
