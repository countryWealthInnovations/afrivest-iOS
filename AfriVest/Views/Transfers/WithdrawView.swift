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
                headerSection
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        
                        // Payout Method
                        payoutMethodSection
                        
                        // Currency Picker
                        currencySection
                        
                        // Mobile Money or Bank Transfer fields
                        if viewModel.payoutMethod == .mobileMoney {
                            phoneNumberSection
                            networkSection
                        } else {
                            bankTransferSection
                        }
                        
                        // Amount
                        amountSection
                        
                        // Fee Display
                        if viewModel.totalAmount > 0 {
                            feeDisplaySection
                        }
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .bodyRegularStyle()
                                .foregroundColor(.errorRed)
                        }
                        
                        infoBox
                        
                        Spacer().frame(height: Spacing.xl)
                        
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
    
    private var payoutMethodSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Payout Method")
                .labelStyle()
            Picker("", selection: $viewModel.payoutMethod) {
                ForEach(WithdrawViewModel.PayoutMethod.allCases, id: \.self) { method in
                    Text(method.rawValue).tag(method)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    // MARK: - Currency
    private var currencySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Payout Currency")
                .labelStyle()
            let currencies = viewModel.payoutMethod == .mobileMoney
            ? Array(viewModel.mobileMoneyNetworks.keys).sorted()
            : viewModel.bankCurrencies
            Menu {
                ForEach(currencies, id: \.self) { currency in
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
    }
    
    // MARK: - Network
    private var networkSection: some View {
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
    }
    
    // MARK: - Phone Number
    private var phoneNumberSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Phone Number")
                .labelStyle()
            HStack(spacing: 0) {
                TextField("Enter phone number", text: $viewModel.phoneNumber)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(.textPrimary)
                    .keyboardType(.phonePad)
                    .padding()
                if viewModel.phoneState == .success {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.successGreen)
                        .padding(.trailing, Spacing.md)
                }
            }
            .background(Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(
                viewModel.phoneState == .error ? Color.errorRed : Color.borderDefault, lineWidth: 1))
            if viewModel.phoneState == .error {
                Text("Invalid phone number")
                    .font(.system(size: 12)).foregroundColor(.errorRed)
            }
        }
    }
    
    // MARK: - Bank Transfer
    private var bankTransferSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Bank Code")
                    .labelStyle()
                TextField("Enter bank code", text: $viewModel.bankCode)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(.textPrimary)
                    .padding()
                    .background(Color.inputBackground)
                    .cornerRadius(Spacing.radiusMedium)
                    .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
            }
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Account Number")
                    .labelStyle()
                TextField("Enter account number", text: $viewModel.accountNumber)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(.textPrimary)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.inputBackground)
                    .cornerRadius(Spacing.radiusMedium)
                    .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
            }
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Account Name")
                    .labelStyle()
                TextField("Enter account name", text: $viewModel.accountName)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(.textPrimary)
                    .padding()
                    .background(Color.inputBackground)
                    .cornerRadius(Spacing.radiusMedium)
                    .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
            }
        }
    }
    
    // MARK: - Amount
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Amount (\(viewModel.selectedCurrency))")
                .labelStyle()
            TextField("Enter amount", text: $viewModel.amount)
                .keyboardType(.numberPad)
                .font(AppFont.bodyLarge())
                .foregroundColor(.textPrimary)
                .padding()
                .background(Color.inputBackground)
                .cornerRadius(Spacing.radiusMedium)
                .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
        }
    }
    
    // MARK: - Info Box
    private var infoBox: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "info.circle")
                .foregroundColor(.textSecondary)
            Text(viewModel.payoutMethod == .mobileMoney
                 ? "Funds will be sent to your mobile money account within 5 minutes"
                 : "Bank transfers may take 1–3 business days")
            .font(.system(size: 12))
            .foregroundColor(.textSecondary)
        }
        .padding(Spacing.md)
        .background(Color.inputBackground)
        .cornerRadius(Spacing.radiusMedium)
    }
    
    // MARK: - Fee Display
    private var feeDisplaySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Amount")
                    .bodyRegularStyle()
                    .foregroundColor(.textSecondary)
                Spacer()
                if let val = Double(viewModel.amount) {
                    Text("\(viewModel.selectedCurrency) \(FeeCalculator.formatCurrency(val))")
                        .bodyRegularStyle()
                        .foregroundColor(.textPrimary)
                }
            }
            HStack {
                Text("Transaction fee")
                    .bodyRegularStyle()
                    .foregroundColor(.textSecondary)
                Spacer()
                Text("\(viewModel.selectedCurrency) \(FeeCalculator.formatCurrency(viewModel.transactionFee))")
                    .bodyRegularStyle()
                    .foregroundColor(.textPrimary)
            }
            Divider().background(Color.borderDefault)
            HStack {
                Text("Total Debited")
                    .bodyLargeStyle()
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("\(viewModel.selectedCurrency) \(FeeCalculator.formatCurrency(viewModel.totalAmount))")
                    .bodyLargeStyle()
                    .foregroundColor(.primaryGold)
            }
            if viewModel.feeConfirmedByAPI {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.successGreen)
                        .font(.system(size: 12))
                    Text("Fees confirmed")
                        .font(AppFont.footnote())
                        .foregroundColor(.successGreen)
                }
            } else {
                Text("* Estimated — confirmed on submit")
                    .font(AppFont.footnote())
                    .foregroundColor(.textSecondary)
            }
            if viewModel.userBalance > 0 {
                HStack {
                    Text("Balance After")
                        .bodyRegularStyle()
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text("\(viewModel.walletCurrency) \(FeeCalculator.formatCurrency(viewModel.balanceAfterWithdrawal))")
                        .bodyRegularStyle()
                        .foregroundColor(viewModel.insufficientFundsWarning ? .errorRed : .successGreen)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.inputBackground)
        .cornerRadius(Spacing.radiusMedium)
    }
}
