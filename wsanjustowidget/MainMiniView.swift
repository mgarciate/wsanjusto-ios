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
                        Image(systemName: "humidity")
                        Text("\(measure.sensorHumidity1, specifier: "%.0f")%")
                        Spacer()
                    }
                    Text(String(format: "%.0f hPa", measure.pressure1))
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

struct MainMiniView_Previews: PreviewProvider {
    static var previews: some View {
        MainMiniView(measure: .constant(Measure.dummyData[0]))
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
