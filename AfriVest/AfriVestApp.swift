//
//  AfriVestApp.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import SwiftUI

@main
struct AfriVestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
