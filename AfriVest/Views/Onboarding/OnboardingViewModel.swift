//
//  OnboardingViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var shouldNavigateToRegister = false
    
    private let userDefaults = UserDefaults.standard
    
    func completeOnboarding() {
        // Mark onboarding as completed
        userDefaults.set(true, forKey: "hasCompletedOnboarding")
        
        // Navigate to registration/login
        shouldNavigateToRegister = true
    }
    
    func skipOnboarding() {
        completeOnboarding()
    }
}