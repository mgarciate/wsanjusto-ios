//
//  LineView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 14/07/2021.
//

import SwiftUI
import Charts

struct LineView : UIViewRepresentable {
    var entries : [Measure]
    
    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        chart.noDataText = "Cargando temperaturas..."
        chart.noDataTextColor = Resources.Colors.primary
        chart.rightAxis.drawLabelsEnabled = false
        chart.rightAxis.drawAxisLineEnabled = false
        
        chart.xAxis.valueFormatter = MyXAxisValueFormatter(entries: entries)
        chart.xAxis.granularity = 1.0
        
        chart.data = addData()
        return chart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.noDataText = "No hay datos"
        uiView.noDataTextColor = Resources.Colors.redDark
        uiView.xAxis.valueFormatter = MyXAxisValueFormatter(entries: entries)
        uiView.data = addData()
    }
    
    func addData() -> LineChartData {
        var chartDataEntries = [ChartDataEntry]()
        entries.enumerated().forEach { (index, item) in
            chartDataEntries.append(ChartDataEntry(x: Double(index), y: Double(item.sensorTemperature1)))
        }
        
        let dataSet = LineChartDataSet(entries: chartDataEntries, label: "Temperatura sensor 1")
        dataSet.setColor(Resources.Colors.primary)
        dataSet.setCircleColor(Resources.Colors.redDark)
        dataSet.valueTextColor = .black
        
        dataSet.circleRadius = 4
        dataSet.circleHoleRadius = 2
        
        let data = LineChartData(dataSets: [dataSet])
        return data
    }
    
    typealias UIViewType = LineChartView
}



struct Bar_Previews: PreviewProvider {
    static var previews: some View {
        LineView(entries: Measure.dummyData)
    }
}

fileprivate class MyXAxisValueFormatter: AxisValueFormatter {
    let entries: [Measure]
    
    init(entries: [Measure]) {
        self.entries = entries
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard entries.count > 0 else { return "no" }
        let graphEntry = entries[Int(value)]
        let date = Date(timeIntervalSince1970: TimeInterval(graphEntry.createdAt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
}
