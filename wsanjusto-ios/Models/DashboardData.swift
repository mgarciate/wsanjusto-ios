//
//  DashboardData.swift
//  wsanjusto-ios
//
//  Created for iOS App Modification
//

import Foundation
import FirebaseDatabase

struct DashboardData: Codable, Sendable {
    let current: Measure?
    let forecast: Forecast?
}

extension DashboardData {
    static func build(with snapshot: DataSnapshot?) -> DashboardData? {
        guard let snapshot = snapshot,
              let value = snapshot.value as? NSDictionary else {
            return nil
        }
        
        var current: Measure?
        var forecast: Forecast?
        
        // Extract current measurement
        current = Measure.build(with: snapshot.childSnapshot(forPath: "current"))
        
        // Extract forecast
        if let forecastDict = value["forecast"] as? NSDictionary,
           let forecast5daysDict = forecastDict["forecast5days"] as? NSDictionary {
            
            let forecast5days = Forecast5Day(
                calendarDayTemperatureMax: forecast5daysDict["calendarDayTemperatureMax"] as? [Int?],
                calendarDayTemperatureMin: forecast5daysDict["calendarDayTemperatureMin"] as? [Int?],
                temperatureMax: forecast5daysDict["temperatureMax"] as? [Int?],
                temperatureMin: forecast5daysDict["temperatureMin"] as? [Int?],
                narrative: forecast5daysDict["narrative"] as? [String?],
                qpf: forecast5daysDict["qpf"] as? [Double?],
                qpfSnow: forecast5daysDict["qpfSnow"] as? [Double?],
                sunriseTimeLocal: forecast5daysDict["sunriseTimeLocal"] as? [String?],
                sunsetTimeLocal: forecast5daysDict["sunsetTimeLocal"] as? [String?],
                iconCode: forecast5daysDict["iconCode"] as? [Int?]
            )
            
            forecast = Forecast(forecast5days: forecast5days)
        }
        
        return DashboardData(current: current, forecast: forecast)
    }
}

