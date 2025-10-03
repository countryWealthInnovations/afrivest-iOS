//
//  ResetPasswordViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//


//
//  ResetPasswordViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI
import Combine

class ResetPasswordViewModel: ObservableObject {
    let email: String
    
    @Published var code = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var codeState: TextFieldState = .normal
    @Published var passwordState: TextFieldState = .normal
    @Published var confirmPasswordState: TextFieldState = .normal
    
    @Published var codeError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    
    @Published var passwordStrength: PasswordStrength = .weak
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var shouldNavigateToLogin = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var isFormValid: Bool {
        codeState == .success &&
        passwordState == .success &&
        confirmPasswordState == .success
    }
    
    init(email: String) {
        self.email = email
        setupValidation()
    }
    
    private func setupValidation() {
        // Code Validation
        $code
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validateCode(value)
            }
            .store(in: &cancellables)
        
        // Password Validation
        $password
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validatePassword(value)
                self?.validateConfirmPassword()
            }
            .store(in: &cancellables)
        
        // Confirm Password Validation
        $confirmPassword
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.validateConfirmPassword()
            }
            .store(in: &cancellables)
    }
    
    private func validateCode(_ code: String) {
        guard !code.isEmpty else {
            codeState = .normal
            codeError = nil
            return
        }
        
        if code.count == 6 {
            codeState = .success
            codeError = nil
        } else {
            codeState = .error
            codeError = "Code must be 6 digits"
        }
    }
    
    private func validatePassword(_ password: String) {
        guard !password.isEmpty else {
            passwordState = .normal
            passwordError = nil
            passwordStrength = .weak
            return
        }
        
        let errors = Validators.isValidPassword(password)
        passwordStrength = Validators.getPasswordStrength(password)
        
        if errors.isEmpty {
            passwordState = .success
            passwordError = nil
        } else {
            passwordState = .error
            passwordError = errors.joined(separator: ", ")
        }
    }
    
    private func validateConfirmPassword() {
        guard !confirmPassword.isEmpty else {
            confirmPasswordState = .normal
            confirmPasswordError = nil
            return
        }
        
        if confirmPassword == password {
            confirmPasswordState = .success
            confirmPasswordError = nil
        } else {
            confirmPasswordState = .error
            confirmPasswordError = "Passwords do not match"
        }
    }
    
    func resetPassword() {
        guard isFormValid else { return }
        
        isLoading = true
        
        // TODO: Call reset password API
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.shouldNavigateToLogin = true
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}