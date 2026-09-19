//
//  DashboardViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import FirebaseDatabase
import WidgetKit

// Owns Firebase's opaque observer registration and removes it on teardown.
private final class DashboardObservation: @unchecked Sendable {
    private let reference: DatabaseReference
    private let handle: DatabaseHandle

    init(reference: DatabaseReference, handle: DatabaseHandle) {
        self.reference = reference
        self.handle = handle
    }

    deinit {
        reference.removeObserver(withHandle: handle)
    }
}

struct WeatherPresentationMapper {
    func backgroundImageName(for measure: Measure, at currentTime: Date) -> String {
        let isNightTime = isNightTime(
            sunriseTimeLocal: measure.sunriseTimeLocal,
            sunsetTimeLocal: measure.sunsetTimeLocal,
            at: currentTime
        )
        let defaultImageSuffix = isNightTime ? 7 : 6
        var suffix = imageSuffix(for: measure.iconCode) ?? defaultImageSuffix

        if isNightTime {
            switch suffix {
            case 6, 11: suffix = 7
            case 2, 3: suffix = 4
            case 9, 10: suffix = 14
            case 1: suffix = 12
            case 0, 8, 13: suffix = 5
            default: break
            }
        } else {
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

    func isNightTime(
        sunriseTimeLocal: String?,
        sunsetTimeLocal: String?,
        at currentTime: Date
    ) -> Bool {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        if let sunsetTimeLocal,
           let sunsetDate = formatter.date(from: sunsetTimeLocal),
           currentTime > sunsetDate {
            return true
        }

        if let sunriseTimeLocal,
           let sunriseDate = formatter.date(from: sunriseTimeLocal),
           currentTime < sunriseDate {
            return true
        }

        return false
    }

    private func imageSuffix(for iconCode: Int?) -> Int? {
        guard let iconCode else { return nil }

        switch iconCode {
        case 8, 10, 12, 18, 40: return 0
        case 13, 14, 15, 16, 25, 41, 42, 43: return 1
        case 28, 30, 34: return 2
        case 20, 21, 22, 26: return 3
        case 27, 29, 33: return 4
        case 45: return 5
        case 32, 36: return 6
        case 31: return 7
        case 39, 9, 11, 17, 35: return 8
        case 3, 4, 38: return 9
        case 37: return 10
        case 19, 23, 24: return 11
        case 46: return 12
        case 5, 6, 7: return 13
        case 47: return 14
        default: return nil
        }
    }
}

@MainActor
class DashboardViewModel: ObservableObject {
    typealias Scheduler = (_ delay: TimeInterval, _ action: @escaping @MainActor @Sendable () -> Void) -> Void
    @Published var measure = Measure.dummyData[0]
    @Published var forecast: [ForecastDay] = []
    @Published var progressTempValue = 0.0
    @Published var progressHumValue = 0.0
    @Published var weatherBackgroundImageName = "weather_dashboard_7"
    private var isRefreshing = false
    private let dateProvider: DateProviding
    private let schedule: Scheduler
    private let weatherPresentationMapper = WeatherPresentationMapper()
    private var dashboardObservation: DashboardObservation?

    init(
        dateProvider: DateProviding = SystemDateProvider(),
        schedule: @escaping Scheduler = { delay, action in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
        }
    ) {
        self.dateProvider = dateProvider
        self.schedule = schedule
    }

    func calculateWeatherBackgroundImageName(for measure: Measure) -> String {
        weatherPresentationMapper.backgroundImageName(for: measure, at: dateProvider.now)
    }

    func isNightTime(sunriseTimeLocal: String?, sunsetTimeLocal: String?) -> Bool {
        weatherPresentationMapper.isNightTime(
            sunriseTimeLocal: sunriseTimeLocal,
            sunsetTimeLocal: sunsetTimeLocal,
            at: dateProvider.now
        )
    }
    
    func fetchData() {
        guard dashboardObservation == nil else { return }

        let reference = Database.database().reference().child("dashboard")
        
        // Fetch dashboard data (includes current measure + forecast)
        let handle = reference.observe(.value) { [weak self] snapshot in
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
        dashboardObservation = DashboardObservation(
            reference: reference,
            handle: handle
        )
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
        
        schedule(1) { [weak self] in
            guard let self = self else { return }
            self.update(measure: previousMeasure)
            self.forecast = previousForecast
            self.isRefreshing = false
        }
    }
    
    func update(measure: Measure) {
        progressTempValue = min(measure.sensorTemperature1 / 40, 1.0)
        progressHumValue = min(measure.sensorHumidity1 / 100, 1.0)
        weatherBackgroundImageName = calculateWeatherBackgroundImageName(for: measure)
        self.measure = measure
    }
}
