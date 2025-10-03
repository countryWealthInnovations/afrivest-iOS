//
//  OTPResponse.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import Foundation

struct OTPResponse: Codable, Sendable {
    let user: User?
    let otpSent: Bool?
    let otpChannel: String?
    let expiresIn: Int?
    let emailVerified: Bool?
    
    enum CodingKeys: String, CodingKey {
        case user
        case otpSent = "otp_sent"
        case otpChannel = "otp_channel"
        case expiresIn = "expires_in"
        case emailVerified = "email_verified"
    }
}

struct MessageResponse: Codable, Sendable {
    let message: String
}
