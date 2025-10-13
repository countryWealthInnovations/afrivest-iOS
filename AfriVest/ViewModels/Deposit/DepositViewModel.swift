//
//  DepositViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 10/10/2025.
//

import Foundation
import Combine

@MainActor
class DepositViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var phoneNumber: String = ""
    @Published var selectedNetwork: String = "MTN"
    @Published var selectedCurrency: String = "UGX"
    
    @Published var phoneState: TextFieldState = .normal
    
    // Card fields
    @Published var cardNumber: String = ""
    @Published var cvv: String = ""
    @Published var expiryMonth: String = ""
    @Published var expiryYear: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isFormValid: Bool = false
    @Published var isCardFormValid: Bool = false
    
    @Published var depositResponse: DepositResponse?
    @Published var transactionStatus: TransactionStatus?
    @Published var shouldNavigateToWebView: Bool = false
    @Published var shouldNavigateToStatus: Bool = false
    
    private let depositService = DepositService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest3($amount, $phoneNumber, $phoneState)
            .map { amount, phone, phoneState in
                guard let amountValue = Double(amount), amountValue >= 4999 else {
                    return false
                }
                
                return phoneState == .success && !phone.isEmpty
            }
            .assign(to: &$isFormValid)
        
        // Card form validation
        Publishers.CombineLatest($amount, Publishers.CombineLatest4($cardNumber, $cvv, $expiryMonth, $expiryYear))
            .map { amount, cardFields in
                let (cardNumber, cvv, expiryMonth, expiryYear) = cardFields
                
                guard let amountValue = Double(amount), amountValue >= 4999 else {
                    return false
                }
                
                let cardNumberValid = cardNumber.replacingOccurrences(of: " ", with: "").count == 16
                let cvvValid = cvv.count == 3
                let expiryMonthValid = expiryMonth.count == 2 && (Int(expiryMonth) ?? 0) >= 1 && (Int(expiryMonth) ?? 0) <= 12
                let expiryYearValid = expiryYear.count == 2
                
                return cardNumberValid && cvvValid && expiryMonthValid && expiryYearValid
            }
            .assign(to: &$isCardFormValid)
        
        // Auto-detect network from phone number
        $phoneNumber
            .sink { [weak self] phone in
                self?.detectNetwork(from: phone)
                self?.validatePhoneNumber(phone)
            }
            .store(in: &cancellables)
    }
    
    private func detectNetwork(from phone: String) {
        // Just check the first 2-3 digits
        if phone.hasPrefix("77") || phone.hasPrefix("78") || phone.hasPrefix("76") || phone.hasPrefix("79") {
            selectedNetwork = "MTN"
        } else if phone.hasPrefix("70") || phone.hasPrefix("74") || phone.hasPrefix("75") {
            selectedNetwork = "AIRTEL"
        }
    }
    
    private func validatePhoneNumber(_ phone: String) {
        if phone.isEmpty {
            phoneState = .normal
        } else if Validators.isValidPhoneNumber(phone) {
            phoneState = .success
        } else {
            phoneState = .error
        }
    }
    
    func initiateDeposit() {
        guard isFormValid else { return }
        
        // Format phone number with +256 prefix
        let formattedPhone = phoneNumber.hasPrefix("+") ? phoneNumber : "+256\(phoneNumber)"
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await depositService.depositMobileMoney(
                    amount: Double(amount) ?? 0,
                    currency: selectedCurrency,
                    network: selectedNetwork,
                    phoneNumber: formattedPhone
                )
                
                depositResponse = response
                shouldNavigateToWebView = true
                
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func initiateCardDeposit() {
        // Validate card fields
        guard !amount.isEmpty,
              let amountValue = Double(amount),
              amountValue >= 1000,
              !cardNumber.isEmpty,
              cardNumber.replacingOccurrences(of: " ", with: "").count == 16,
              !cvv.isEmpty,
              cvv.count == 3,
              !expiryMonth.isEmpty,
              expiryMonth.count == 2,
              !expiryYear.isEmpty,
              expiryYear.count == 2 else {
            errorMessage = "Please fill in all card details correctly"
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await depositService.depositCard(
                    amount: amountValue,
                    currency: selectedCurrency,
                    cardNumber: cardNumber.replacingOccurrences(of: " ", with: ""),
                    cvv: cvv,
                    expiryMonth: expiryMonth,
                    expiryYear: expiryYear
                )
                
                depositResponse = response
                shouldNavigateToWebView = true
                
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}
