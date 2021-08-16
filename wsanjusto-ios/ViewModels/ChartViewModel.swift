//
//  ChartViewModel.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import Foundation
import FirebaseDatabase

class ChartViewModel: ObservableObject {
    @Published var measures = [Measure]()
    @Published var isLoading = false
    
    func fetchData() {
        isLoading = true
        let ref = Database.database().reference()
        ref.child("measures").queryOrdered(byChild: "orderByDate").queryLimited(toFirst: 150).observeSingleEvent(of: .value) { [weak self] snapshot in
            #if DEBUG
            print("*** Children \(snapshot.childrenCount)")
            #endif
            self?.isLoading = false
            let measures: [Measure] = snapshot.children.compactMap { child in
                guard let measure = Measure.build(with: child as? DataSnapshot) else {
                    return nil
                }
                return measure
            }
            self?.measures = measures.reversed()
        }
    }
}
