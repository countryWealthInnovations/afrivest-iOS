//
//  AppTheme.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI

struct AppTheme {
    // MARK: - Background Gradient
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.backgroundDark1, .backgroundDark2]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Button Gradient (Optional - for special buttons)
    static var buttonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FFEAAF"),
                Color(hex: "C58D30")
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Glassmorphism Effect
    static func glassmorphismBlur() -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .glassmorphismOverlay, location: 0.7),
                        .init(color: .overlayDark, location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .blur(radius: 15)
    }
}

// MARK: - View Extension for Background
extension View {
    func appBackground() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.backgroundGradient)
            .ignoresSafeArea()
    }
}