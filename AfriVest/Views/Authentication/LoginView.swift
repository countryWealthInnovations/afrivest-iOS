//
//  LoginView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import SwiftUI
import FirebaseMessaging

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.fieldSpacing) {
                    // Header
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Welcome back!")
                            .h1Style()
                        
                        Text("Access your investments, and remittances.")
                            .bodyRegularStyle()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Spacing.xl)
                    .padding(.bottom, Spacing.lg)
                    
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
                    
                    // Password
                    AppTextField(
                        label: "Password",
                        placeholder: "Enter your password",
                        text: $viewModel.password,
                        isSecure: true,
                        state: viewModel.passwordState,
                        errorMessage: viewModel.passwordError
                    )
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        Button(action: { viewModel.showForgotPassword = true }) {
                            Text("Forgot Password?")
                                .font(AppFont.bodyRegular())
                                .foregroundColor(.primaryGold)
                        }
                    }
                    
                    // Login Button
                    PrimaryButton(
                        title: "Log in",
                        action: { viewModel.login() },
                        isLoading: viewModel.isLoading,
                        isEnabled: viewModel.isFormValid
                    )
                    .padding(.top, Spacing.md)
                    
                    // Register Link
                    HStack {
                        Text("Don't have an account?")
                            .font(AppFont.bodyRegular())
                            .foregroundColor(.textSecondary)
                        
                        NavigationLink(destination: RegisterView()) {
                            Text("Create an account")
                                .font(AppFont.bodyRegular())
                                .foregroundColor(.primaryGold)
                        }
                    }
                    .padding(.top, Spacing.md)
                    
                    // Biometric Button
                    if viewModel.biometricAvailable {
                        BiometricButton {
                            viewModel.loginWithBiometric()
                        }
                        .padding(.top, Spacing.lg)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .alert("Enable Biometric Login", isPresented: $viewModel.shouldPromptBiometricSetup) {
            Button("Enable") {
                viewModel.enableBiometric()
            }
            Button("Not Now", role: .cancel) {
                viewModel.skipBiometric()
            }
        } message: {
            Text("Would you like to use Face ID to login faster next time?")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .fullScreenCover(isPresented: $viewModel.showForgotPassword) {
            ForgotPasswordView()
        }
        .fullScreenCover(isPresented: $viewModel.shouldNavigateToOTP) {
            OTPView(email: viewModel.email, from: "login")
        }
        .fullScreenCover(isPresented: $viewModel.shouldNavigateToDashboard) {
            DashboardView()
        }
    }
}
