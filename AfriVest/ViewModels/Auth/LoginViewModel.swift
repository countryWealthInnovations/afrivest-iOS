import SwiftUI
import Combine
import FirebaseMessaging
import LocalAuthentication

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
            
            // TODO: Call login API
            // Simulate API call
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isLoading = false
                // Check if email verified
                let emailVerified = true // From API response
                
                if emailVerified {
                    self.shouldNavigateToDashboard = true
                } else {
                    self.shouldNavigateToOTP = true
                }
            }
        }
    }
    
    // MARK: - Biometric
    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        
        biometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            && UserDefaultsManager.shared.biometricEnabled
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
                        // In production, retrieve password from keychain or use token-based auth
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
}