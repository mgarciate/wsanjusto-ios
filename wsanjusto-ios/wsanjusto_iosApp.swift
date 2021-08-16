//
//  wsanjusto_iosApp.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import SwiftUI

@main
struct wsanjusto_iosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
