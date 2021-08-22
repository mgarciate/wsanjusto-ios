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
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.refreshData()
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                            .background(Color("PrimaryColor"))
                            .cornerRadius(25)
                    })
                    .padding()
                }
                Spacer()
            }
            
            VStack {
                VStack {
                    Spacer()
                    ProgressBar(measure: $viewModel.measure, progress: $viewModel.progressTempValue, type: .temperature)
                        .frame(width: 250.0, height: 250.0)
                        .padding(10.0)
                    Spacer()
                        .frame(height: 20)
                    ProgressBar(measure: $viewModel.measure, progress: $viewModel.progressHumValue, type: .humidity)
                        .frame(width: 150.0, height: 150.0)
                        .padding(10.0)
                    Spacer()
                }
                Spacer()
                DashboardFooterView(measure: $viewModel.measure)
                    .padding(10)
            }
        }
        .onReceive(authService.$user) { user in
            guard let _ = user else { return }
            viewModel.fetchData()
        }
    }
}

fileprivate struct DashboardFooterView: View {
    @Binding var measure: Measure
    
    var body: some View {
        VStack {
            Color("PrimaryColor")
                .frame(height: 1)
            VStack(spacing: 5) {
                HStack(alignment: .top) {
                    VStack(alignment: .trailing) {
                        HStack {
                            Text("Presión atmosférica:")
                            Spacer()
                            Text(String(format: "%.0f hPa", measure.pressure1))
                                .bold()
                        }
                        HStack {
                            Text("Sensación térmica:")
                            Spacer()
                            Text(String(format: "%.2f °C", measure.realFeel))
                                .bold()
                        }
                        HStack {
                            Text("Segundo sensor:")
                            Spacer()
                            Text(String(format: "%.2f °C", measure.sensorTemperature2))
                                .bold()
                        }
                    }
                    .frame(maxWidth: 180)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Últ. actualización:")
                        Text(measure.dateString)
                            .bold()
                    }
                }
                Text("*Los datos se actualizan cada 10 minutos aproximadamente...")
                    .foregroundColor(Color("TextGrayColor"))
                    .italic()
                    .lineLimit(1)
            }
            .foregroundColor(Color("TextBlackColor"))
            .font(.caption)
        }
    }
}

fileprivate enum ProgressBarType {
    case temperature, humidity
}

fileprivate struct ProgressBar: View {
    @Binding var measure: Measure
    @Binding var progress: Double
    let type: ProgressBarType
    private let gradientHot = AngularGradient(
        gradient: Gradient(colors: [ Color("RedDarkColor"), Color("RedLightColor"),.white]),
        center: .center,
        startAngle: .degrees(270),
        endAngle: .degrees(0))
    private let gradientCold = AngularGradient(
        gradient: Gradient(colors: [.white, Color("BlueLightColor"), Color("BlueDarkColor")]),
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(90))
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .foregroundColor(Color("PrimaryColor"))
            
            if progress >= 0 {
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(gradientHot, style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear(duration: 1.0))
                //                .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
            } else {
                Circle()
                    .trim(from: 0.0, to: CGFloat(abs(progress)))
                    .stroke(gradientCold, style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear(duration: 1.0))
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }

            VStack(alignment: .center, spacing: -10) {
                if type == .temperature {
                    Text(String(format: "%.1f", measure.sensorTemperature1))
                        .font(.system(size: 60))
                        .bold()
                } else if type == .humidity {
                    Text(String(format: "%.0f", measure.sensorHumidity1))
                        .font(.system(size: 60))
                        .bold()
                }
                Text("\(type == .temperature ? "°C" : "%")")
                    .font(.title)
                    .bold()
            }
            .foregroundColor(Color("PrimaryColor"))
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
