//
//  ChartView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI
import Charts

struct ChartView: View {
    @StateObject private var viewModel: ChartViewModel
    @State private var touchLocation: CGPoint? = nil

    init(viewModel: ChartViewModel = ChartViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
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
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            Color("SecondaryColor")
                .edgesIgnoringSafeArea(.all)
            if viewModel.loadingState == .loading {
                Text("Cargando temperaturas...")
                    .accessibilityIdentifier("chart.loading")
                    .foregroundColor(Color("PrimaryColor"))
            } else if viewModel.loadingState == .empty {
                Text("No hay temperaturas disponibles")
                    .accessibilityIdentifier("chart.empty")
                    .foregroundColor(Color("PrimaryColor"))
            } else if viewModel.loadingState == .failed {
                Text("No se han podido cargar las temperaturas")
                    .accessibilityIdentifier("chart.error")
                    .foregroundColor(Color("PrimaryColor"))
            } else {
                VStack {
                    Picker("Magnitud", selection: $viewModel.selectedMetric) {
                        ForEach(ChartMetric.allCases) { metric in
                            Text(metric.title)
                                .tag(metric)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("chart.metricPicker")
                    .padding(.horizontal)

                    if viewModel.chartData.isEmpty {
                        Text("No hay datos de \(viewModel.selectedMetric.title.lowercased()) disponibles")
                            .accessibilityIdentifier("chart.metricEmpty")
                            .foregroundColor(Color("PrimaryColor"))
                            .frame(maxHeight: .infinity)
                    } else {
                        ChartSelectionHeader(
                            selectedDate: viewModel.selectedDate,
                            metricTitle: viewModel.selectedMetric.title,
                            selectedValue: viewModel.selectedValue
                        )
                        Chart(viewModel.chartData) {
                            LineMark(
                                x: .value("Hora", $0.date),
                                y: .value(viewModel.selectedMetric.title, $0.value)
                            )
                            .foregroundStyle(chartColor.gradient)
                            .interpolationMethod(.catmullRom)
                            AreaMark(
                                x: .value("Hora", $0.date),
                                yStart: .value(viewModel.selectedMetric.title, $0.value),
                                yEnd: .value("Base", viewModel.chartDomain.lowerBound)
                            )
                            .foregroundStyle(chartColor.opacity(0.1).gradient)
                            .interpolationMethod(.catmullRom)
                            if let windDirection = $0.displayedWindDirection {
                                PointMark(
                                    x: .value("Hora", $0.date),
                                    y: .value(viewModel.selectedMetric.title, $0.value)
                                )
                                .foregroundStyle(chartColor)
                                .symbol {
                                    Image(systemName: "location.north.fill")
                                        .font(.caption2)
                                        .rotationEffect(.degrees(Double(windDirection)))
                                }
                            }
//                        .symbol {
//                            Circle()
//                                .fill(Color.green)
//                                .frame(width: 4, height: 4)
//                        }
                    }
                    .chartYScale(domain: viewModel.chartDomain)
                    .chartXAxis {
                        AxisMarks(preset: .extended, values: .automatic) { value in
                            AxisValueLabel(format: .dateTime.hour())
                            AxisGridLine(centered: true)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(preset: .extended, position: .trailing, values: .automatic)
                    }
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            ZStack {
                                Rectangle().fill(.clear).contentShape(Rectangle())
                                    .gesture(DragGesture()
                                        .onChanged { value in
                                            guard let measure = findClosestMeasure(
                                                to: value.location,
                                                proxy: proxy,
                                                geometry: geometry
                                            ) else { return }
                                            viewModel.select(measure: measure)
                                        }
                                    )
                                    .onTapGesture { location in
                                        guard let measure = findClosestMeasure(
                                            to: location,
                                            proxy: proxy,
                                            geometry: geometry
                                        ) else { return }
                                        viewModel.select(measure: measure)
                                }
                                if let touchLocation {
                                    ChartCrosshair(
                                        location: touchLocation,
                                        plotFrame: geometry[proxy.plotAreaFrame]
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                    }
                }
            }
        }
        .onAppear() {
            viewModel.fetchData()
            touchLocation = nil
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.fetchData()
                touchLocation = nil
            }
        }
        .onChange(of: viewModel.selectedMetric) { _ in
            touchLocation = nil
        }
    }

    private var chartColor: Color {
        switch viewModel.selectedMetric {
        case .temperature:
            Color("Green")
        case .windSpeed:
            .blue
        case .precipitation:
            .cyan
        }
    }
    
    private func findClosestMeasure(to location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> Measure? {
        let plotFrame = geometry[proxy.plotAreaFrame]
        guard plotFrame.contains(location) else { return nil }
        let plotX = location.x - plotFrame.origin.x
        guard let touchedDate: Date = proxy.value(atX: plotX),
              let point = viewModel.closestDataPoint(to: touchedDate) else { return nil }
        guard let xLocation = proxy.position(
            forX: point.date
        ), let yLocation = proxy.position(forY: point.value) else { return nil }
        touchLocation = CGPoint(
            x: xLocation + plotFrame.origin.x,
            y: yLocation + plotFrame.origin.y
        )
        return point.measure
    }
}

private struct ChartSelectionHeader: View {
    let selectedDate: String
    let metricTitle: String
    let selectedValue: String

    var body: some View {
        HStack {
            HStack(spacing: 5) {
                Text("Hora:")
                    .font(.caption)
                Text(selectedDate)
                    .accessibilityIdentifier("chart.selectedDate")
                    .font(.caption)
                    .bold()
            }
            HStack(spacing: 5) {
                Text("\(metricTitle):")
                    .font(.caption)
                Text(selectedValue)
                    .accessibilityIdentifier("chart.selectedValue")
                    .font(.caption)
                    .bold()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("White"))
        .cornerRadius(4.0)
        .padding()
    }
}

private struct ChartCrosshair: View {
    let location: CGPoint
    let plotFrame: CGRect

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: location.x, y: plotFrame.minY))
                path.addLine(to: CGPoint(x: location.x, y: plotFrame.maxY))
            }
            .stroke(Color("RedDarkColor"), lineWidth: 1)
            Path { path in
                path.move(to: CGPoint(x: plotFrame.minX, y: location.y))
                path.addLine(to: CGPoint(x: plotFrame.maxX, y: location.y))
            }
            .stroke(Color("RedDarkColor"), lineWidth: 1)
            Circle()
                .foregroundStyle(Color("RedDarkColor"))
                .frame(width: 5, height: 5)
                .position(location)
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
