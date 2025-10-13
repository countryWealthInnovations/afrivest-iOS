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
    @FocusState private var focusedField: CardField?
    
    enum CardField {
        case expiryMonth
        case expiryYear
        case cvv
    }
    
    enum DepositMethod: String, CaseIterable {
        case mobileMoney = "Mobile Money"
        case card = "Card Deposit"
    }
    
    @State private var selectedMethod: DepositMethod = .mobileMoney
    
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
                        
                        // Payment Method Selector
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Payment Method")
                                .labelStyle()
                            
                            Picker("", selection: $selectedMethod) {
                                ForEach(DepositMethod.allCases, id: \.self) { method in
                                    Text(method.rawValue).tag(method)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Mobile Money Fields
                        if selectedMethod == .mobileMoney {
                            mobileMoneySectionView
                        }
                        
                        // Card Fields
                        if selectedMethod == .card {
                            cardSectionView
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Amount (UGX)")
                                .labelStyle()
                            
                            TextField("Enter amount (min 5,000)", text: $viewModel.amount)
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
                            action: {
                                if selectedMethod == .mobileMoney {
                                    viewModel.initiateDeposit()
                                } else {
                                    viewModel.initiateCardDeposit()
                                }
                            },
                            isLoading: viewModel.isLoading,
                            isEnabled: selectedMethod == .mobileMoney ? viewModel.isFormValid : viewModel.isCardFormValid
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
    // MARK: - Mobile Money Section
    private var mobileMoneySectionView: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Phone Number
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Phone Number")
                    .labelStyle()
                
                HStack(spacing: 0) {
                    // Uganda Flag and Code (hardcoded)
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
    }
    
    // MARK: - Card Section
    private var cardSectionView: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Card Number
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Card Number")
                    .labelStyle()
                
                TextField("1234 5678 9012 3456", text: $viewModel.cardNumber)
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
                    .onChange(of: viewModel.cardNumber) { newValue in
                        // Format card number with spaces
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count > 16 {
                            viewModel.cardNumber = String(filtered.prefix(16))
                        } else {
                            var formatted = ""
                            for (index, char) in filtered.enumerated() {
                                if index > 0 && index % 4 == 0 {
                                    formatted += " "
                                }
                                formatted += String(char)
                            }
                            viewModel.cardNumber = formatted
                        }
                    }
            }
            
            // CVV and Expiry Row
            HStack(spacing: Spacing.md) {
                // Expiry Month
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Expiry Month")
                        .labelStyle()
                    
                    TextField("MM", text: $viewModel.expiryMonth)
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
                        .focused($focusedField, equals: .expiryMonth)
                        .onChange(of: viewModel.expiryMonth) { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 2 {
                                viewModel.expiryMonth = String(filtered.prefix(2))
                                focusedField = .expiryYear
                            } else {
                                viewModel.expiryMonth = filtered
                                if filtered.count == 2 {
                                    focusedField = .expiryYear
                                }
                            }
                        }
                }
                
                // Expiry Year
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Expiry Year")
                        .labelStyle()
                    
                    TextField("YY", text: $viewModel.expiryYear)
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
                        .focused($focusedField, equals: .expiryYear)
                        .onChange(of: viewModel.expiryYear) { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 2 {
                                viewModel.expiryYear = String(filtered.prefix(2))
                                focusedField = .cvv
                            } else {
                                viewModel.expiryYear = filtered
                                if filtered.count == 2 {
                                    focusedField = .cvv
                                }
                            }
                        }
                }
                
                // CVV
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("CVV")
                        .labelStyle()
                    
                    TextField("123", text: $viewModel.cvv)
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
                        .focused($focusedField, equals: .cvv)
                        .onChange(of: viewModel.cvv) { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 3 {
                                viewModel.cvv = String(filtered.prefix(3))
                            } else {
                                viewModel.cvv = filtered
                            }
                        }
                }
            }
        }
    }
}
