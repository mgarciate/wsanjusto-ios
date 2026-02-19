//
//  MainView.swift
//  wsanjustowatchos WatchKit Extension
//
//  Created by mgarciate on 12/6/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = MainViewModel()
    var body: some View {
        ZStack {
            @Bindable var bindableViewModel = viewModel
            MainMiniView(measure: $bindableViewModel.measure)
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
        .onChange(of: scenePhase) { _, phase in
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
