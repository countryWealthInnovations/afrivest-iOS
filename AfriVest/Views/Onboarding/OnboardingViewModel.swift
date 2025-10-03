//
//  OnboardingViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var shouldNavigateToRegister = false
    
    private let userDefaultsManager = UserDefaultsManager.shared

    func completeOnboarding() {
        // Mark onboarding as completed (set first launch to false)
        UserDefaults.standard.set(true, forKey: AppConstants.StorageKeys.isFirstLaunch)
        
        // Navigate to registration/login
        shouldNavigateToRegister = true
    }
    
    func skipOnboarding() {
        completeOnboarding()
    }
}
