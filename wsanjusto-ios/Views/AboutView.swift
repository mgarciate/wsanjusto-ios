//
//  AboutView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI

final class AboutViewModel: ObservableObject {
    @Published var appVersion: String
    
    init() {
        if let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleShortVersionString"] as? String, let build = dictionary["CFBundleVersion"] as? String {
            appVersion = "\(version) (\(build))"
        } else {
            appVersion = "-"
        }
    }
}

struct AboutView: View {
    @StateObject private var viewModel = AboutViewModel()
    
    var body: some View {
        ZStack {
            Color("SecondaryColor")
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 10) {
                VStack(spacing: 10) {
                    Image("Icon")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text("Versión \(viewModel.appVersion)")
                }
                Text("La aplicación permite visualizar la temperatura actual en San Justo de la Vega. Un pueblo situado en la provincia de León, España. También, se encuentra integrado un indicador que muestra la humedad del sensor capacitivo. Adicionalmente, se pueden comprobar los datos con un segundo sensor de temperatura. En la pantalla principal, se encuentran la temperatura capturada por el dispositivo Dallas DS1820 y la humedad adquirida del DHT22.")
                    .padding()
                    .font(Font.subheadline.italic())
                    .multilineTextAlignment(.center)
                VStack(spacing: 0) {
                    Text("© 2021 mgarciate")
                    Text("Todos los derechos reservados.")
                }
                .foregroundColor(Color("TextGrayColor"))
                .font(Font.subheadline.italic())
            }
        }
        .foregroundColor(Color("TextBlackColor"))
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
