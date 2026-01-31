//
//  MeasureItemCardView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 14/07/2021.
//

import SwiftUI

struct MeasureItemCardView: View {
    let measure: Measure
    
    private let skyBlue = Color(red: 0.53, green: 0.81, blue: 0.92)
    private let steelBlue = Color(red: 0.27, green: 0.51, blue: 0.71)
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon and temperature
            VStack(spacing: 8) {
                Image(systemName: "thermometer")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                
                Text(String(format: "%.1f°C", measure.sensorTemperature1))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Data rows
            VStack(alignment: .leading, spacing: 4) {
                DataRow(label: "Humedad:", value: String(format: "%.1f%%", measure.sensorHumidity1))
                
                DataRow(label: "Sensación térmica:", value: String(format: "%.1f°C", measure.realFeel))
                
                if let dewpoint = measure.dewpoint {
                    DataRow(label: "Punto de rocío:", value: String(format: "%.1f°C", dewpoint))
                }
                
                if let precipTotal = measure.precipTotal {
                    DataRow(label: "Precip. total:", value: String(format: "%.1f mm", precipTotal))
                }
                
                DataRow(label: "Presión:", value: String(format: "%.0f hPa", measure.pressure1))
                
                if let uv = measure.uv {
                    DataRow(label: "UV:", value: String(format: "%.1f", uv))
                }
                
                if let windSpeed = measure.windSpeed, let windGust = measure.windGust {
                    DataRow(label: "Viento:", value: String(format: "%.0f | %.0f km/h", windSpeed, windGust))
                }
                
                if let airQualityIndex = measure.airQualityIndex, 
                   let airQualityCategory = measure.airQualityCategory {
                    DataRow(label: "Calidad aire:", value: "\(airQualityCategory) \(airQualityIndex)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Timestamp
            Text(measure.shortTimeString)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [skyBlue, steelBlue],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 3, y: 2)
    }
}

fileprivate struct DataRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct MeasureItemCardView_Previews: PreviewProvider {
    static var previews: some View {
        MeasureItemCardView(measure: Measure.dummyData[0])
            .padding()
    }
}
