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
        case bank = "Bank"
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
                                // Card deposit temporarily disabled
                                ForEach(DepositMethod.allCases.filter { $0 != .card }, id: \.self) { method in
                                    Text(method.rawValue).tag(method)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: selectedMethod) { newValue in
                                viewModel.amount = ""
                                if newValue == .bank {
                                    viewModel.setBankSubMethod("virtual_account")
                                }
                            }
                        }
                        
                        // Mobile Money Fields
                        if selectedMethod == .mobileMoney {
                            mobileMoneySectionView
                        }
                        
                        // Card Fields
                        if selectedMethod == .card {
                            cardSectionView
                        }
                        
                        // Bank Fields (Virtual Account + Internet Banking merged)
                        if selectedMethod == .bank {
                            bankSectionView
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Amount (\(selectedMethod == .bank ? viewModel.selectedBankCurrency : viewModel.selectedCurrency))")
                                .labelStyle()
                            
                            TextField("Enter amount", text: $viewModel.amount)
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
                            
                            // Inline minimum-amount hint — always visible, updates per currency/method
                            Text("Minimum: \(minimumHintCurrency) \(FeeCalculator.formatCurrency(minimumHintAmount))")
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)
                        }
                        
                        // Fee Breakdown Preview
                        if let amountValue = Double(viewModel.amount), amountValue > 0 {
                            depositFeePreview(amount: amountValue)
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
                            
                            Text(infoBoxText)
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
                                } else if selectedMethod == .card {
                                    viewModel.initiateCardDeposit()
                                } else if selectedMethod == .bank {
                                    viewModel.initiateBankDeposit()
                                }
                            },
                            isLoading: viewModel.isLoading,
                            isEnabled: selectedMethod == .mobileMoney
                            ? viewModel.isFormValid
                            : selectedMethod == .card
                            ? viewModel.isCardFormValid
                            : viewModel.isBankFormValid
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
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $viewModel.shouldNavigateToBankConfirmation) {
            if let details = viewModel.bankConfirmationDetails {
                BankTransferConfirmationView(details: details)
            }
        }
        .alert("Payment Initiated", isPresented: $viewModel.showPushNotificationMessage) {
            Button("OK") { presentationMode.wrappedValue.dismiss() }
        } message: {
            Text("Please approve the payment prompt on your phone.\nReference: \(viewModel.pushNotificationReference)")
        }
        .alert("Deposit Failed", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .fullScreenCover(isPresented: $viewModel.shouldNavigateToWebView) {
            if let response = viewModel.depositResponse,
               let paymentUrl = response.paymentData.paymentUrl {
                PaymentWebView(
                    paymentUrl: paymentUrl,
                    transactionId: response.transactionId,
                    reference: response.reference,
                    amount: String(response.amount),
                    currency: response.currency,
                    network: response.network ?? "MTN"
                )
            }
        }
    }
    
    // MARK: - Inline hint helpers
    private var minimumHintCurrency: String {
        selectedMethod == .bank ? viewModel.selectedBankCurrency : viewModel.selectedCurrency
    }
    
    private var minimumHintAmount: Double {
        switch selectedMethod {
        case .bank: return viewModel.bankMinimumAmount
        case .card: return 4999
        case .mobileMoney: return viewModel.minimumAmount
        }
    }
    
    private var infoBoxText: String {
        if selectedMethod == .bank {
            return viewModel.bankSubMethod == "internet_banking"
            ? "You will be redirected to your bank to complete this payment."
            : "A virtual bank account will be generated for you to transfer into."
        }
        return "You will receive a prompt on your phone to approve the payment"
    }
    
    // MARK: - Fee Preview
    private func depositFeePreview(amount: Double) -> some View {
        let isBankFlow = selectedMethod == .bank
        let method = selectedMethod == .card ? "card" : "mobile_money"
        let currency = isBankFlow ? viewModel.selectedBankCurrency : viewModel.selectedCurrency
        let flwFee = FeeCalculator.flutterwaveCollectionFee(amount: amount, currency: currency, method: method)
        let total = amount + flwFee
        let minAmount = isBankFlow ? viewModel.bankMinimumAmount : viewModel.minimumAmount
        let isBelowMin = amount < minAmount
        
        return VStack(alignment: .leading, spacing: Spacing.sm) {
            if isBelowMin {
                Text("Minimum amount is \(currency) \(FeeCalculator.formatCurrency(minAmount))")
                    .font(AppFont.bodySmall())
                    .foregroundColor(.errorRed)
            }
            HStack {
                Text("Amount")
                    .bodyRegularStyle()
                    .foregroundColor(.textSecondary)
                Spacer()
                Text("\(currency) \(FeeCalculator.formatCurrency(amount))")
                    .bodyRegularStyle()
                    .foregroundColor(.textPrimary)
            }
            HStack {
                Text("Transaction fee")
                    .bodyRegularStyle()
                    .foregroundColor(.textSecondary)
                Spacer()
                Text(flwFee == 0
                     ? "Free"
                     : "\(currency) \(FeeCalculator.formatCurrency(flwFee))")
                .bodyRegularStyle()
                .foregroundColor(flwFee == 0 ? .successGreen : .textPrimary)
            }
            Divider().background(Color.borderDefault)
            HStack {
                Text("You Pay")
                    .bodyLargeStyle()
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("\(currency) \(FeeCalculator.formatCurrency(total))")
                    .bodyLargeStyle()
                    .foregroundColor(.primaryGold)
            }
            Text("* Your wallet will be credited \(currency) \(FeeCalculator.formatCurrency(amount))")
                .font(AppFont.footnote())
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.md)
        .background(Color.inputBackground)
        .cornerRadius(Spacing.radiusMedium)
    }
    
    // MARK: - Mobile Money Section
    private var mobileMoneySectionView: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            
            // Currency Picker
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Deposit Currency")
                    .labelStyle()
                Menu {
                    ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                        Button(currency) { viewModel.selectedCurrency = currency }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedCurrency)
                            .font(AppFont.bodyLarge())
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.textSecondary)
                    }
                    .padding()
                    .background(Color.inputBackground)
                    .cornerRadius(Spacing.radiusMedium)
                    .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
                }
            }
            
            // Network Picker
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Network")
                    .labelStyle()
                Menu {
                    ForEach(viewModel.availableNetworks, id: \.self) { network in
                        Button(network) { viewModel.selectedNetwork = network }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedNetwork)
                            .font(AppFont.bodyLarge())
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.textSecondary)
                    }
                    .padding()
                    .background(Color.inputBackground)
                    .cornerRadius(Spacing.radiusMedium)
                    .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
                }
            }
            
            // Phone Number
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Phone Number")
                    .labelStyle()
                
                HStack(spacing: 0) {
                    if !viewModel.dialCode.isEmpty {
                        Text(viewModel.dialCode)
                            .font(AppFont.bodyLarge())
                            .foregroundColor(.textPrimary)
                            .padding(.leading, Spacing.md)
                            .padding(.trailing, Spacing.sm)
                        
                        Divider()
                            .frame(height: 24)
                            .background(Color.borderDefault)
                    }
                    
                    TextField("Enter phone number", text: $viewModel.phoneNumber)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(.textPrimary)
                        .keyboardType(.numberPad)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.leading, Spacing.sm)
                        .onChange(of: viewModel.phoneNumber) { newValue in
                            viewModel.phoneNumber = newValue.filter { $0.isNumber }
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
                    Text("Invalid phone number")
                        .font(.system(size: 12))
                        .foregroundColor(.errorRed)
                }
            }
        }
    }
    
    // MARK: - Card Section
    private var cardSectionView: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            
            // Card Currency Picker
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Card Currency")
                    .labelStyle()
                Menu {
                    ForEach(["UGX", "USD", "EUR", "GBP", "KES", "NGN", "ZAR", "CAD", "AED"], id: \.self) { currency in
                        Button(currency) { viewModel.selectedCurrency = currency }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedCurrency)
                            .font(AppFont.bodyLarge())
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.textSecondary)
                    }
                    .padding()
                    .background(Color.inputBackground)
                    .cornerRadius(Spacing.radiusMedium)
                    .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
                }
            }
            
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
    
    // MARK: - Bank Section (merged: Virtual Account + Internet Banking)
    private var bankSectionView: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            
            // Sub-method toggle
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Method")
                    .labelStyle()
                Picker("", selection: Binding(
                    get: { viewModel.bankSubMethod },
                    set: { viewModel.setBankSubMethod($0) }
                )) {
                    Text("Virtual Account").tag("virtual_account")
                    Text("Internet Banking").tag("internet_banking")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            if viewModel.bankSubMethod == "virtual_account" {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Currency")
                        .labelStyle()
                    Menu {
                        ForEach(["NGN", "GHS"], id: \.self) { currency in
                            Button(currency) { viewModel.setVirtualAccountCurrency(currency) }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedBankCurrency)
                                .font(AppFont.bodyLarge())
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textSecondary)
                        }
                        .padding()
                        .background(Color.inputBackground)
                        .cornerRadius(Spacing.radiusMedium)
                        .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Country")
                        .labelStyle()
                    Menu {
                        ForEach(["NG", "UK", "EU"], id: \.self) { country in
                            Button(country) {
                                viewModel.selectedPayWithBankCountry = country
                                viewModel.applyPayWithBankCountry()
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedPayWithBankCountry)
                                .font(AppFont.bodyLarge())
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textSecondary)
                        }
                        .padding()
                        .background(Color.inputBackground)
                        .cornerRadius(Spacing.radiusMedium)
                        .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
                    }
                }
            }
        }
    }
}

// MARK: - Keyboard dismissal helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
