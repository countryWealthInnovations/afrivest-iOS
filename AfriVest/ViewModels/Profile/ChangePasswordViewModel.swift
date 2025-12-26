//
//  ChangePasswordViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 27/12/2025.
//

import SwiftUI
import Combine
import Alamofire

@MainActor
class ChangePasswordViewModel: ObservableObject {
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    
    @Published var currentPasswordState: TextFieldState = .normal
    @Published var newPasswordState: TextFieldState = .normal
    @Published var confirmPasswordState: TextFieldState = .normal
    
    @Published var currentPasswordError: String?
    @Published var newPasswordError: String?
    @Published var confirmPasswordError: String?
    
    @Published var passwordStrength: PasswordStrength = .weak
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var shouldDismiss = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var isFormValid: Bool {
        currentPasswordState == .success &&
        newPasswordState == .success &&
        confirmPasswordState == .success
    }
    
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        // Current Password Validation
        $currentPassword
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validateCurrentPassword(value)
            }
            .store(in: &cancellables)
        
        // New Password Validation
        $newPassword
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validateNewPassword(value)
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
    
    private func validateCurrentPassword(_ password: String) {
        guard !password.isEmpty else {
            currentPasswordState = .normal
            currentPasswordError = nil
            return
        }
        
        if password.count >= 8 {
            currentPasswordState = .success
            currentPasswordError = nil
        } else {
            currentPasswordState = .error
            currentPasswordError = "Password is required"
        }
    }
    
    private func validateNewPassword(_ password: String) {
        guard !password.isEmpty else {
            newPasswordState = .normal
            newPasswordError = nil
            passwordStrength = .weak
            return
        }
        
        let errors = Validators.isValidPassword(password)
        passwordStrength = Validators.getPasswordStrength(password)
        
        if errors.isEmpty {
            newPasswordState = .success
            newPasswordError = nil
        } else {
            newPasswordState = .error
            newPasswordError = errors.joined(separator: ", ")
        }
    }
    
    private func validateConfirmPassword() {
        guard !confirmPassword.isEmpty else {
            confirmPasswordState = .normal
            confirmPasswordError = nil
            return
        }
        
        if confirmPassword == newPassword {
            confirmPasswordState = .success
            confirmPasswordError = nil
        } else {
            confirmPasswordState = .error
            confirmPasswordError = "Passwords do not match"
        }
    }
    
    func changePassword() {
        guard isFormValid else { return }
        
        isLoading = true
        
        Task {
            do {
                let parameters: [String: String] = [
                    "current_password": currentPassword,
                    "new_password": newPassword,
                    "new_password_confirmation": confirmPassword
                ]
                
                let _: MessageResponse = try await APIClient.shared.request(
                    APIConstants.Endpoints.updatePassword,
                    method: .put,
                    parameters: parameters,
                    requiresAuth: true
                )
                
                self.isLoading = false
                self.shouldDismiss = true
                
            } catch {
                self.isLoading = false
                self.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
