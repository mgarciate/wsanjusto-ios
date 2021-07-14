//
//  MainView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI

class MainViewModel: ObservableObject {
    
}

struct MainView: View {
    @ObservedObject private var viewModel = MainViewModel()
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "thermometer")
                    Text("Temperatura")
                }
            ChartView()
                .tabItem {
                    Image("timeline")
                    Text("Gráfico")
                }
            HistoricalView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Histórico")
                }
            AboutView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("Acerca de")
                }
        }
        .accentColor(Color("PrimaryColor"))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
