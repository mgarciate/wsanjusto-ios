//
//  HistoricalView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI
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

struct HistoricalView: View {
    @ObservedObject var viewModel = HistoricalViewModel()
    
    var body: some View {
        ZStack {
            Color("SecondaryColor")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.measures) { item in
                        MeasureItemCardView(measure: item)
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .onAppear() {
            viewModel.fetchData()
        }
    }
}

struct HistoricalView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalView()
    }
}
