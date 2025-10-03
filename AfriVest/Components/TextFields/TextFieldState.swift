//
//  TextFieldState.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI

enum TextFieldState {
    case normal
    case active
    case success
    case error
}

struct AppTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var state: TextFieldState = .normal
    var errorMessage: String? = nil
    var showCheckmark: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    @State private var isPasswordVisible: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Label
            Text(label)
                .font(AppFont.label())
                .foregroundColor(.textPrimary)
            
            // Input Field
            HStack {
                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(.textPrimary)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(.textPrimary)
                        .keyboardType(keyboardType)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                }
                
                // Right Icons
                if isSecure {
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.textSecondary)
                            .frame(width: Spacing.iconSize, height: Spacing.iconSize)
                    }
                } else if showCheckmark && state == .success {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.successGreen)
                        .frame(width: Spacing.iconSize, height: Spacing.iconSize)
                }
            }
            .padding(.horizontal, Spacing.md)
            .frame(height: Spacing.inputHeight)
            .background(Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(borderColor, lineWidth: Spacing.borderMedium)
            )
            
            // Error Message
            if let errorMessage = errorMessage, state == .error {
                Text(errorMessage)
                    .font(AppFont.bodySmall())
                    .foregroundColor(.errorRed)
            }
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .normal:
            return isFocused ? .borderActive : .borderDefault
        case .active:
            return .borderActive
        case .success:
            return .successGreen
        case .error:
            return .errorRed
        }
    }
}

// Usage:
// AppTextField(label: "Email", placeholder: "Enter your email", text: $email, state: .success, showCheckmark: true, keyboardType: .emailAddress)