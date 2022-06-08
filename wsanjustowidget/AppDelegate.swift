//
//  AppDelegate.swift
//  wsanjustowidgetExtension
//
//  Created by mgarciate on 8/6/22.
//

import Foundation
import UIKit
import Firebase

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
