//
//  AppDelegate.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 14/07/2021.
//

import Foundation
import FirebaseCore
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if !AppLaunchConfiguration.current.isUITesting, FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        return true
    }
}
