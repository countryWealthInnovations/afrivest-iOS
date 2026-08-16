//
//  PhoneOTPView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import SwiftUI

struct PhoneOTPView: View {
    @StateObject private var viewModel: PhoneOTPViewModel
    @Environment(\.dismiss) private var dismiss
    var onVerified: (() -> Void)?

    init(phone: String, onVerified: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: PhoneOTPViewModel(phone: phone))
        self.onVerified = onVerified
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Verify Your Phone").h1Style()
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Enter the 6-digit code sent by SMS to")
                            .font(AppFont.bodyRegular())
                            .foregroundColor(.textSecondary)
                        Text(viewModel.phone)
                            .font(AppFont.bodyRegular())
                            .foregroundColor(.primaryGold)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Spacing.xxl)

                OTPBoxes(otpCode: $viewModel.otpCode)
                    .padding(.vertical, Spacing.lg)

                if viewModel.timeRemaining > 0 {
                    Text("Code expires in \(viewModel.formattedTime)")
                        .font(AppFont.bodyRegular())
                        .foregroundColor(viewModel.timeRemaining < 60 ? .errorRed : .textSecondary)
                }

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

                PrimaryButton(
                    title: "Verify",
                    action: { viewModel.verifyOTP() },
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.otpCode.count == 6
                )
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.bottom, Spacing.xl)
            }
            .padding(.horizontal, Spacing.screenHorizontal)

            if viewModel.isLoading { LoadingOverlay() }
        }
        .overlay(alignment: .topLeading) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.primaryGold)
                    .padding(12)
            }
            .padding(.top, 8)
            .padding(.leading, 8)
        }
        .onChange(of: viewModel.verified) { done in
            if done {
                UserDefaultsManager.shared.set(true, forKey: "phone_verified")
                onVerified?()
                dismiss()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .navigationBarBackButtonHidden(true)
    }
}
