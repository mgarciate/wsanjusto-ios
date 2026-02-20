//
//  SplashView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 15/07/2021.
//

import SwiftUI

struct SplashView: View {
    @State private var isMainViewPresented = false
    @State private var show = false
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                Color("PrimaryDarkColor")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    ZStack {
                        if show {
                            Circle()
                                .foregroundColor(.white)
                                .transition(AnyTransition
                                                .move(edge: .trailing)
                                                .combined(with:
                                                            .offset(.init(width: (geometry.size.width / 2), height: 0))
                                                ))
                            
                            Image("Icon")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .transition(AnyTransition
                                                .move(edge: .leading)
                                                .combined(with:
                                                            .offset(.init(width: -(geometry.size.width / 2), height: 0))
                                                ))
                        }
                        
                    }
                    .frame(width: 140, height: 140)
                    
                    if show {
                        Text("Tiempo \nSan Justo de la Vega")
                            .foregroundColor(.white)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .transition(AnyTransition
                                            .move(edge: .trailing)
                                            .combined(with:
                                                        .offset(.init(width: (geometry.size.width / 2), height: 0))
                                            ))
                    }
                }
            }
            .fullScreenCover(isPresented: $isMainViewPresented, content: MainView.init)
            .onAppear() {
                AuthenticationService().signIn()
                withAnimation {
                    self.show.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isMainViewPresented.toggle()
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
