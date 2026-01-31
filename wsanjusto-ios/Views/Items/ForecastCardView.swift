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
            
            Image(weatherIconAsset)
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
                    .foregroundColor(.white.opacity(rainAlpha))
                Text(String(format: "%.1f mm", forecast.precipitation))
                    .foregroundColor(.white.opacity(rainAlpha))
            }
            .font(.caption)
            
            // Snow precipitation (only show if > 0)
            if let qpfSnow = forecast.qpfSnow, qpfSnow > 0.0 {
                HStack(spacing: 2) {
                    Image(systemName: "snowflake")
                        .foregroundColor(.white.opacity(snowAlpha))
                    Text(String(format: "%.1f cm", qpfSnow))
                        .foregroundColor(.white.opacity(snowAlpha))
                }
                .font(.caption)
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
    
    private var weatherIconAsset: String {
        // Map iconCode to SVG weather assets
        // Use weather_icon_{code} format
        guard let code = forecast.iconCode else {
            return "weather_icon_0"
        }
        
        // Return corresponding weather icon asset
        return "weather_icon_\(code)"
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
