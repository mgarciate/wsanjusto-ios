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
    @Published var weatherBackgroundImageName = "weather_dashboard_7"
    private var isRefreshing = false
    private let dateProvider: DateProviding
    
    init(dateProvider: DateProviding = SystemDateProvider()) {
        self.dateProvider = dateProvider
    }
    
    private func calculateWeatherBackgroundImageName(for measure: Measure) -> String {
        let defaultImageSuffix = 7
        
        // Map iconCode to image suffix based on CSV data
        let suffix: Int = measure.iconCode.map { code in
            switch code {
            case 13, 14, 15, 16, 25, 41, 42, 43: 1
            case 28, 30, 34: 2
            case 20, 21, 22, 26: 3
            case 27, 29, 33: 4
            case 45: 5
            case 32, 36: 6
            case 31: 7
            case 39, 9, 11: 8
            case 3, 4, 38: 9
            case 37: 10
            case 19, 23, 24: 11
            case 46: 12
            case 5, 6, 7: 13
            case 47: 14
            default: defaultImageSuffix
            }
        } ?? defaultImageSuffix
        
        return "weather_dashboard_\(suffix)"
    }
    
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
        progressTempValue = min(measure.sensorTemperature1 / 40, 1.0)
        progressHumValue = min(measure.sensorHumidity1 / 100, 1.0)
        weatherBackgroundImageName = calculateWeatherBackgroundImageName(for: measure)
        self.measure = measure
    }
}
