//
//  MainView.swift
//  wsanjustowatchos WatchKit Extension
//
//  Created by mgarciate on 12/6/22.
//

import SwiftUI

extension View {
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(watchOS 10.0, *) {
            self.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            self.onChange(of: value, perform: action)
        }
    }
}

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
        .onChangeCompat(of: scenePhase) { phase in
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
