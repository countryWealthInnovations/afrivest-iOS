//
//  PhoneOTPViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import SwiftUI
import Alamofire
import Combine

class PhoneOTPViewModel: ObservableObject {
    @Published var phone: String
    @Published var otpCode = ""
    @Published var timeRemaining = 600
    @Published var canResend = false

    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var verified = false

    private var timer: Timer?

    var formattedTime: String {
        String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60)
    }

    init(phone: String) {
        self.phone = phone
        sendOtp()
    }

    private func startTimer() {
        timer?.invalidate()
        timeRemaining = 600
        canResend = false
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

    private func sendOtp() {
        isLoading = true
        Task {
            do {
                let _: PhoneOtpData = try await APIClient.shared.request(
                    "/auth/phone/send-otp", method: .post, parameters: [:], requiresAuth: true)
                await MainActor.run { self.isLoading = false; self.startTimer() }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }

    func verifyOTP() {
        guard otpCode.count == 6 else { return }
        isLoading = true
        Task {
            do {
                let _: PhoneVerifyData = try await APIClient.shared.request(
                    "/auth/phone/verify-otp", method: .post,
                    parameters: ["code": otpCode], requiresAuth: true)
                await MainActor.run { self.isLoading = false; self.verified = true }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }

    func resendOTP() {
        guard canResend else { return }
        otpCode = ""
        sendOtp()
    }

    deinit { timer?.invalidate() }
}

struct PhoneOtpData: Codable, Sendable {
    let otp_sent: Bool?
    let channel: String?
    let otp_code: String?

    enum CodingKeys: String, CodingKey { case otp_sent, channel, otp_code }
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        otp_sent = try c.decodeIfPresent(Bool.self, forKey: .otp_sent)
        channel = try c.decodeIfPresent(String.self, forKey: .channel)
        otp_code = try c.decodeIfPresent(String.self, forKey: .otp_code)
    }
}

struct PhoneVerifyData: Codable, Sendable {
    let phone_verified: Bool?

    enum CodingKeys: String, CodingKey { case phone_verified }
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        phone_verified = try c.decodeIfPresent(Bool.self, forKey: .phone_verified)
    }
}
