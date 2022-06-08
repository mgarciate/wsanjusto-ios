//
//  wsanjustowidget.swift
//  wsanjustowidget
//
//  Created by mgarciate on 7/6/22.
//

import WidgetKit
import SwiftUI
import Firebase
import FirebaseDatabase

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), measure: Measure.dummyData[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), measure: Measure.dummyData[0])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let ref = Database.database().reference()
        ref.child("/widget/measures/current").observeSingleEvent(of: .value) { snapshot in
            guard let currentData = Measure.build(with: snapshot) else {
                print("Cannot download current data")
                let currentDate = Date()
                let entry = SimpleEntry(date: currentDate, measure: Measure.dummyData[0])
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
                return
            }
            #if DEBUG
            print("*** WIDGET DATA \(currentData)")
            #endif
            let currentDate = Date()
            let entry = SimpleEntry(date: currentDate, measure: currentData)
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            print("timeline")
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let measure: Measure
}

struct wsanjustowidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
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
                        Text("\(entry.measure.sensorTemperature1, specifier: "%.1f")°C")
                        Text("\(entry.measure.sensorHumidity1, specifier: "%.0f")%")
                    }
                }
                .font(.title.bold())
                Spacer()
                HStack {
                    Spacer()
                    Label(entry.measure.dateString, systemImage: "icloud.and.arrow.down")
                        .lineLimit(1)
                        .padding([.trailing, .bottom], 10)
                }
            }
        }
        .foregroundColor(Color.init("White").opacity(0.9))
        .font(.caption)
    }
}

@main
struct wsanjustowidget: Widget {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let kind: String = "wsanjustowidget"
    
    init() {
        FirebaseApp.configure()
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            wsanjustowidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tiempo San Justo de la Vega")
        .description("Este widget muestra la temperatura y humedad actual")
        .supportedFamilies([.systemSmall])
    }
}

struct wsanjustowidget_Previews: PreviewProvider {
    static var previews: some View {
        wsanjustowidgetEntryView(entry: SimpleEntry(date: Date(), measure: Measure.dummyData[0]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
