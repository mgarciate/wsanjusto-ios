//
//  HistoricalView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI

struct HistoricalView: View {
    @ObservedObject private var viewModel: HistoricalViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: HistoricalViewModel = HistoricalViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color("SecondaryColor")
                .edgesIgnoringSafeArea(.all)
            
            if viewModel.loadingState == .loading {
                Text("Cargando histórico...")
                    .accessibilityIdentifier("history.loading")
                    .foregroundColor(Color("PrimaryColor"))
            } else if viewModel.loadingState == .empty {
                Text("No hay mediciones disponibles")
                    .accessibilityIdentifier("history.empty")
                    .foregroundColor(Color("PrimaryColor"))
            } else if viewModel.loadingState == .failed {
                Text("No se ha podido cargar el histórico")
                    .accessibilityIdentifier("history.error")
                    .foregroundColor(Color("PrimaryColor"))
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.measures) { item in
                            MeasureItemCardView(measure: item)
                                .accessibilityIdentifier("history.row.\(item.uid)")
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
            }
        }
        .onAppear() {
            viewModel.fetchData()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.fetchData()
            }
        }
    }
}

struct HistoricalView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalView()
    }
}
