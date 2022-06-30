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
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Color("Green")
                        Color("Yellow")
                    }
                    Color("Red")
                    VStack(spacing: 0) {
                        Color("Yellow")
                        Color("Green")
                    }
                }
                Color.clear
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color("Black").opacity(0.6), Color("Black").opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                    )
                VStack {
                    HStack {
                        Spacer()
                        Label("San Justo", systemImage: "location")
                            .lineLimit(1)
                            .padding([.trailing, .top], 10)
                    }
                    Spacer()
                    HStack {
                        VStack(spacing: 10) {
                            Image(systemName: "thermometer")
                            Image(systemName: "humidity")
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(viewModel.measure.sensorTemperature1, specifier: "%.1f")°C")
                            Text("\(viewModel.measure.sensorHumidity1, specifier: "%.0f")%")
                        }
                    }
                    .font(.title.bold())
                    Spacer()
                    HStack {
                        Spacer()
                        Label(viewModel.measure.dateString, systemImage: "icloud.and.arrow.down")
                            .lineLimit(1)
                            .padding([.trailing, .bottom], 10)
                    }
                }
            }
            .foregroundColor(Color("White").opacity(0.9))
            .font(.caption)
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
