//
//  WeatherMetricView.swift
//  wsanjusto-ios
//
//  Created for iOS App Modification
//

import SwiftUI

struct WeatherMetricView: View {
    let icon: String
    let label: String
    let value: String
    let systemIcon: Bool
    let rotation: Double?
    
    init(icon: String, label: String, value: String, systemIcon: Bool = true, rotation: Double? = nil) {
        self.icon = icon
        self.label = label
        self.value = value
        self.systemIcon = systemIcon
        self.rotation = rotation
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if systemIcon {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white.opacity(0.9))
                    .rotationEffect(.degrees(rotation ?? 0))
            } else {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white.opacity(0.9))
                    .rotationEffect(.degrees(rotation ?? 0))
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

struct WeatherMetricView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.53, green: 0.81, blue: 0.92), Color(red: 0.27, green: 0.51, blue: 0.71)],
                startPoint: .top,
                endPoint: .bottom
            )
            VStack {
                WeatherMetricView(icon: "thermometer", label: "Sensación térmica", value: "5.6 °C")
                WeatherMetricView(icon: "location.fill", label: "Viento", value: "15 | 25", rotation: 45)
            }
        }
    }
}
