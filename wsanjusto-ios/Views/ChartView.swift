//
//  ChartView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI
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
            self?.measures = snapshot.children.compactMap { child in
                guard let measure = Measure.build(with: child as? DataSnapshot) else {
                    return nil
                }
                return measure
            }
        }
    }
}

struct ChartView: View {
    @ObservedObject private var viewModel = ChartViewModel()
    
    var body: some View {
        ZStack {
            Color("SecondaryColor")
                .edgesIgnoringSafeArea(.all)
            if viewModel.isLoading {
                Text("Cargando temperaturas...")
                    .foregroundColor(Color("PrimaryColor"))
            } else {
                LineView(entries: viewModel.measures)
                    .frame(minHeight: 0, maxHeight: .infinity)
            }
        }
        .onAppear() {
            viewModel.fetchData()
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
