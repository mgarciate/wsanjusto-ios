//
//  Measure.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 14/07/2021.
//

import Foundation

struct Measure: Identifiable, Codable {
    let id: UUID = UUID()
    let createdAt: Int
    let indexArduino: Int
    let orderByDate: Int
    let realFeel: Double
    let sensorHumidity1: Double
    let sensorTemperature1: Double
    let sensorTemperature2: Double
    let pressure1: Double
    let uid: Int
    let dewpoint: Double?
    let precipTotal: Double?
    let uv: Double?
    let windSpeed: Double?
    let windGust: Double?
    let windDir: Int?
    let airQualityIndex: Int?
    let airQualityCategory: String?
    let villamecaActual: Double?
    let villamecaWeeklyVolumeVariation: Double?
    let villamecaLastYear: Double?
    
    enum CodingKeys: String, CodingKey {
        case createdAt, indexArduino, orderByDate, realFeel
        case sensorHumidity1, sensorTemperature1, sensorTemperature2
        case pressure1, uid, dewpoint, precipTotal, uv
        case windSpeed, windGust, windDir
        case airQualityIndex, airQualityCategory
        case villamecaActual, villamecaWeeklyVolumeVariation, villamecaLastYear
    }
}

extension Measure {
    static var dummyData: [Measure] {
        return [Measure(createdAt: 0, indexArduino: 0, orderByDate: 0, realFeel: 0, sensorHumidity1: 0, sensorTemperature1: 0, sensorTemperature2: 0, pressure1: 0, uid: 0, dewpoint: 0, precipTotal: 0, uv: 0, windSpeed: 0, windGust: 0, windDir: 0, airQualityIndex: 0, airQualityCategory: "Buena", villamecaActual: 0, villamecaWeeklyVolumeVariation: 0, villamecaLastYear: 0)]
    }
    
    var dateString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(createdAt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
    var shortDateString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(createdAt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter.string(from: date)
    }
    
    var shortTimeString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(createdAt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
    var lastUpdateString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(createdAt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateFormatter.dateFormat = "EEEE, dd MMMM HH:mm"
        return dateFormatter.string(from: date)
    }
}
