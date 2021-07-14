//
//  AppDelegate.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 14/07/2021.
//

import Foundation
import UIKit
import Firebase

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        AuthenticationService().signIn()
        return true
    }
}
