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
        guard otpCode.count == 6 else { return }
        
        isLoading = true
        
        // TODO: Call verify OTP API
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.shouldNavigateToDashboard = true
        }
    }
    
    func resendOTP() {
        guard canResend else { return }
        
        isLoading = true
        
        // TODO: Call resend OTP API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.timeRemaining = 600
            self.canResend = false
            self.otpCode = ""
            self.startTimer()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}