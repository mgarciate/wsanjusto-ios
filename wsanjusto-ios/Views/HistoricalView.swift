//
//  HistoricalView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI

struct HistoricalView: View {
    @StateObject var viewModel = HistoricalViewModel()
    
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
