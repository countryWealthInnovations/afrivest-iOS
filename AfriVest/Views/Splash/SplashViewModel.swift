import SwiftUI
import Combine

class SplashViewModel: ObservableObject {
    @Published var isAnimating = false
    @Published var navigateTo: NavigationDestination?
    
    private var cancellables = Set<AnyCancellable>()
    private let authManager = AuthManager.shared
    private let userDefaults = UserDefaults.standard
    
    enum NavigationDestination {
        case onboarding
        case login
        case dashboard
    }
    
    // MARK: - Animation
    func startAnimation() {
        // Trigger animation immediately
        withAnimation {
            isAnimating = true
        }
    }
    
    // MARK: - Check Auth Status
    func checkAuthStatus() {
        // Wait for splash animation (2.5 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.determineNextScreen()
        }
    }
    
    private func determineNextScreen() {
        // Check if onboarding has been completed
        let hasCompletedOnboarding = userDefaults.bool(forKey: "hasCompletedOnboarding")
        
        // Check if user has valid auth token
        if let token = authManager.getToken(), !token.isEmpty {
            // Validate token with API
            validateToken(token)
        } else {
            // No token, check onboarding status
            navigateTo = hasCompletedOnboarding ? .login : .onboarding
        }
    }
    
    private func validateToken(_ token: String) {
        // TODO: Call API to validate token
        // For now, assume token is valid if it exists
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // If token is valid, go to dashboard
            self?.navigateTo = .dashboard
            
            // If token is invalid:
            // self?.navigateTo = .login
        }
    }
}

// MARK: - Auth Manager (Placeholder)
class AuthManager {
    static let shared = AuthManager()
    private let keychainManager = KeychainManager()
    
    private init() {}
    
    func getToken() -> String? {
        return keychainManager.get(key: "auth_token")
    }
    
    func saveToken(_ token: String) {
        keychainManager.save(key: "auth_token", value: token)
    }
    
    func clearToken() {
        keychainManager.delete(key: "auth_token")
    }
}