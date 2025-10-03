//
//  ForgotPasswordView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                // Back Button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                
                ScrollView {
                    VStack(spacing: Spacing.fieldSpacing) {
                        // Header
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Forgot Password?")
                                .h1Style()
                            
                            Text("Enter your email address and we'll send you a code to reset your password.")
                                .bodyRegularStyle()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, Spacing.lg)
                        .padding(.bottom, Spacing.xl)
                        
                        // Email
                        AppTextField(
                            label: "Email",
                            placeholder: "Enter your email",
                            text: $viewModel.email,
                            state: viewModel.emailState,
                            errorMessage: viewModel.emailError,
                            showCheckmark: viewModel.emailState == .success,
                            keyboardType: .emailAddress
                        )
                        
                        // Send Code Button
                        PrimaryButton(
                            title: "Send Reset Code",
                            action: { viewModel.sendResetCode() },
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
        .navigationBarHidden(true)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .fullScreenCover(isPresented: $viewModel.shouldNavigateToResetPassword) {
            ResetPasswordView(email: viewModel.email)
        }
    }
}
