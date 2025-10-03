//
//  ForgotPasswordViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI
import Combine

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
            .debounce(for: 0.3, scheduler: RunLoop.