//
//  ChangePasswordView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 27/12/2025.
//


import SwiftUI

struct ChangePasswordView: View {
    @StateObject private var viewModel = ChangePasswordViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                // Header with Back Button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("Change Password")
                        .font(AppFont.heading3())
                        .foregroundColor(Color.textPrimary)
                    Spacer()
                    // Placeholder for symmetry
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                
                ScrollView {
                    VStack(spacing: Spacing.fieldSpacing) {
                        // Current Password
                        AppTextField(
                            label: "Current Password",
                            placeholder: "Enter your current password",
                            text: $viewModel.currentPassword,
                            isSecure: true,
                            state: viewModel.currentPasswordState,
                            errorMessage: viewModel.currentPasswordError
                        )
                        .padding(.top, Spacing.md)
                        
                        // New Password
                        AppTextField(
                            label: "New Password",
                            placeholder: "Enter your new password",
                            text: $viewModel.newPassword,
                            isSecure: true,
                            state: viewModel.newPasswordState,
                            errorMessage: viewModel.newPasswordError
                        )
                        
                        // Password Requirements
                        Text("At least 8 characters, 1 uppercase, number or special character")
                            .font(AppFont.bodySmall())
                            .foregroundColor(.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Password Strength Indicator
                        if !viewModel.newPassword.isEmpty {
                            PasswordStrengthView(strength: viewModel.passwordStrength)
                        }
                        
                        // Confirm New Password
                        AppTextField(
                            label: "Confirm New Password",
                            placeholder: "Confirm your new password",
                            text: $viewModel.confirmPassword,
                            isSecure: true,
                            state: viewModel.confirmPasswordState,
                            errorMessage: viewModel.confirmPasswordError,
                            showCheckmark: viewModel.confirmPasswordState == .success
                        )
                        
                        // Change Password Button
                        PrimaryButton(
                            title: "Change Password",
                            action: { viewModel.changePassword() },
                            isLoading: viewModel.isLoading,
                            isEnabled: viewModel.isFormValid
                        )
                        .padding(.top, Spacing.lg)
                        
                        Spacer()
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                }
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success", isPresented: $viewModel.shouldDismiss) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Password changed successfully!")
        }
    }
}
