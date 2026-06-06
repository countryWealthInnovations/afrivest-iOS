//
//  WithdrawViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 13/10/2025.
//

import Foundation
import Combine

@MainActor
class WithdrawViewModel: ObservableObject {
    
    enum PayoutMethod: String, CaseIterable {
        case mobileMoney = "Mobile Money"
        case bankTransfer = "Bank Transfer"
    }
    
    // Payout method
    @Published var payoutMethod: PayoutMethod = .mobileMoney
    
    // Mobile money fields
    @Published var phoneNumber: String = ""
    @Published var selectedNetwork: String = "MTN"
    @Published var phoneState: TextFieldState = .normal
    
    // Bank transfer fields
    @Published var bankCode: String = ""
    @Published var accountNumber: String = ""
    @Published var accountName: String = ""
    
    // Shared
    @Published var amount: String = ""
    @Published var selectedCurrency: String = "UGX"
    @Published var walletCurrency: String = "UGX"
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isFormValid: Bool = false
    
    @Published var withdrawResponse: WithdrawResponse?
    @Published var shouldNavigateToSuccess: Bool = false
    
    // Fee — single combined line shown to user
    @Published var transactionFee: Double = 0.0
    @Published var totalAmount: Double = 0.0
    @Published var balanceAfterWithdrawal: Double = 0.0
    @Published var userBalance: Double = 0.0
    @Published var insufficientFundsWarning: Bool = false
    @Published var feeConfirmedByAPI: Bool = false
    
    // Available currencies per payout method
    let mobileMoneyNetworks: [String: [String]] = [
        "UGX": ["MTN", "AIRTEL"],
        "KES": ["MPESA", "AIRTEL"],
        "NGN": ["MTN", "AIRTEL"],
        "GHS": ["MTN", "VODAFONE", "AIRTEL"],
        "TZS": ["VODACOM", "AIRTEL", "TIGO"],
        "RWF": ["MTN", "AIRTEL"],
        "ZMW": ["MTN", "AIRTEL", "ZAMTEL"],
        "ZAR": ["MTN"],
        "XAF": ["MTN", "AIRTEL"],
        "XOF": ["MTN", "AIRTEL"],
    ]
    
    let bankCurrencies = ["UGX", "USD", "EUR", "GBP", "KES", "NGN", "ZAR", "CAD", "AED", "GHS", "TZS", "RWF"]
    
    var availableNetworks: [String] {
        mobileMoneyNetworks[selectedCurrency] ?? ["MTN", "AIRTEL"]
    }
    
    private let withdrawService = WithdrawService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        if let profile = UserDefaultsManager.shared.getCachedProfile(),
           let wallet = profile.wallets.first {
            walletCurrency = wallet.currency
            selectedCurrency = wallet.currency
        }
        setupValidation()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest3($amount, $payoutMethod, $insufficientFundsWarning)
            .combineLatest($phoneState)
            .map { [weak self] combined, phoneState in
                guard let self else { return false }
                let (amount, method, insufficientFunds) = combined
                guard let amountValue = Double(amount), amountValue >= 1000 else { return false }
                if insufficientFunds { return false }
                if method == .mobileMoney {
                    return phoneState == .success && !self.phoneNumber.isEmpty
                } else {
                    return !self.bankCode.isEmpty && !self.accountNumber.isEmpty && !self.accountName.isEmpty
                }
            }
            .assign(to: &$isFormValid)
        
        Publishers.CombineLatest3($amount, $selectedCurrency, $payoutMethod)
            .sink { [weak self] amount, currency, method in
                guard let self, let value = Double(amount), value >= 1000 else {
                    self?.transactionFee = 0
                    self?.totalAmount = 0
                    self?.insufficientFundsWarning = false
                    return
                }
                self.calculateAndUpdateFee(value, currency: currency, method: method)
            }
            .store(in: &cancellables)
        
        $phoneNumber
            .sink { [weak self] phone in
                self?.detectNetwork(from: phone)
                self?.validatePhoneNumber(phone)
            }
            .store(in: &cancellables)
        
        $selectedCurrency
            .sink { [weak self] currency in
                guard let self else { return }
                let nets = self.availableNetworks
                if !nets.contains(self.selectedNetwork) {
                    self.selectedNetwork = nets.first ?? "MTN"
                }
            }
            .store(in: &cancellables)
    }
    
    private func detectNetwork(from phone: String) {
        guard selectedCurrency == "UGX" else { return }
        if phone.hasPrefix("77") || phone.hasPrefix("78") || phone.hasPrefix("76") || phone.hasPrefix("79") {
            selectedNetwork = "MTN"
        } else if phone.hasPrefix("70") || phone.hasPrefix("74") || phone.hasPrefix("75") {
            selectedNetwork = "AIRTEL"
        }
    }
    
    private func validatePhoneNumber(_ phone: String) {
        if phone.isEmpty {
            phoneState = .normal
        } else if phone.count >= 7 {
            phoneState = .success
        } else {
            phoneState = .error
        }
    }
    
    private func calculateAndUpdateFee(_ amount: Double, currency: String, method: PayoutMethod) {
        let flwMethod = method == .bankTransfer ? "bank_transfer" : "mobile_money"
        let flwFee = FeeCalculator.flutterwavePayoutFee(amount: amount, currency: currency, method: flwMethod)
        let afrivestFee = amount * 0.005
        transactionFee = flwFee + afrivestFee
        totalAmount = amount + transactionFee
        feeConfirmedByAPI = false
        
        if let profile = UserDefaultsManager.shared.getCachedProfile(),
           let wallet = profile.wallets.first(where: { $0.currency == walletCurrency }),
           let balance = Double(wallet.balance) {
            userBalance = balance
            let rate = CurrencyConverter.getRate(from: currency, to: walletCurrency)
            let totalInWallet = walletCurrency == currency ? totalAmount : totalAmount * rate
            balanceAfterWithdrawal = balance - totalInWallet
            insufficientFundsWarning = totalInWallet > balance
        }
    }
    
    private func updateFeeFromAPIResponse(_ response: WithdrawResponse) {
        guard let tf = response.totalFee, let td = response.totalDebited else { return }
        transactionFee    = tf
        totalAmount       = td
        feeConfirmedByAPI = true
        if userBalance > 0 {
            balanceAfterWithdrawal = userBalance - td
            insufficientFundsWarning = td > userBalance
        }
    }
    
    func initiateWithdraw() {
        guard isFormValid else { return }
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let response: WithdrawResponse
                if payoutMethod == .mobileMoney {
                    response = try await withdrawService.withdrawMobileMoney(
                        amount: Double(amount) ?? 0,
                        currency: selectedCurrency,
                        walletCurrency: walletCurrency,
                        network: selectedNetwork,
                        phoneNumber: phoneNumber
                    )
                } else {
                    response = try await withdrawService.withdrawBankTransfer(
                        amount: Double(amount) ?? 0,
                        currency: selectedCurrency,
                        walletCurrency: walletCurrency,
                        bankCode: bankCode,
                        accountNumber: accountNumber,
                        accountName: accountName
                    )
                }
                withdrawResponse = response
                updateFeeFromAPIResponse(response)
                shouldNavigateToSuccess = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
