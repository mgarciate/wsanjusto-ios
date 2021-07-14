//
//  Measure.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 14/07/2021.
//

import Foundation

struct Measure: Identifiable {
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
}

extension Measure {
    static var dummyData: [Measure] {
        return [Measure(createdAt: 0, indexArduino: 0, orderByDate: 0, realFeel: 0, sensorHumidity1: 0, sensorTemperature1: 0, sensorTemperature2: 0, pressure1: 0, uid: 0)]
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
}
