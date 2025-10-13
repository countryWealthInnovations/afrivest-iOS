//
//  WithdrawView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import SwiftUI

struct WithdrawView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = WithdrawViewModel()
    
    var body: some View {
        ZStack {
            Color.backgroundDark1.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        // Phone Number
                        phoneNumberSection
                        
                        // Amount
                        amountSection
                        
                        // Error Message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .bodyRegularStyle()
                                .foregroundColor(.errorRed)
                        }
                        
                        // Info Box
                        infoBox
                        
                        Spacer().frame(height: Spacing.xl)
                        
                        // Withdraw Button
                        PrimaryButton(
                            title: "Withdraw",
                            action: { viewModel.initiateWithdraw() },
                            isLoading: viewModel.isLoading,
                            isEnabled: viewModel.isFormValid
                        )
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.top, Spacing.md)
                }
            }
            
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $viewModel.shouldNavigateToSuccess) {
            if let response = viewModel.withdrawResponse {
                WithdrawSuccessView(
                    reference: response.reference,
                    amount: response.amount,
                    currency: response.currency,
                    phoneNumber: viewModel.phoneNumber
                )
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            Text("Withdraw Money")
                .h2Style()
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.top, Spacing.md)
    }
    
    // MARK: - Phone Number Section
    private var phoneNumberSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Phone Number")
                .labelStyle()
            
            HStack(spacing: 0) {
                // Uganda Flag and Code
                HStack(spacing: 4) {
                    Text("🇺🇬")
                        .font(.system(size: 20))
                    Text("+256")
                        .font(AppFont.bodyLarge())
                        .foregroundColor(.textPrimary)
                }
                .padding(.leading, Spacing.md)
                .padding(.trailing, Spacing.sm)
                
                Divider()
                    .frame(height: 24)
                    .background(Color.borderDefault)
                
                TextField("700000001", text: $viewModel.phoneNumber)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(.textPrimary)
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.leading, Spacing.sm)
                    .onChange(of: viewModel.phoneNumber) { newValue in
                        viewModel.phoneNumber = newValue.filter { $0.isNumber }
                        if viewModel.phoneNumber.count > 9 {
                            viewModel.phoneNumber = String(viewModel.phoneNumber.prefix(9))
                        }
                    }
                
                if viewModel.phoneState == .success {
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
                    .stroke(viewModel.phoneState == .error ? Color.errorRed : Color.borderDefault, lineWidth: 1)
            )
            
            if viewModel.phoneState == .error {
                Text("Invalid phone number format")
                    .font(.system(size: 12))
                    .foregroundColor(.errorRed)
            } else if viewModel.phoneNumber.count >= 2 {
                if viewModel.selectedNetwork == "MTN" {
                    Text("MTN detected ✓")
                        .font(.system(size: 12))
                        .foregroundColor(.successGreen)
                } else if viewModel.selectedNetwork == "AIRTEL" {
                    Text("Airtel detected ✓")
                        .font(.system(size: 12))
                        .foregroundColor(.successGreen)
                } else {
                    Text("MTN: 77, 78, 76, 79 | Airtel: 70, 74, 75")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
            } else {
                Text("MTN: 77, 78, 76, 79 | Airtel: 70, 74, 75")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
    // MARK: - Amount Section
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Amount (UGX)")
                .labelStyle()
            
            TextField("Enter amount (min 10,000)", text: $viewModel.amount)
                .keyboardType(.numberPad)
                .font(AppFont.bodyLarge())
                .foregroundColor(.textPrimary)
                .padding()
                .background(Color.inputBackground)
                .cornerRadius(Spacing.radiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .stroke(Color.borderDefault, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Info Box
    private var infoBox: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "info.circle")
                .foregroundColor(.textSecondary)
            
            Text("Funds will be sent to your mobile money account within 5 minutes")
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.md)
        .background(Color.inputBackground)
        .cornerRadius(Spacing.radiusMedium)
    }
}
