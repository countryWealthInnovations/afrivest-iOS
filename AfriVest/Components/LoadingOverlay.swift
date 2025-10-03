//
//  LoadingOverlay.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryGold))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(AppFont.bodyRegular())
                    .foregroundColor(.textPrimary)
            }
            .padding(Spacing.xl)
            .background(Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
        }
    }
}

// Usage:
// ZStack {
//     YourContentView()
//     if isLoading {
//         LoadingOverlay()
//     }
// }