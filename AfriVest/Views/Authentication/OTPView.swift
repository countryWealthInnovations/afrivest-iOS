//
//  OTPView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import SwiftUI

struct OTPView: View {
    @StateObject private var viewModel: OTPViewModel
    @Environment(\.dismiss) var dismiss
    
    init(email: String, from: String) {
        _viewModel = StateObject(wrappedValue: OTPViewModel(email: email, from: from))
    }
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Verify Your Email")
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
                .padding(.top, Spacing.xxl)
                
                // OTP Boxes
                OTPBoxes(otpCode: $viewModel.otpCode)
                    .padding(.vertical, Spacing.lg)
                
                // Timer
                if viewModel.timeRemaining > 0 {
                    Text("Code expires in \(viewModel.formattedTime)")
                        .font(AppFont.bodyRegular())
                        .foregroundColor(viewModel.timeRemaining < 60 ? .errorRed : .textSecondary)
                }
                
                // Resend
                HStack {
                    Text("Didn't receive the code?")
                        .font(AppFont.bodyRegular())
                        .foregroundColor(.textSecondary)
                    
                    Button(action: { viewModel.resendOTP() }) {
                        Text("Resend")
                            .font(AppFont.bodyRegular())
                            .foregroundColor(viewModel.canResend ? .primaryGold : .textDisabled)
                    }
                    .disabled(!viewModel.canResend)
                }
                
                Spacer()
                
                // Verify Button
                PrimaryButton(
                    title: "Verify",
                    action: { viewModel.verifyOTP() },
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.otpCode.count == 6
                )
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.bottom, Spacing.xl)
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
        .fullScreenCover(isPresented: $viewModel.shouldNavigateToDashboard) {
            DashboardView()
        }
    }
}
