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
        // Check if current time is nighttime (after sunset or before sunrise)
        let isNightTime = isNightTime(
            sunriseTimeLocal: measure.sunriseTimeLocal,
            sunsetTimeLocal: measure.sunsetTimeLocal
        )
        
        // Map iconCode to image suffix based on CSV data
        var suffix: Int = measure.iconCode.map { code in
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
        
        // Apply day/night transformations
        if isNightTime {
            // Nighttime transformations
            switch suffix {
            case 6, 11: suffix = 7
            case 2, 3: suffix = 4
            case 9, 10: suffix = 14
            case 1: suffix = 12
            case 0, 8, 13: suffix = 5
            default: break
            }
        } else {
            // Daytime transformations
            switch suffix {
            case 7: suffix = 6
            case 4: suffix = 2
            case 14: suffix = 9
            case 12: suffix = 1
            case 5: suffix = 0
            default: break
            }
        }
        
        return "weather_dashboard_\(suffix)"
    }
    
    private func isNightTime(sunriseTimeLocal: String?, sunsetTimeLocal: String?) -> Bool {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let currentTime = dateProvider.now
        
        // Parse sunset time from format: "2026-02-12T18:52:23+0100"
        if let sunsetString = sunsetTimeLocal,
           let sunsetDate = formatter.date(from: sunsetString),
           currentTime > sunsetDate {
            return true
        }
        
        // Parse sunrise time
        if let sunriseString = sunriseTimeLocal,
           let sunriseDate = formatter.date(from: sunriseString),
           currentTime < sunriseDate {
            return true
        }
        
        return false
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
