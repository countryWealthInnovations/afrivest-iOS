//
//  PhoneTextField.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI

struct PhoneTextField: View {
    let label: String
    @Binding var text: String
    var state: TextFieldState = .normal
    var errorMessage: String? = nil
    var showCheckmark: Bool = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Label
            Text(label)
                .font(AppFont.label())
                .foregroundColor(.textPrimary)
            
            // Input Field with prefix
            HStack(spacing: 0) {
                Text("+")
                    .font(AppFont.bodyLarge())
                    .foregroundColor(.textPrimary)
                    .padding(.leading, Spacing.md)
                
                TextField("256700000001", text: $text)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(.textPrimary)
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isFocused)
                    .onChange(of: text) { newValue in
                        // Only allow numbers
                        text = newValue.filter { $0.isNumber }
                        // Limit to 15 digits
                        if text.count > 15 {
                            text = String(text.prefix(15))
                        }
                    }
                
                // Right Icon
                if showCheckmark && state == .success {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.successGreen)
                        .frame(width: Spacing.iconSize, height: Spacing.iconSize)
                        .padding(.trailing, Spacing.md)
                }
            }
            .frame(height: Spacing.inputHeight)
            .background(Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(borderColor, lineWidth: Spacing.borderMedium)
            )
            
            // Helper text
            if state != .error {
                Text("Include country code (e.g., 256700000001)")
                    .font(AppFont.bodySmall())
                    .foregroundColor(.textSecondary)
            }
            
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

// Usage in SwiftUI View:
/*
@State private var phoneNumber = ""
@State private var phoneState: TextFieldState = .normal

PhoneTextField(
    label: "Phone Number",
    text: $phoneNumber,
    state: phoneState,
    errorMessage: "Invalid phone number",
    showCheckmark: phoneState == .success
)
.onChange(of: phoneNumber) { newValue in
    if newValue.count >= 10 {
        if Validators.isValidPhoneNumber(newValue) {
            phoneState = .success
        } else {
            phoneState = .error
        }
    } else {
        phoneState = .normal
    }
}
*/