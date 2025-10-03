//
//  PrimaryButton.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: {
            if isEnabled && !isLoading {
                action()
            }
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .buttonPrimaryText))
                } else {
                    Text(title)
                        .font(AppFont.button())
                        .foregroundColor(isEnabled ? .buttonPrimaryText : .buttonDisabledText)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.buttonHeight)
            .background(isEnabled ? Color.buttonPrimary : Color.buttonDisabled)
            .cornerRadius(Spacing.radiusMedium)
        }
        .disabled(!isEnabled || isLoading)
    }
}

// Usage:
// PrimaryButton(title: "Log in", action: { login() }, isLoading: isLoading, isEnabled: isFormValid)