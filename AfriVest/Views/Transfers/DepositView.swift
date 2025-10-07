//
//  DepositView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 06/10/2025.
//

import SwiftUI

struct DepositView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var amount: String = ""
    @State private var selectedCurrency: String = "UGX"
    @State private var phoneNumber: String = ""
    @State private var phoneState: TextFieldState = .normal
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isLoading: Bool = false
    
    let currencies = ["UGX", "USD", "EUR", "GBP"]
    
    var body: some View {
        ZStack {
            Color.backgroundDark1
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back Button Header
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
                        .font(AppFont.heading2())
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        
                        // Amount Input
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Amount")
                                .labelStyle()
                            
                            HStack {
                                Text(selectedCurrency)
                                    .font(AppFont.bodyLarge())
                                    .foregroundColor(.textPrimary)
                                    .frame(width: 50)
                                
                                TextField("0", text: $amount)
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
                            
                            Picker("Currency", selection: $selectedCurrency) {
                                ForEach(currencies, id: \.self) { currency in
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
                                text: $phoneNumber,
                                state: phoneState,
                                errorMessage: "Invalid phone number format",
                                showCheckmark: phoneState == .success
                            )
                            .onChange(of: phoneNumber) { newValue in
                                if !newValue.isEmpty {
                                    phoneState = Validators.isValidPhoneNumber(newValue) ? .success : .error
                                } else {
                                    phoneState = .normal
                                }
                            }
                            
                        }
                        
                        // Error Message
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.errorRed)
                                .bodyRegularStyle()
                        }
                        
                        // Success Message
                        if let success = successMessage {
                            Text(success)
                                .foregroundColor(.successGreen)
                                .bodyRegularStyle()
                        }
                        
                        Spacer()
                        
                        // Deposit Button
                        PrimaryButton(
                            title: "Deposit",
                            action: {
                                print("🔘 Deposit button tapped")
                                // Add your deposit logic here
                            },
                            isLoading: isLoading,
                            isEnabled: !amount.isEmpty && phoneState == .success
                        )
                    }
                    .padding(Spacing.screenHorizontal)
                    .padding(.top, Spacing.md)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
