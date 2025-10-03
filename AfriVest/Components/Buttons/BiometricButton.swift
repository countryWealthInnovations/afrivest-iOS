//
//  BiometricButton.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI

struct BiometricButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "faceid")
                .font(.system(size: 24))
                .foregroundColor(.primaryGold)
                .frame(width: Spacing.otpBoxSize, height: Spacing.otpBoxSize)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .stroke(Color.primaryGold, lineWidth: Spacing.borderMedium)
                )
        }
    }
}

// Usage:
// BiometricButton { authenticateWithBiometric() }