//
//  ChartView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI

struct ChartView: View {
    @StateObject private var viewModel = ChartViewModel()
    
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
