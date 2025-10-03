//
//  RegisterViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 03/10/2025.
//


import SwiftUI
import Combine

class RegisterViewModel: ObservableObject {
    // Form Fields
    @Published var fullName = ""
    @Published var email = ""
    @Published var selectedCountry = Country.default
    @Published var phoneNumber = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var termsAccepted = false
    
    // Field States
    @Published var nameState: TextFieldState = .normal
    @Published var emailState: TextFieldState = .normal
    @Published var phoneState: TextFieldState = .normal
    @Published var passwordState: TextFieldState = .normal
    @Published var confirmPasswordState: TextFieldState = .normal
    
    // Errors
    @Published var nameError: String?
    @Published var emailError: String?
    @Published var phoneError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    
    // UI States
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var passwordStrength: PasswordStrength = .weak
    
    // Navigation
    @Published var shouldNavigateToOTP = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var isFormValid: Bool {
        nameState == .success &&
        emailState == .success &&
        phoneState == .success &&
        passwordState == .success &&
        confirmPasswordState == .success &&
        termsAccepted
    }
    
    init() {
        setupValidation()
    }
    
    // MARK: - Setup Validation
    private func setupValidation() {
        // Name Validation
        $fullName
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validateName(value)
            }
            .store(in: &cancellables)
        
        // Email Validation
        $email
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validateEmail(value)
            }
            .store(in: &cancellables)
        
        // Phone Validation
        $phoneNumber
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validatePhone(value)
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
    
    // MARK: - Validation Methods
    private func validateName(_ name: String) {
        guard !name.isEmpty else {
            nameState = .normal
            nameError = nil
            return
        }
        
        if Validators.isValidName(name) {
            nameState = .success
            nameError = nil
        } else {
            nameState = .error
            nameError = "Please enter your full name (first and last name)"
        }
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
    
    private func validatePhone(_ phone: String) {
        guard !phone.isEmpty else {
            phoneState = .normal
            phoneError = nil
            return
        }
        
        // Combine country code with phone number
        let fullPhone = selectedCountry.dialCode.replacingOccurrences(of: "+", with: "") + phone
        
        if Validators.isValidPhoneNumber(fullPhone) {
            phoneState = .success
            phoneError = nil
        } else {
            phoneState = .error
            phoneError = "Please enter a valid phone number"
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
    
    // MARK: - Register
    func register() {
        guard isFormValid else { return }
        
        isLoading = true
        
        // Prepare phone number
        let fullPhone = selectedCountry.dialCode.replacingOccurrences(of: "+", with: "") + phoneNumber
        
        // TODO: Get device token from Firebase
        let deviceToken = UserDefaultsManager.shared.getDeviceToken() ?? ""
        
        let request = RegisterRequest(
            name: fullName,
            email: email,
            phoneNumber: fullPhone,
            password: password,
            passwordConfirmation: confirmPassword,
            deviceToken: deviceToken,
            deviceType: "ios",
            deviceName: UIDevice.current.name,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        )
        
        // TODO: Call API
        // For now, simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isLoading = false
            // On success:
            self?.shouldNavigateToOTP = true
            // On error:
            // self?.showError(message: "Registration failed")
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Register Request Model
struct RegisterRequest: Codable {
    let name: String
    let email: String
    let phoneNumber: String
    let password: String
    let passwordConfirmation: String
    let deviceToken: String
    let deviceType: String
    let deviceName: String
    let appVersion: String
    
    enum CodingKeys: String, CodingKey {
        case name, email
        case phoneNumber = "phone_number"
        case password
        case passwordConfirmation = "password_confirmation"
        case deviceToken = "device_token"
        case deviceType = "device_type"
        case deviceName = "device_name"
        case appVersion = "app_version"
    }
}