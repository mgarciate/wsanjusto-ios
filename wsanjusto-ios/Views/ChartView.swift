//
//  ChartView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI
import Charts

struct ChartView: View {
    @StateObject private var viewModel = ChartViewModel()
    // TODO: Remove magic numbers
    
    var body: some View {
        ZStack {
            Color("SecondaryColor")
                .edgesIgnoringSafeArea(.all)
            if viewModel.isLoading {
                Text("Cargando temperaturas...")
                    .foregroundColor(Color("PrimaryColor"))
            } else {
                Chart(viewModel.measures) {
                    LineMark(
                        x: .value("Hora", Date(timeIntervalSince1970: TimeInterval($0.createdAt))),
                        y: .value("Temperatura", $0.sensorTemperature1)
                    )
                    .interpolationMethod(.catmullRom)
    //                .symbol {
    //                    Circle()
    //                        .fill(Color.green)
    //                        .frame(width: 4, height: 4)
    //                }
                }
                .chartXScale(range: .plotDimension(padding: 10))
                .chartXAxis {
                    AxisMarks(preset: .extended, values: .automatic) { value in
                        AxisValueLabel(format: .dateTime.hour())
                        AxisGridLine(centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 5))
                }
                .padding()
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
