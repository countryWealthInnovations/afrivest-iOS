//
//  OTPViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//


import SwiftUI
import Combine

class OTPViewModel: ObservableObject {
    @Published var email: String
    @Published var from: String
    @Published var otpCode = ""
    @Published var timeRemaining = 600 // 10 minutes
    @Published var canResend = false
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var shouldNavigateToDashboard = false
    
    private var timer: Timer?
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init(email: String, from: String) {
        self.email = email
        self.from = from
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.canResend = true
                self.timer?.invalidate()
            }
        }
    }
    
    func verifyOTP() {
        let code = otpCode
        if code.count != 6 { return }
        
        isLoading = true
        
        Task {
            do {
                let parameters = ["code": code]
                
                let response: OTPResponse = try await APIClient.shared.request(
                    APIConstants.Endpoints.verifyOTP,
                    method: .post,
                    parameters: parameters,
                    requiresAuth: true
                )
                
                await MainActor.run {
                    self.isLoading = false
                    
                    // Update user verification status if returned
                    if let user = response.user, let emailVerified = response.emailVerified {
                        if emailVerified {
                            self.shouldNavigateToDashboard = true
                        }
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

    func resendOTP() {
        guard canResend else { return }
        
        isLoading = true
        
        Task {
            do {
                let response: OTPResponse = try await APIClient.shared.request(
                    APIConstants.Endpoints.resendOTP,
                    method: .post,
                    requiresAuth: true
                )
                
                await MainActor.run {
                    self.isLoading = false
                    self.timeRemaining = 600
                    self.canResend = false
                    self.otpCode = ""
                    self.startTimer()
                }
                
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
