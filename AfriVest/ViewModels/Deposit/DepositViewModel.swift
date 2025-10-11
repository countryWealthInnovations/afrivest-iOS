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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isFormValid: Bool = false
    
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
                guard let amountValue = Double(amount), amountValue >= 1000 else {
                    return false
                }
                
                return phoneState == .success && !phone.isEmpty
            }
            .assign(to: &$isFormValid)
        
        // Auto-detect network from phone number
        $phoneNumber
            .sink { [weak self] phone in
                self?.detectNetwork(from: phone)
                self?.validatePhoneNumber(phone)
            }
            .store(in: &cancellables)
    }
    
    private func detectNetwork(from phone: String) {
        let cleanPhone = phone.replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        if cleanPhone.hasPrefix("256077") ||
            cleanPhone.hasPrefix("256078") ||
            cleanPhone.hasPrefix("256076") {
            selectedNetwork = "MTN"
        } else if cleanPhone.hasPrefix("256070") ||
                    cleanPhone.hasPrefix("256074") ||
                    cleanPhone.hasPrefix("256075") {
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
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await depositService.depositMobileMoney(
                    amount: Double(amount) ?? 0,
                    currency: selectedCurrency,
                    network: selectedNetwork,
                    phoneNumber: Validators.formatPhoneNumber(phoneNumber)
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
