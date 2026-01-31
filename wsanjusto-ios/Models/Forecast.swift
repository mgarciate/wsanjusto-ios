//
//  Forecast.swift
//  wsanjusto-ios
//
//  Created for iOS App Modification
//

import Foundation

// Safe array subscript extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct ForecastDay: Identifiable, Codable {
    let id: UUID = UUID()
    let date: Date
    let tempMin: Int
    let tempMax: Int
    let precipitation: Double
    let qpfSnow: Double?
    let iconCode: Int?
    let narrative: String?
    
    enum CodingKeys: String, CodingKey {
        case date, tempMin, tempMax, precipitation, qpfSnow, iconCode, narrative
    }
}

extension ForecastDay {
    var dayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateFormatter.dateFormat = "EEE dd/MM"
        return dateFormatter.string(from: date).capitalized
    }
}

struct Forecast5Day: Codable {
    let calendarDayTemperatureMax: [Int?]?
    let calendarDayTemperatureMin: [Int?]?
    let temperatureMax: [Int?]?
    let temperatureMin: [Int?]?
    let narrative: [String?]?
    let qpf: [Double?]?
    let qpfSnow: [Double?]?
    let sunriseTimeLocal: [String?]?
    let sunsetTimeLocal: [String?]?
    let iconCode: [Int?]?
}

struct Forecast: Codable {
    let forecast5days: Forecast5Day?
    
    func toDays() -> [ForecastDay] {
        guard let forecast5days = forecast5days,
              let tempMaxArray = forecast5days.calendarDayTemperatureMax,
              let tempMinArray = forecast5days.calendarDayTemperatureMin,
              let qpfArray = forecast5days.qpf,
              !tempMaxArray.isEmpty else {
            return []
        }
        
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        
        // If it's 2pm (14:00) or later, start from index 1 (tomorrow), otherwise from index 0 (today)
        let startIndex = currentHour >= 14 ? 1 : 0
        
        var forecastDate = calendar.startOfDay(for: Date())
        
        // Adjust to start from the correct day
        if startIndex == 1 {
            forecastDate = calendar.date(byAdding: .day, value: 1, to: forecastDate) ?? forecastDate
        }
        
        var days: [ForecastDay] = []
        
        for i in startIndex..<tempMaxArray.count {
            guard let tempMax = tempMaxArray[i],
                  let tempMin = tempMinArray[i] else {
                continue
            }
            
            let precipitation = qpfArray[i] ?? 0.0
            let qpfSnow = forecast5days.qpfSnow?[i] ?? nil
            
            // iconCode array is larger (has day and night icons), use i*2 for day icon, i*2+1 as fallback
            let iconCode: Int?
            if let iconCodeArray = forecast5days.iconCode {
                // Flatten double optionals from array of optional Ints
                let dayIcon = iconCodeArray[safe: i * 2].flatMap { $0 }
                let nightIcon = iconCodeArray[safe: i * 2 + 1].flatMap { $0 }
                iconCode = dayIcon ?? nightIcon
            } else {
                iconCode = nil
            }
            
            let narrative = forecast5days.narrative?[i] ?? nil
            
            let day = ForecastDay(
                date: forecastDate,
                tempMin: tempMin,
                tempMax: tempMax,
                precipitation: precipitation,
                qpfSnow: qpfSnow,
                iconCode: iconCode,
                narrative: narrative
            )
            days.append(day)
            
            // Move to next day
            forecastDate = calendar.date(byAdding: .day, value: 1, to: forecastDate) ?? forecastDate
        }
        
        return days
    }
}

