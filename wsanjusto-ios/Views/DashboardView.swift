//
//  DashboardView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel = DashboardViewModel()
    @ObservedObject var authService = AuthenticationService()
    
    var body: some View {
        ZStack {
            // Background image
            ZStack {
                Image(viewModel.measure.weatherBackgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width)
                    .clipped()
                    .id(viewModel.measure.weatherBackgroundImageName)
                    .transition(.opacity)
                
                // Blue gradient overlay
                LinearGradient(
                    colors: [.blue.opacity(0.2), .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.0), value: viewModel.measure.weatherBackgroundImageName)
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    // Header with location and refresh button
                    HStack {
                        Spacer()
                        Text("San Justo de la Vega")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .overlay(
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.refreshData()
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                                    .padding(12)
                            })
                        }
                    )
                    .padding(.horizontal)
                    
                    // Large temperature display
                    Text(String(format: "%.1fº", viewModel.measure.sensorTemperature1))
                        .font(.system(size: 80))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    .padding(.top, 10)
                    
                    // Weather metrics grid (3x3)
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        WeatherMetricView(
                            icon: "thermometer",
                            label: "Sensación\ntérmica",
                            value: String(format: "%.1f °C", viewModel.measure.realFeel)
                        )
                        
                        WeatherMetricView(
                            icon: "drop.fill",
                            label: "Punto de\nrocío",
                            value: String(format: "%.1f °C", viewModel.measure.dewpoint ?? 0)
                        )
                        
                        WeatherMetricView(
                            icon: "humidity.fill",
                            label: "Humedad",
                            value: String(format: "%.0f %%", viewModel.measure.sensorHumidity1)
                        )
                        
                        WeatherMetricView(
                            icon: "cloud.rain.fill",
                            label: "Total\nprecipitación",
                            value: String(format: "%.2f mm", viewModel.measure.precipTotal ?? 0)
                        )
                        
                        WeatherMetricView(
                            icon: "gauge",
                            label: "Presión\natmosférica",
                            value: String(format: "%.0f", viewModel.measure.pressure1)
                        )
                        
                        WeatherMetricView(
                            icon: "sun.max.fill",
                            label: "UV",
                            value: String(format: "%.1f", viewModel.measure.uv ?? 0)
                        )
                        
                        // Wind speed and gust with direction
                        WeatherMetricView(
                            icon: "location.north.fill",
                            label: "Viento (km/h)",
                            value: String(format: "%.1f | %.1f", 
                                        viewModel.measure.windSpeed ?? 0,
                                        viewModel.measure.windGust ?? 0),
                            rotation: Double(viewModel.measure.windDir ?? 0)
                        )
                        
                        // Air quality
                        WeatherMetricView(
                            icon: "aqi.medium",
                            label: viewModel.measure.airQualityCategory ?? "CO₂",
                            value: String(format: "%.0f", Double(viewModel.measure.airQualityIndex ?? 0))
                        )
                    }
                    .padding(.horizontal)
                    
                    // Forecast section
                    if !viewModel.forecast.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PREVISIÓN PRÓXIMOS DÍAS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.forecast) { day in
                                        ForecastCardView(forecast: day)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    }
                    
                    // Reservoir section
                    if viewModel.measure.villamecaActual != nil {
                        ReservoirView(measure: viewModel.measure)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }
                    
                    // Last update timestamp
                    VStack(spacing: 4) {
                        Text("Últ. actualización")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text(viewModel.measure.lastUpdateString)
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .padding(.top)
            }
        }
        .onReceive(authService.$user) { user in
            guard let _ = user else { return }
            viewModel.fetchData()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
