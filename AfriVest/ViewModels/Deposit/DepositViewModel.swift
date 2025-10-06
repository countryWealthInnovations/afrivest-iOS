//
//  DepositViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 06/10/2025.
//

import SwiftUI
import Combine

class DepositViewModel: ObservableObject {
    
    @Published var phoneNumber: String = ""
    @Published var phoneState: TextFieldState = .normal
    @Published var amount: String = ""
    @Published var selectedCurrency: String = "UGX"
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var shouldNavigateToDashboard = false
    
    let currencies = ["UGX", "USD", "EUR", "GBP"]
    
    private var initiatedTransaction: SDKInitiateResponse?
    
    // MARK: - Initiate Deposit
    
    func initiateDeposit(from viewController: UIViewController) {
        guard let amountValue = Double(amount), amountValue >= 1000 else {
                errorMessage = "Minimum amount is 1,000"
                return
            }
            
            // ADD THIS: Validate phone number
            guard Validators.isValidPhoneNumber(phoneNumber) else {
                errorMessage = "Please enter a valid phone number"
                phoneState = .error
                return
            }
            
            phoneState = .success
            isLoading = true
            errorMessage = nil
        
        // Step 1: Call backend to create transaction
        DepositService.shared.initiateSDKDeposit(amount: amountValue, currency: selectedCurrency) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.initiatedTransaction = response
                self.launchFlutterwaveSDK(from: viewController, response: response)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Launch SDK
    
    private func launchFlutterwaveSDK(from viewController: UIViewController, response: SDKInitiateResponse) {
        
        let phoneToUse = Validators.formatPhoneNumber(phoneNumber)
        
        FlutterwaveSDKManager.shared.initiatePayment(
            from: viewController,
            amount: String(response.amount),
            currency: response.currency,
            txRef: response.txRef,
            email: response.user.email,
            name: response.user.name,
            phoneNumber: phoneToUse, // Use formatted entered phone
            publicKey: response.sdkConfig.publicKey,
            encryptionKey: response.sdkConfig.encryptionKey,
            isStaging: false
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let sdkResult):
                self.verifyTransaction(flwRef: sdkResult.flwRef, status: sdkResult.status)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Payment cancelled"
                }
            }
        }
    }
    
    // MARK: - Verify Transaction
    
    private func verifyTransaction(flwRef: String, status: String) {
        guard let transaction = initiatedTransaction else { return }
        
        DepositService.shared.verifySDKDeposit(
            transactionId: transaction.transactionId,
            flwRef: flwRef,
            status: status
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let transaction):
                    if transaction.status == "success" {
                        self?.successMessage = "Deposit successful! \(transaction.getFormattedAmount())"
                        self?.shouldNavigateToDashboard = true
                    } else {
                        self?.errorMessage = "Payment failed. Please try again."
                    }
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
