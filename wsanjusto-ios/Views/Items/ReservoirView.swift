//
//  ReservoirView.swift
//  wsanjusto-ios
//
//  Created for iOS App Modification
//

import SwiftUI

struct ReservoirView: View {
    let measure: Measure
    
    private let maxCapacity: Double = 18.7 // hm³
    
    private var currentVolume: Double {
        measure.villamecaActual ?? 0
    }
    
    private var fillPercentage: Double {
        guard maxCapacity > 0 else { return 0 }
        return min((currentVolume / maxCapacity) * 100, 100)
    }
    
    private var weeklyVariation: Double {
        measure.villamecaWeeklyVolumeVariation ?? 0
    }
    
    private var lastYearDifference: Double {
        guard let current = measure.villamecaActual,
              let lastYear = measure.villamecaLastYear else {
            return 0
        }
        return current - lastYear
    }
    
    private var lastYearPercentage: Double {
        guard let lastYear = measure.villamecaLastYear, lastYear > 0 else {
            return 0
        }
        return (lastYearDifference / lastYear) * 100
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 4) {
                Text("RESERVA ACTUAL")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.9))
                
                Text("Embalse de Villameca")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Gauge and values
            HStack(spacing: 30) {
                // Left value - Max capacity
                VStack {
                    Text(String(format: "%.1f hm³", maxCapacity))
                        .font(.caption)
                    Spacer()
                    Text("0 hm³")
                        .font(.caption)
                }
                .foregroundColor(.white)
                
                // Gauge
                ZStack(alignment: .bottom) {
                    // Container
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        .frame(width: 100, height: 200)
                    
                    // Fill
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            ZStack {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: geometry.size.height * CGFloat(fillPercentage / 100))
                                
                                // Percentage text centered in filled area
                                Text(String(format: "%.0f%%", fillPercentage))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(width: 96, height: 196)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                }
                .frame(width: 100, height: 200)
                
                // Right value - Current volume
                VStack {
                    Spacer()
                    Text(String(format: "%.1f hm³", currentVolume))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
            }
            .padding(.vertical, 8)
            
            // Comparisons
            HStack(spacing: 1) {
                // Weekly comparison
                VStack(spacing: 8) {
                    Text("Respecto a la\nsemana anterior")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Image(systemName: weeklyVariation >= 0 ? "chevron.up" : "chevron.down")
                        .foregroundColor(weeklyVariation >= 0 ? .blue : .red)
                        .font(.title2)
                    
                    Text(String(format: "%+.1f hm³", weeklyVariation))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if let lastYear = measure.villamecaLastYear {
                        let weeklyPercentage = lastYear > 0 ? (weeklyVariation / lastYear) * 100 : 0
                        Text(String(format: "%+.1f%%", weeklyPercentage))
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 1, height: 100)
                
                // Last year comparison
                VStack(spacing: 8) {
                    Text("Misma semana del\naño anterior")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Image(systemName: lastYearDifference >= 0 ? "chevron.up" : "chevron.down")
                        .foregroundColor(lastYearDifference >= 0 ? .blue : .red)
                        .font(.title2)
                    
                    Text(String(format: "%+.1f hm³", lastYearDifference))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(String(format: "%+.1f%%", lastYearPercentage))
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ReservoirView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.53, green: 0.81, blue: 0.92), Color(red: 0.27, green: 0.51, blue: 0.71)],
                startPoint: .top,
                endPoint: .bottom
            )
            ReservoirView(measure: Measure(
                createdAt: 0,
                indexArduino: 0,
                orderByDate: 0,
                realFeel: 0,
                sensorHumidity1: 0,
                sensorTemperature1: 22.5,
                sensorTemperature2: 0,
                pressure1: 0,
                uid: 0,
                dewpoint: 0,
                precipTotal: 0,
                uv: 0,
                windSpeed: 0,
                windGust: 0,
                windDir: 0,
                airQualityIndex: 0,
                airQualityCategory: "Buena",
                villamecaActual: 13.3,
                villamecaWeeklyVolumeVariation: 3.6,
                villamecaLastYear: 13.4
            ))
            .padding()
        }
    }
}
