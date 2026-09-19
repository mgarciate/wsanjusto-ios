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
                        ForEach(viewModel.measures, id: \.uid) { item in
                            MeasureItemCardView(measure: item)
                                .accessibilityIdentifier("history.row.\(item.uid)")
                        }

                        HistoryPaginationFooter(
                            isLoading: viewModel.isLoadingPage,
                            hasFailed: viewModel.pageLoadFailed,
                            hasMore: viewModel.hasMore,
                            retry: { viewModel.loadNextPage() }
                        )
                        .onAppear {
                            guard !viewModel.pageLoadFailed else { return }
                            viewModel.loadNextPage()
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
            }
        }
        .onAppear {
            guard viewModel.loadingState == .idle else { return }
            viewModel.fetchData()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.fetchData()
            }
        }
    }
}

private struct HistoryPaginationFooter: View {
    let isLoading: Bool
    let hasFailed: Bool
    let hasMore: Bool
    let retry: () -> Void

    var body: some View {
        VStack {
            if hasFailed {
                Button("Reintentar", action: retry)
                    .accessibilityIdentifier("history.retryPage")
                    .foregroundColor(Color("PrimaryColor"))
            } else if hasMore {
                ProgressView()
                    .accessibilityIdentifier("history.loadingMore")
                    .tint(Color("PrimaryColor"))
                    .opacity(isLoading ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct HistoricalView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalView()
    }
}
