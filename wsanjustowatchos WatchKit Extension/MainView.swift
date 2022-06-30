//
//  MainView.swift
//  wsanjustowatchos WatchKit Extension
//
//  Created by mgarciate on 12/6/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var viewModel = MainViewModel()
    var body: some View {
        ZStack {
            MainMiniView(measure: $viewModel.measure)
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .background(
                        Color("Black")
                            .opacity(0.7)
                    )
            }
        }
        .onAppear() {
            viewModel.loadData()
        }
        .onTapGesture {
            viewModel.loadData()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                viewModel.loadData()
            default:
                print(">> do nothing")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
