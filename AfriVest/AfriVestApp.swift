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
    @State private var isLoggedOut = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoggedOut {
                    LoginView()
                        .onAppear { isLoggedOut = false }
                } else {
                    SplashView()
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: NSNotification.Name("AfriVestForceLogout"))
            ) { _ in
                isLoggedOut = true
            }
        }
    }
}
