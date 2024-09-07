//
//  ChartViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import Foundation
import FirebaseDatabase

class ChartViewModel: ObservableObject {
    private static let defaultDate = "-"
    private static let defaultTemperature = "- ºC"
    @Published var measures = [Measure]()
    @Published var isLoading = false
    @Published var selectedDate: String = ChartViewModel.defaultDate
    @Published var selectedTemperature: String = ChartViewModel.defaultTemperature
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
            self?.isLoading = false
            self?.measures = snapshot.children.compactMap { child in
                guard let measure = Measure.build(with: child as? DataSnapshot) else {
                    return nil
                }
                return measure
            }
            self?.domainMeasuresFrom = (self?.measures.map { $0.sensorTemperature1 }.min() ?? 0) - 2
            self?.domainMeasuresTo = (self?.measures.map { $0.sensorTemperature1 }.max() ?? 50) + 2
            // Append half of measures
//            var resultArray: [Measure] = []
//
//            for i in stride(from: 0, to: measures.count, by: 2) {
//                resultArray.append(measures[i])
//            }
//            self?.measures = resultArray
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
