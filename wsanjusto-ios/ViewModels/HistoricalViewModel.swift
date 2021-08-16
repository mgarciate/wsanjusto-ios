//
//  HistoricalViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import FirebaseDatabase

class HistoricalViewModel: ObservableObject {
    @Published var measures = [Measure]()

    func fetchData() {
        let ref = Database.database().reference()
        ref.child("measures").queryOrdered(byChild: "orderByDate").queryLimited(toFirst: 100).observeSingleEvent(of: .value) { [weak self] snapshot in
            #if DEBUG
            print("*** Children \(snapshot.childrenCount)")
            #endif
            self?.measures = snapshot.children.compactMap { child in
                guard let measure = Measure.build(with: child as? DataSnapshot) else {
                    return nil
                }
                return measure
            }
        }
    }
}
