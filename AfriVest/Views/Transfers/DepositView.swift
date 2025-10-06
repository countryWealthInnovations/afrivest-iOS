//
//  DepositView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 06/10/2025.
//


import SwiftUI

struct DepositView: View {
    
    @StateObject private var viewModel = DepositViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.backgroundDark1
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    
                    // Amount Input
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Amount")
                            .labelStyle()
                        
                        HStack {
                            Text(viewModel.selectedCurrency)
                                .font(AppFont.bodyLarge())
                                .foregroundColor(.textPrimary)
                                .frame(width: 50)
                            
                            TextField("0", text: $viewModel.amount)
                                .keyboardType(.numberPad)
                                .font(AppFont.bodyLarge())
                                .foregroundColor(.textPrimary)
                                .padding()
                                .background(Color.inputBackground)
                                .cornerRadius(Spacing.radiusMedium)
                        }
                    }
                    
                    // Currency Picker
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Currency")
                            .labelStyle()
                        
                        Picker("Currency", selection: $viewModel.selectedCurrency) {
                            ForEach(viewModel.currencies, id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Phone Number Field
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
                    }
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.errorRed)
                            .bodyRegularStyle()
                    }
                    
                    // Success Message
                    if let success = viewModel.successMessage {
                        Text(success)
                            .foregroundColor(.successGreen)
                            .bodyRegularStyle()
                    }
                    
                    Spacer()
                    
                    // Deposit Button
                    PrimaryButton(
                        title: "Deposit",
                        action: {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootVC = windowScene.windows.first?.rootViewController {
                                viewModel.initiateDeposit(from: rootVC)
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isEnabled: !viewModel.amount.isEmpty && !viewModel.phoneNumber.isEmpty
                    )
                }
                .padding(Spacing.screenHorizontal)
            }
        }
        .navigationTitle("Deposit Money")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.shouldNavigateToDashboard) { should in
            if should {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
