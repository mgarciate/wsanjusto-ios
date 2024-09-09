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
    @State private var touchLocation: CGPoint? = nil
    // TODO: Remove test values
//    let measures: [Measure] = {
//        var measures = [Measure]()
//        (0..<20).forEach {
//            let timestamp = 1718038095 + ($0 * 1000)
//            var temp = 20.0
//            var temp_factor = 0.0
//            if $0 < (144/2) {
//                temp =  Double($0) * 0.2
//            } else {
//                temp -= Double($0) * 0.2
//            }
//            measures.append(
//                Measure(createdAt: timestamp, indexArduino: timestamp, orderByDate: -timestamp, realFeel: 19, sensorHumidity1: 80, sensorTemperature1: temp, sensorTemperature2: 21, pressure1: 1000, uid: timestamp)
//            )
//        }
//        return measures
//    }()
    
    var body: some View {
        ZStack {
            Color("SecondaryColor")
                .edgesIgnoringSafeArea(.all)
            if viewModel.isLoading {
                Text("Cargando temperaturas...")
                    .foregroundColor(Color("PrimaryColor"))
            } else {
                VStack {
                    Group {
                            HStack {
                                HStack(spacing: 5) {
                                    Text("Hora:")
                                        .font(.caption)
                                    Text(viewModel.selectedDate)
                                        .font(.caption)
                                        .bold()
                                }
                                HStack(spacing: 5) {
                                    Text("Temperatura:")
                                        .font(.caption)
                                    Text(viewModel.selectedTemperature)
                                        .font(.caption)
                                        .bold()
                                }
                                Spacer()
                            }
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color("White"))
                    .cornerRadius(4.0)
                    .padding()
                    Chart(viewModel.measures) {
                        LineMark(
                            x: .value("Hora", Date(timeIntervalSince1970: TimeInterval($0.createdAt))),
                            y: .value("Temperatura", $0.sensorTemperature1)
                        )
                        .foregroundStyle(Color("Green").gradient)
                        .interpolationMethod(.catmullRom)
                        AreaMark(
                            x: .value("Hora", Date(timeIntervalSince1970: TimeInterval($0.createdAt))),
                            yStart: .value("Temperatura", $0.sensorTemperature1),
                            yEnd: .value("TemperaturaEnd", viewModel.domainMeasuresFrom)
                        )
                        .foregroundStyle(Color("Green").opacity(0.1).gradient)
                        .interpolationMethod(.catmullRom)
//                        .symbol {
//                            Circle()
//                                .fill(Color.green)
//                                .frame(width: 4, height: 4)
//                        }
                    }
                    .chartYScale(domain: viewModel.domainMeasuresFrom...viewModel.domainMeasuresTo)
                    .chartXAxis {
                        AxisMarks(preset: .extended, values: .automatic) { value in
                            AxisValueLabel(format: .dateTime.hour())
                            AxisGridLine(centered: true)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(preset: .extended, position: .trailing, values: .stride(by: 2))
                    }
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            ZStack {
                                Rectangle().fill(.clear).contentShape(Rectangle())
                                    .gesture(DragGesture()
                                        .onChanged { value in
                                            guard let measure = findClosestMeasure(to: value.location, proxy: proxy, geometry: geometry) else { return }
                                            viewModel.select(measure: measure)
                                        }
                                    )
                                    .onTapGesture { location in
                                        guard let measure = findClosestMeasure(to: location, proxy: proxy, geometry: geometry) else { return }
                                        viewModel.select(measure: measure)
                                }
                                if let touchLocation {
                                    Path { path in
                                        path.move(to: CGPoint(x: touchLocation.x, y: 0))
                                        path.addLine(to: CGPoint(x: touchLocation.x, y: geometry.size.height))
                                    }
                                    .stroke(Color("RedDarkColor"), lineWidth: 1)
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: touchLocation.y))
                                        path.addLine(to: CGPoint(x: geometry.size.width, y: touchLocation.y))
                                    }
                                    .stroke(Color("RedDarkColor"), lineWidth: 1)
                                    Circle()
                                        .foregroundStyle(Color("RedDarkColor"))
                                        .frame(width: 5, height: 5)
                                        .position(touchLocation)
                                }
                            }
                        }
                    }
                .padding()
                }
            }
        }
        .onAppear() {
            viewModel.fetchData()
            touchLocation = nil
        }
    }
    
    private func findClosestMeasure(to location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> Measure? {
        let plotSizeWidth: CGFloat
        if #available(iOS 17.0, *) {
            plotSizeWidth = proxy.plotSize.width
        } else {
            plotSizeWidth = geometry[proxy.plotAreaFrame].width
        }
        guard !viewModel.measures.isEmpty,
              location.x >= 0,
              location.x < plotSizeWidth,
              let firstTimestamp = viewModel.measures.last?.createdAt,
              let lastTimestamp = viewModel.measures.first?.createdAt else { return nil }
        let xScaleFactor = CGFloat(lastTimestamp - firstTimestamp) / plotSizeWidth
        let touchedTimestamp = firstTimestamp + Int(location.x * xScaleFactor)
        guard let measure = viewModel.measures.min(by: { abs($0.createdAt - touchedTimestamp) < abs($1.createdAt - touchedTimestamp) }) else { return nil }
        let xLocation = plotSizeWidth * CGFloat(measure.createdAt - firstTimestamp) / CGFloat(lastTimestamp - firstTimestamp)
        guard let yLocation = proxy.position(forY: measure.sensorTemperature1) else { return nil }
        touchLocation = CGPoint(x: xLocation, y: yLocation)
        return measure
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
