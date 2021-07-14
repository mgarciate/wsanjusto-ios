//
//  MeasureItemCardView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 14/07/2021.
//

import SwiftUI

struct MeasureItemCardView: View {
    let measure: Measure
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "thermometer")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(Color("PrimaryColor"))
                    .frame(width: 30, height: 40)
                VStack {
                    HStack {
                        Text("Temperatura sensor1:")
                        Spacer()
                        Text(String(format: "%.2f °C", measure.sensorTemperature1))
                            .foregroundColor(Color("PrimaryColor"))
                            .bold()
                    }
                    HStack {
                        Text("Temperatura sensor2:")
                        Spacer()
                        Text(String(format: "%.2f °C", measure.sensorTemperature2))
                            .foregroundColor(Color("PrimaryColor"))
                            .bold()
                    }
                    HStack {
                        Text("Sensación térmica:")
                        Spacer()
                        Text(String(format: "%.2f °C", measure.realFeel))
                            .foregroundColor(Color("PrimaryColor"))
                            .bold()
                    }
                    HStack {
                        Text("Humedad sensor1:")
                        Spacer()
                        Text(String(format: "%.2f %%", measure.sensorHumidity1))
                            .foregroundColor(Color("PrimaryColor"))
                            .bold()
                    }
                    HStack {
                        Text("Presión atmosférica:")
                        Spacer()
                        Text(String(format: "%.0f hPa", measure.pressure1))
                            .foregroundColor(Color("PrimaryColor"))
                            .bold()
                    }
                }
                Spacer()
                    .frame(width: 40)
                HStack(alignment: .center) {
                    VStack(alignment: .trailing) {
                        Text("\(measure.shortTimeString)")
                            .foregroundColor(Color("PrimaryColor"))
                            .bold()
                        Text("\(measure.shortDateString)")
                    }
                }
            }
            .foregroundColor(Color("TextBlackColor"))
        }
        .padding(10)
        .foregroundColor(.gray)
        .background(Color.white)
        .clipped()
        .shadow(color: Color("GrayLightColor"), radius: 5, y: 10)
        .font(.caption)
        .cornerRadius(5.0)
    }
}

struct MeasureItemCardView_Previews: PreviewProvider {
    static var previews: some View {
        MeasureItemCardView(measure: Measure.dummyData[0])
    }
}
