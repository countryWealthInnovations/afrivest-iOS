//
//  ProfileViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 27/12/2025.
//

import SwiftUI
import Combine
import Alamofire
import LocalAuthentication

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: ProfileData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var biometricEnabled = false
    
    private let profileService = ProfileService.shared
    private let context = LAContext()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadBiometricPreference()
        setupBiometricToggle()
    }
    
    // MARK: - Load Profile
    func loadProfile() {
        isLoading = true
        errorMessage = nil
        
        profileService.getProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileData):
                    self?.user = profileData
                    self?.isLoading = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Biometric Authentication
    private func loadBiometricPreference() {
        biometricEnabled = UserDefaults.standard.bool(forKey: "biometric_enabled")
    }
    
    private func setupBiometricToggle() {
        $biometricEnabled
            .dropFirst() // Skip initial value
            .sink { [weak self] enabled in
                self?.handleBiometricToggle(enabled)
            }
            .store(in: &cancellables)
    }
    
    private func handleBiometricToggle(_ enabled: Bool) {
        if enabled {
            // Check if biometric is available
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                // Authenticate to enable
                authenticateBiometric { [weak self] success in
                    if success {
                        UserDefaults.standard.set(true, forKey: "biometric_enabled")
                    } else {
                        // Revert toggle if authentication failed
                        DispatchQueue.main.async {
                            self?.biometricEnabled = false
                        }
                    }
                }
            } else {
                // Biometric not available
                DispatchQueue.main.async {
                    self.biometricEnabled = false
                    self.errorMessage = "Biometric authentication is not available on this device"
                }
            }
        } else {
            // Disable biometric
            UserDefaults.standard.set(false, forKey: "biometric_enabled")
        }
    }
    
    private func authenticateBiometric(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Enable biometric authentication for quick and secure access"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
    
    // MARK: - Logout
    func logout() {
        isLoading = true
        
        Task {
            do {
                let _: MessageResponse = try await APIClient.shared.request(
                    APIConstants.Endpoints.logout,
                    method: .post,
                    requiresAuth: true
                )
                
                // Clear token and user data
                KeychainManager.shared.deleteToken()
                UserDefaultsManager.shared.clearProfile()
                UserDefaultsManager.shared.kycVerified = false
                
                // Post notification to return to login
                NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
                
                self.isLoading = false
                
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
