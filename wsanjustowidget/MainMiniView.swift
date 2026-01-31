//
//  MainMiniView.swift
//  wsanjusto-ios
//
//  Created by Marcelino on 30/6/22.
//

import SwiftUI

struct MainMiniView: View {
    @Binding var measure: Measure
    
    var body: some View {
        ZStack {
            Color("PrimaryDarkColor")
            Color.clear
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color("Black").opacity(0.6), Color("Black").opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                )
            VStack {
                HStack {
                    Label("San Justo", systemImage: "location")
                        .lineLimit(1)
                    FlagView()
                        .frame(width: 20.0, height: 20.0)
                        .cornerRadius(10.0)
                    Spacer()
                }
                .padding([.top, .leading], 10)
                HStack {
                    Text("\(measure.sensorTemperature1, specifier: "%.1f")°C")
                        .font(.title.bold())
                    Spacer()
                }
                .padding(.leading, 10)
                VStack(alignment: .leading) {
                    HStack(spacing: 5) {
                        Text("Sens. térmica:")
                        Text(String(format: "%.1f°C", measure.realFeel))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack(spacing: 5) {
                        Text("Total precip.:")
                        Text(String(format: "%.2f mm", measure.precipTotal ?? 0))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack(spacing: 5) {
                        Text("Villameca:")
                        Text(String(format: "%.2f hm³", measure.villamecaActual ?? 0))
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                .font(.caption)
                .padding(.leading, 10)
                
                Spacer()
                HStack {
                    Label(measure.dateString, systemImage: "icloud.and.arrow.down")
                        .lineLimit(1)
                        .padding([.leading, .bottom], 10)
                    Spacer()
                }
            }
        }
        .foregroundColor(Color("White").opacity(0.9))
        .font(.caption)
    }
}

#if DEBUG
struct MainMiniView_Previews: PreviewProvider {
    static var previews: some View {
        MainMiniView(measure: .constant(Measure(
            createdAt: Int(Date().timeIntervalSince1970),
            indexArduino: 0,
            orderByDate: 0,
            realFeel: 20.0,
            sensorHumidity1: 65.0,
            sensorTemperature1: 22.5,
            sensorTemperature2: 21.0,
            pressure1: 1013.25,
            uid: 1,
            dewpoint: 15.0,
            precipTotal: 2.5,
            uv: 3.0,
            windSpeed: 10.0,
            windGust: 15.0,
            windDir: 180,
            airQualityIndex: 50,
            airQualityCategory: "Buena",
            villamecaActual: 13.3,
            villamecaWeeklyVolumeVariation: 0.5,
            villamecaLastYear: 12.8
        )))
        .previewLayout(.fixed(width: 200, height: 200))
        .previewDisplayName("Widget Small")
    }
}
#endif
