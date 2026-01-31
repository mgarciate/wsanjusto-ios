//
//  ForecastCardView.swift
//  wsanjusto-ios
//
//  Created for iOS App Modification
//

import SwiftUI

struct ForecastCardView: View {
    let forecast: ForecastDay
    
    var body: some View {
        VStack(spacing: 8) {
            Text(forecast.dayName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(forecast.shortDate)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
            
            Image(systemName: weatherIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
            
            Text("\(forecast.tempMin)° | \(forecast.tempMax)°")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Rain precipitation
            HStack(spacing: 2) {
                Image(systemName: "drop.fill")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(rainAlpha))
                Text(String(format: "%.1f mm", forecast.precipitation))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(rainAlpha))
            }
            
            // Snow precipitation (only show if > 0)
            if let qpfSnow = forecast.qpfSnow, qpfSnow > 0.0 {
                HStack(spacing: 2) {
                    Image(systemName: "snowflake")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(snowAlpha))
                    Text(String(format: "%.1f cm", qpfSnow))
                        .font(.caption2)
                        .foregroundColor(.white.opacity(snowAlpha))
                }
            }
        }
        .padding()
        .frame(width: 120)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
    }
    
    private var rainAlpha: Double {
        forecast.precipitation > 0.0 ? 0.7 : 0.3
    }
    
    private var snowAlpha: Double {
        guard let qpfSnow = forecast.qpfSnow else { return 0.3 }
        return qpfSnow > 0.0 ? 0.7 : 0.3
    }
    
    private var weatherIcon: String {
        // Map iconCode to SF Symbols
        // Based on Weather.com icon codes
        guard let code = forecast.iconCode else {
            return forecast.precipitation > 0.5 ? "cloud.rain.fill" : "cloud.fill"
        }
        
        switch code {
        case 1, 2, 3, 4: // Sunny variations
            return "sun.max.fill"
        case 5, 6, 7, 8: // Partly cloudy
            return "cloud.sun.fill"
        case 9, 10, 11: // Cloudy
            return "cloud.fill"
        case 12, 13, 14, 15, 16, 17, 18: // Rain variations
            return "cloud.rain.fill"
        case 19, 20, 21, 22: // Snow variations
            return "cloud.snow.fill"
        case 23, 24: // Windy
            return "wind"
        case 29, 30: // Partly cloudy night
            return "cloud.moon.fill"
        case 31, 32, 33: // Clear night
            return "moon.fill"
        case 39, 40, 41, 42: // Rain showers
            return "cloud.drizzle.fill"
        case 43, 44, 45, 46: // Snow showers
            return "cloud.snow.fill"
        default:
            return "cloud.fill"
        }
    }
}

struct ForecastCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.53, green: 0.81, blue: 0.92), Color(red: 0.27, green: 0.51, blue: 0.71)],
                startPoint: .top,
                endPoint: .bottom
            )
            VStack {
                ForecastCardView(forecast: ForecastDay(
                    date: Date(),
                    tempMin: 1,
                    tempMax: 7,
                    precipitation: 6.39,
                    qpfSnow: 2.5,
                    iconCode: 12,
                    narrative: "Rain"
                ))
                
                ForecastCardView(forecast: ForecastDay(
                    date: Date(),
                    tempMin: -1,
                    tempMax: 8,
                    precipitation: 0.0,
                    qpfSnow: nil,
                    iconCode: 1,
                    narrative: "Sunny"
                ))
            }
        }
    }
}
