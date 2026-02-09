//
//  Measure+Database.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 14/07/2021.
//

import Foundation
import Firebase

extension Measure {
    static func build(with snapshot: DataSnapshot?) -> Measure? {
        guard let snapshot = snapshot,
              let value = snapshot.value as? NSDictionary,
              let createdAt = value["createdAt"] as? Int,
              let indexArduino = value["indexArduino"] as? Int,
              let orderByDate = value["orderByDate"] as? Int,
              let realFeel = value["realFeel"] as? Double,
              let sensorHumidity1 = value["sensorHumidity1"] as? Double,
              let sensorTemperature1 = value["sensorTemperature1"] as? Double,
              let sensorTemperature2 = value["sensorTemperature2"] as? Double,
              let pressure1 = value["pressure1"] as? Double,
              let uid = value["uid"] as? Int else {
            return nil
        }
        
        // Extract optional fields
        let dewpoint = value["dewpoint"] as? Double
        let precipTotal = value["precipTotal"] as? Double
        let uv = value["uv"] as? Double
        let windSpeed = value["windSpeed"] as? Double
        let windGust = value["windGust"] as? Double
        let windDir = value["winddir"] as? Int
        let airQualityIndex = value["airQualityIndex"] as? Int
        let airQualityCategory = value["airQualityCategory"] as? String
        let villamecaActual = value["villamecaActual"] as? Double
        let villamecaWeeklyVolumeVariation = value["villamecaWeeklyVolumeVariation"] as? Double
        let villamecaLastYear = value["villamecaLastYear"] as? Double
        let iconCode = value["iconCode"] as? Int
        let shortPhrase = value["shortPhrase"] as? String
        
        return Measure(
            createdAt: createdAt,
            indexArduino: indexArduino,
            orderByDate: orderByDate,
            realFeel: realFeel,
            sensorHumidity1: min(sensorHumidity1, 99),
            sensorTemperature1: sensorTemperature1,
            sensorTemperature2: sensorTemperature2,
            pressure1: pressure1,
            uid: uid,
            dewpoint: dewpoint,
            precipTotal: precipTotal,
            uv: uv,
            windSpeed: windSpeed,
            windGust: windGust,
            windDir: windDir,
            airQualityIndex: airQualityIndex,
            airQualityCategory: airQualityCategory,
            villamecaActual: villamecaActual,
            villamecaWeeklyVolumeVariation: villamecaWeeklyVolumeVariation,
            villamecaLastYear: villamecaLastYear,
            iconCode: iconCode,
            shortPhrase: shortPhrase
        )
    }
}
