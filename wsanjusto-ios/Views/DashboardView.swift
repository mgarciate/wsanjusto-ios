//
//  DashboardView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var authService: AuthenticationService
    private let loadRemoteData: Bool

    init(
        viewModel: DashboardViewModel = DashboardViewModel(),
        authService: AuthenticationService = AuthenticationService(),
        loadRemoteData: Bool = true
    ) {
        self.viewModel = viewModel
        self.authService = authService
        self.loadRemoteData = loadRemoteData
    }
    
    var body: some View {
        ZStack {
            DashboardBackground(imageName: viewModel.weatherBackgroundImageName)
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    DashboardHeader(onRefresh: viewModel.refreshData)
                    
                    // Large temperature display
                    Text(String(format: "%.1fº", viewModel.measure.sensorTemperature1))
                        .accessibilityIdentifier("dashboard.temperature")
                        .font(.system(size: 80))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    .padding(.top, 10)
                    
                    DashboardMetrics(measure: viewModel.measure)
                    
                    // Forecast section
                    DashboardForecast(forecast: viewModel.forecast)
                    
                    // Reservoir section
                    if viewModel.measure.villamecaActual != nil {
                        ReservoirView(measure: viewModel.measure)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }
                    
                    DashboardLastUpdate(value: viewModel.measure.lastUpdateString)
                }
                .padding(.top)
            }
        }
        .accessibilityIdentifier("dashboard.screen")
        .onReceive(authService.$user) { user in
            guard loadRemoteData, user != nil else { return }
            viewModel.fetchData()
        }
    }

}

private struct DashboardBackground: View {
    let imageName: String

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width)
                .clipped()
                .id(imageName)
                .transition(.opacity)

            LinearGradient(
                colors: [.black.opacity(0.3), .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.0), value: imageName)
    }
}

private struct DashboardHeader: View {
    let onRefresh: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Text("San Justo de la Vega")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
            Spacer()
        }
        .overlay {
            HStack {
                Spacer()
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        .padding(12)
                }
                .accessibilityLabel("Actualizar datos")
                .accessibilityIdentifier("dashboard.refresh")
            }
        }
        .padding(.horizontal)
    }
}

private struct DashboardMetrics: View {
    let measure: Measure

    private let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            WeatherMetricView(icon: "thermometer", label: "Sensación\ntérmica", value: String(format: "%.1f °C", measure.realFeel))
            WeatherMetricView(icon: "drop.fill", label: "Punto de\nrocío", value: String(format: "%.1f °C", measure.dewpoint ?? 0))
            WeatherMetricView(icon: "humidity.fill", label: "Humedad", value: String(format: "%.0f %%", measure.sensorHumidity1))
            WeatherMetricView(icon: "cloud.rain.fill", label: "Total\nprecipitación", value: String(format: "%.2f mm", measure.precipTotal ?? 0))
            WeatherMetricView(icon: "gauge", label: "Presión\natmosférica", value: String(format: "%.0f", measure.pressure1))
            WeatherMetricView(icon: "sun.max.fill", label: "UV", value: String(format: "%.1f", measure.uv ?? 0))
            WeatherMetricView(
                icon: "location.north.fill",
                label: "Viento (km/h)",
                value: String(format: "%.1f | %.1f", measure.windSpeed ?? 0, measure.windGust ?? 0),
                rotation: Double(measure.windDir ?? 0)
            )
            WeatherMetricView(
                icon: "aqi.medium",
                label: measure.airQualityCategory ?? "CO₂",
                value: String(format: "%.0f", Double(measure.airQualityIndex ?? 0))
            )
        }
        .padding(.horizontal)
    }
}

private struct DashboardForecast: View {
    let forecast: [ForecastDay]

    var body: some View {
        if !forecast.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("PREVISIÓN PRÓXIMOS DÍAS")
                    .accessibilityIdentifier("dashboard.forecast.title")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(forecast) { day in
                            ForecastCardView(
                                forecast: day,
                                accessibilityKey: accessibilityKey(for: day)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .accessibilityIdentifier("dashboard.forecast.scroll")
            }
            .padding(.top, 10)
        }
    }

    private func accessibilityKey(for day: ForecastDay) -> String {
        if day.id == forecast.first?.id {
            return "first"
        }
        if day.id == forecast.last?.id {
            return "last"
        }
        return String(Int(day.date.timeIntervalSince1970))
    }
}

private struct DashboardLastUpdate: View {
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text("Últ. actualización")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
