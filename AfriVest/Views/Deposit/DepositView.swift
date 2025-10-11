//
//  DepositView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 06/10/2025.
//

import SwiftUI

struct DepositView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = DepositViewModel()
    @State private var showWebView = false
    
    var body: some View {
        ZStack {
            Color.backgroundDark1
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    Text("Deposit Money")
                        .h2Style()
                    
                    Spacer()
                    
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.top, Spacing.md)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        
                        // Network Selection
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Select Network")
                                .labelStyle()
                            
                            HStack(spacing: Spacing.sm) {
                                NetworkButton(
                                    title: "MTN",
                                    isSelected: viewModel.selectedNetwork == "MTN",
                                    action: { viewModel.selectedNetwork = "MTN" }
                                )
                                
                                NetworkButton(
                                    title: "Airtel",
                                    isSelected: viewModel.selectedNetwork == "AIRTEL",
                                    action: { viewModel.selectedNetwork = "AIRTEL" }
                                )
                            }
                        }
                        
                        // Phone Number
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Phone Number")
                                .labelStyle()
                            
                            PhoneTextField(
                                label: "",
                                text: $viewModel.phoneNumber,
                                state: viewModel.phoneState,
                                errorMessage: "Invalid phone number format",
                                showCheckmark: viewModel.phoneState == .success
                            )
                            
                            Text("MTN: 077, 078, 076 | Airtel: 070, 074, 075")
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Amount (UGX)")
                                .labelStyle()
                            
                            TextField("Enter amount (min 1,000)", text: $viewModel.amount)
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
                        
                        // Error Message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .bodyRegularStyle()
                                .foregroundColor(.errorRed)
                        }
                        
                        // Info Box
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.textSecondary)
                            
                            Text("You will receive a prompt on your phone to approve the payment")
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(Spacing.md)
                        .background(Color.inputBackground)
                        .cornerRadius(Spacing.radiusMedium)
                        
                        Spacer().frame(height: Spacing.xl)
                        
                        // Deposit Button
                        PrimaryButton(
                            title: "Continue",
                            action: { viewModel.initiateDeposit() },
                            isLoading: viewModel.isLoading,
                            isEnabled: viewModel.isFormValid
                        )
                    }
                    .padding(Spacing.screenHorizontal)
                    .padding(.top, Spacing.md)
                }
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $viewModel.shouldNavigateToWebView) {
            if let response = viewModel.depositResponse,
               let paymentUrl = response.paymentData.paymentUrl {
                PaymentWebView(
                    paymentUrl: paymentUrl,
                    transactionId: response.transactionId,
                    reference: response.reference,
                    amount: response.amount,
                    currency: response.currency,
                    network: response.network ?? "MTN"
                )
            }
        }
    }
}

// MARK: - Network Button
struct NetworkButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.button())
                .foregroundColor(isSelected ? .buttonPrimaryText : .textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: Spacing.buttonHeight)
                .background(isSelected ? Color.primaryGold : Color.inputBackground)
                .cornerRadius(Spacing.radiusMedium)
        }
    }
}
