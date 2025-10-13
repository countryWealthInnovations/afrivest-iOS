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
    @Published var amount: String = ""
    @Published var phoneNumber: String = ""
    @Published var selectedNetwork: String = "MTN"
    @Published var selectedCurrency: String = "UGX"
    
    @Published var phoneState: TextFieldState = .normal
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isFormValid: Bool = false
    
    @Published var withdrawResponse: WithdrawResponse?
    @Published var shouldNavigateToSuccess: Bool = false

    @Published var fee: Double = 0.0
    @Published var totalAmount: Double = 0.0
    @Published var balanceAfterWithdrawal: Double = 0.0
    @Published var userBalance: Double = 0.0
    @Published var insufficientFundsWarning: Bool = false

    private let withdrawService = WithdrawService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest4($amount, $phoneNumber, $phoneState, $insufficientFundsWarning)
            .map { amount, phone, phoneState, insufficientFunds in
                guard let amountValue = Double(amount), amountValue >= 10000 else {
                    return false
                }
                
                return phoneState == .success && !phone.isEmpty && !insufficientFunds
            }
            .assign(to: &$isFormValid)
        
        // Calculate fee whenever amount changes
        $amount
            .sink { [weak self] amount in
                if let amountValue = Double(amount), amountValue >= 10000 {
                    self?.calculateAndUpdateFee(amountValue)
                } else {
                    self?.fee = 0.0
                    self?.totalAmount = 0.0
                    self?.insufficientFundsWarning = false
                }
            }
            .store(in: &cancellables)
        
        // Auto-detect network from phone number
        $phoneNumber
            .sink { [weak self] phone in
                self?.detectNetwork(from: phone)
                self?.validatePhoneNumber(phone)
            }
            .store(in: &cancellables)
    }
    
    private func detectNetwork(from phone: String) {
        // User enters only 9 digits like: 700426822
        // Just check the first 2 digits
        if phone.hasPrefix("77") || phone.hasPrefix("78") || phone.hasPrefix("76") || phone.hasPrefix("79") {
            selectedNetwork = "MTN"
        } else if phone.hasPrefix("70") || phone.hasPrefix("74") || phone.hasPrefix("75") {
            selectedNetwork = "AIRTEL"
        }
    }
    
    private func validatePhoneNumber(_ phone: String) {
        if phone.isEmpty {
            phoneState = .normal
        } else if phone.count == 9 && phone.first == "7" {
            phoneState = .success
        } else {
            phoneState = .error
        }
    }

    private func calculateAndUpdateFee(_ amount: Double) {
        fee = FeeCalculator.calculateFee(for: amount)
        totalAmount = amount + fee
        
        // Get user's UGX balance from profile
        if let profile = UserDefaultsManager.shared.getCachedProfile(),
           let ugxWallet = profile.wallets.first(where: { $0.currency == "UGX" }),
           let balance = Double(ugxWallet.balance) {
            userBalance = balance
            balanceAfterWithdrawal = balance - totalAmount
            insufficientFundsWarning = totalAmount > balance
        }
    }
    
    func initiateWithdraw() {
        guard isFormValid else { return }
        
        let formattedPhone = "+256\(phoneNumber)"
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await withdrawService.withdrawMobileMoney(
                    amount: Double(amount) ?? 0,
                    currency: selectedCurrency,
                    network: selectedNetwork,
                    phoneNumber: formattedPhone
                )
                
                withdrawResponse = response
                shouldNavigateToSuccess = true
                
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}
