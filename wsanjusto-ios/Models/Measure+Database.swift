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
        return Measure(createdAt: createdAt, indexArduino: indexArduino, orderByDate: orderByDate, realFeel: realFeel, sensorHumidity1: min(sensorHumidity1, 99), sensorTemperature1: sensorTemperature1, sensorTemperature2: sensorTemperature2, pressure1: pressure1, uid: uid)
    }
}
