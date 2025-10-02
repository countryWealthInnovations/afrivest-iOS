//
//  AfriVestApp.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import SwiftUI
import FirebaseCore

@main
struct AfriVRestApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
