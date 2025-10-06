//
//  LoginViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI
import Combine
import FirebaseMessaging
import LocalAuthentication
import Alamofire

class LoginViewModel: ObservableObject {
    // Form Fields
    @Published var email = ""
    @Published var password = ""
    
    // Field States
    @Published var emailState: TextFieldState = .normal
    @Published var passwordState: TextFieldState = .normal
    
    // Errors
    @Published var emailError: String?
    @Published var passwordError: String?
    
    // UI States
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var biometricAvailable = false
    
    // Navigation
    @Published var shouldNavigateToOTP = false
    @Published var shouldNavigateToDashboard = false
    @Published var showForgotPassword = false
    @Published var shouldPromptBiometricSetup = false
    @Published var showEmailVerificationAlert = false
    @Published var verificationAlertMessage = ""
    
    private var biometricHardwareAvailable = false
    private var cancellables = Set<AnyCancellable>()
    
    var isFormValid: Bool {
        emailState == .success && !password.isEmpty
    }
    
    init() {
        setupValidation()
        checkBiometricAvailability()
    }
    
    // MARK: - Setup Validation
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
    
    // MARK: - Login
    func login() {
        guard isFormValid else { return }
        
        isLoading = true
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error)")
                self.isLoading = false
                self.showError(message: "Failed to get device token")
                return
            }
            
            let deviceToken = token ?? ""
            UserDefaultsManager.shared.deviceToken = deviceToken
            
            Task {
                do {
                    let parameters: [String: Any] = [
                        "email": self.email,
                        "password": self.password,
                        "device_token": deviceToken,
                        "device_type": "ios",
                        "device_name": UIDevice.current.name
                    ]
                    
                    let response: AuthResponse = try await APIClient.shared.request(
                        APIConstants.Endpoints.login,
                        method: .post,
                        parameters: parameters,
                        requiresAuth: false
                    )

                    await MainActor.run {
                        self.isLoading = false
                        
                        // Save credentials
                        KeychainManager.shared.saveToken(response.token)
                        UserDefaultsManager.shared.userEmail = self.email

                        let user = response.user   // no need for if let

                        if let id = user.id {
                            UserDefaultsManager.shared.userId = String(id)
                        }

                        // Save verification status
                        UserDefaultsManager.shared.emailVerified = user.emailVerified ?? false
                        UserDefaultsManager.shared.kycVerified = user.kycVerified ?? false

                        // Check email verification
                        if !(user.emailVerified ?? false) {
                            self.verificationAlertMessage = "Please verify your email to unlock all features. A verification code will be sent to your email."
                            self.showEmailVerificationAlert = true
                        } else {
                            self.shouldNavigateToDashboard = true
                        }

                    }
                    
                } catch {
                    await MainActor.run {
                        self.isLoading = false
                        self.showError(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // MARK: - Biometric
    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        
        // Check if device has biometric hardware
        biometricHardwareAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        // Show button only if hardware exists AND user has enabled it
        biometricAvailable = biometricHardwareAvailable && UserDefaultsManager.shared.biometricEnabled
    }
    
    func enableBiometric() {
        UserDefaultsManager.shared.biometricEnabled = true
        // Update button visibility
        biometricAvailable = biometricHardwareAvailable && UserDefaultsManager.shared.biometricEnabled
        shouldPromptBiometricSetup = false
    }
    
    func skipBiometric() {
        shouldPromptBiometricSetup = false
    }
    
    func loginWithBiometric() {
        let context = LAContext()
        let reason = "Login to AfriVest"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    // Get saved credentials and login
                    if let savedEmail = UserDefaultsManager.shared.userEmail {
                        self.email = savedEmail
                        // Enable biometric for future use
                        UserDefaultsManager.shared.biometricEnabled = true
                        // In production, use token-based auth instead of calling login()
                        self.login()
                    }
                } else {
                    self.showError(message: "Biometric authentication failed")
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - Email Verification Alert Handler
    func proceedToEmailVerification() {
        isLoading = true
        
        Task {
            do {
                // Auto-send OTP
                let _: OTPResponse = try await APIClient.shared.request(
                    APIConstants.Endpoints.resendOTP,
                    method: .post,
                    requiresAuth: true
                )
                
                await MainActor.run {
                    self.isLoading = false
                    self.shouldNavigateToOTP = true
                }
                
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.showError(message: "Failed to send verification code. Please try again.")
                }
            }
        }
    }
}
