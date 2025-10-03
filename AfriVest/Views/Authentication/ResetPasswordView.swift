//
//  ResetPasswordView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI

struct ResetPasswordView: View {
    @StateObject private var viewModel: ResetPasswordViewModel
    @Environment(\.dismiss) var dismiss
    
    init(email: String) {
        _viewModel = StateObject(wrappedValue: ResetPasswordViewModel(email: email))
    }
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.fieldSpacing) {
                    // Header
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Reset Password")
                            .h1Style()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Enter the 6-digit code sent to")
                                .font(AppFont.bodyRegular())
                                .foregroundColor(.textSecondary)
                            Text(viewModel.email)
                                .font(AppFont.bodyRegular())
                                .foregroundColor(.primaryGold)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Spacing.xl)
                    .padding(.bottom, Spacing.lg)
                    
                    // Verification Code
                    AppTextField(
                        label: "Verification Code",
                        placeholder: "Enter 6-digit code",
                        text: $viewModel.code,
                        state: viewModel.codeState,
                        errorMessage: viewModel.codeError,
                        showCheckmark: viewModel.codeState == .success,
                        keyboardType: .numberPad
                    )
                    
                    // New Password
                    AppTextField(
                        label: "New Password",
                        placeholder: "Enter your new password",
                        text: $viewModel.password,
                        isSecure: true,
                        state: viewModel.passwordState,
                        errorMessage: viewModel.passwordError
                    )
                    
                    // Password Requirements
                    Text("At least 8 characters, 1 uppercase, number or special character")
                        .font(AppFont.bodySmall())
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Password Strength Indicator
                    if !viewModel.password.isEmpty {
                        PasswordStrengthView(strength: viewModel.passwordStrength)
                    }
                    
                    // Confirm Password
                    AppTextField(
                        label: "Confirm New Password",
                        placeholder: "Confirm your new password",
                        text: $viewModel.confirmPassword,
                        isSecure: true,
                        state: viewModel.confirmPasswordState,
                        errorMessage: viewModel.confirmPasswordError,
                        showCheckmark: viewModel.confirmPasswordState == .success
                    )
                    
                    // Reset Password Button
                    PrimaryButton(
                        title: "Reset Password",
                        action: { viewModel.resetPassword() },
                        isLoading: viewModel.isLoading,
                        isEnabled: viewModel.isFormValid
                    )
                    .padding(.top, Spacing.md)
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success", isPresented: $viewModel.shouldNavigateToLogin) {
            Button("OK") {
                // Navigate back to login
                dismiss()
            }
        } message: {
            Text("Password reset successful. Please login with your new password.")
        }
    }
}
