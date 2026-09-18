//
//  wsanjusto_iosApp.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 13/07/2021.
//

import Foundation
import SwiftUI

enum UITestScenario: String {
    case success
    case empty
    case error
}

struct AppLaunchConfiguration {
    let isUITesting: Bool
    let skipSplash: Bool
    let uiTestScenario: UITestScenario

    init(arguments: [String]) {
        let scenarioValue = arguments
            .drop { $0 != "-UITestingScenario" }
            .dropFirst()
            .first
        isUITesting = arguments.contains("-UITesting")
        skipSplash = arguments.contains("-UITestingSkipSplash")
        uiTestScenario = scenarioValue.flatMap(UITestScenario.init(rawValue:)) ?? .success
    }

    static var current: AppLaunchConfiguration {
        AppLaunchConfiguration(arguments: ProcessInfo.processInfo.arguments)
    }
}

@main
struct wsanjusto_iosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    private let launchConfiguration = AppLaunchConfiguration.current

    var body: some Scene {
        WindowGroup {
            if launchConfiguration.skipSplash {
                MainView(
                    isUITesting: launchConfiguration.isUITesting,
                    uiTestScenario: launchConfiguration.uiTestScenario
                )
            } else {
                SplashView(
                    isUITesting: launchConfiguration.isUITesting,
                    uiTestScenario: launchConfiguration.uiTestScenario
                )
            }
        }
    }
}
