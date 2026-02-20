//
//  MainView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    
}

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    init() {
        // Set TabBar appearance with visible background
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "thermometer")
                    Text("Temperatura")
                }
                .accessibilityIdentifier("dashboardTab")
            ChartView()
                .tabItem {
                    Image("timeline")
                    Text("Gráfico")
                }
                .accessibilityIdentifier("chartTab")
            HistoricalView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Histórico")
                }
                .accessibilityIdentifier("historicalTab")
            AboutView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("Acerca de")
                }
                .accessibilityIdentifier("aboutTab")
        }
        .accessibilityIdentifier("mainTabView")
        .accentColor(Color("PrimaryColor"))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
