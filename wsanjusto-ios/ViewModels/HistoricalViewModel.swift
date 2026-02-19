//
//  HistoricalViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import FirebaseDatabase
import Observation

@MainActor
@Observable
final class HistoricalViewModel {
    var measures = [Measure]()

    func fetchData() {
        let ref = Database.database().reference()
        ref.child("measures").queryOrdered(byChild: "orderByDate").queryLimited(toFirst: 100).observeSingleEvent(of: .value) { [weak self] snapshot in
            #if DEBUG
            print("*** Children \(snapshot.childrenCount)")
            #endif
            let measures = snapshot.children.compactMap { child in
                Measure.build(with: child as? DataSnapshot)
            }
            Task { @MainActor [weak self] in
                self?.measures = measures
            }
        }
    }
}
