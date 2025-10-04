//
//  ForgotPasswordViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI
import Combine
import Alamofire

class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var emailState: TextFieldState = .normal
    @Published var emailError: String?
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var shouldNavigateToResetPassword = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var isFormValid: Bool {
        emailState == .success
    }
    
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        $email
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validateEmail(value)
            }
            .store(in: &cancellables)
    }
    
    private func validateEmail(_ email: String) {
        guard !email.isEmpty else {
            emailState = .normal
            emailError = nil
            return
        }
        
        if Validators.isValidEmail(email) {
            emailState = .success
            emailError = nil
        } else {
            emailState = .error
            emailError = "Please enter a valid email address"
        }
    }
    
    func sendResetCode() {
        guard isFormValid else { return }
        
        isLoading = true
        
        Task {
            do {
                let parameters = ["email": email]
                
                let _: MessageResponse = try await APIClient.shared.request(
                    APIConstants.Endpoints.forgotPassword,
                    method: .post,
                    parameters: parameters,
                    requiresAuth: false
                )
                
                await MainActor.run {
                    self.isLoading = false
                    self.shouldNavigateToResetPassword = true
                }
                
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
