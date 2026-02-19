//
//  ChartViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import Foundation
import FirebaseDatabase
import Observation

@MainActor
@Observable
final class ChartViewModel {
    private static let defaultDate = "-"
    private static let defaultTemperature = "- ºC"
    var measures = [Measure]()
    var isLoading = false
    var selectedDate: String = ChartViewModel.defaultDate
    var selectedTemperature: String = ChartViewModel.defaultTemperature
    var domainMeasuresFrom: Double = 0.0
    var domainMeasuresTo: Double = 0.0
    
    func fetchData() {
        clear()
        isLoading = true
        let ref = Database.database().reference()
        ref.child("measures").queryOrdered(byChild: "orderByDate").queryLimited(toFirst: 150).observeSingleEvent(of: .value) { [weak self] snapshot in
            #if DEBUG
            print("*** Children \(snapshot.childrenCount)")
            #endif
            let measures = snapshot.children.compactMap { child in
                Measure.build(with: child as? DataSnapshot)
            }
            Task { @MainActor [weak self] in
                self?.isLoading = false
                self?.measures = measures
                self?.domainMeasuresFrom = (self?.measures.map { $0.sensorTemperature1 }.min() ?? 0) - 2
                self?.domainMeasuresTo = (self?.measures.map { $0.sensorTemperature1 }.max() ?? 50) + 2
            }
        }
    }
    
    func select(measure: Measure) {
        selectedDate = measure.dateString
        selectedTemperature = String(format: "%.2f °C", measure.sensorTemperature1)
    }
    
    func clear() {
        selectedDate = ChartViewModel.defaultDate
        selectedTemperature = ChartViewModel.defaultTemperature
    }
}
