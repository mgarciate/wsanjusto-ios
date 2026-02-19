//
//  wsanjustowidget.swift
//  wsanjustowidget
//
//  Created by mgarciate on 7/6/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), measure: Measure.dummyData[0])
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), measure: Measure.dummyData[0])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<Entry>) -> ()) {
        Task {
            do {
                let measure = try await NetworkService<Measure>().get(endpoint: "weather/current")
                let currentDate = Date()
                let entry = SimpleEntry(date: currentDate, measure: measure)
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
                return
            } catch {
                print("Error", error)
                let currentDate = Date()
                let entry = SimpleEntry(date: currentDate, measure: Measure.dummyData[0])
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
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
        ZStack {}
            .widgetBackground(MainMiniView(measure: .constant(entry.measure)))
    }
}

@main
struct wsanjustowidget: Widget {
    let kind: String = "wsanjustowidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            wsanjustowidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tiempo San Justo")
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

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
