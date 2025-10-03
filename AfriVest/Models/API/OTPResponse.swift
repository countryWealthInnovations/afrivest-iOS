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
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decodeIfPresent(User.self, forKey: .user)
        otpSent = try container.decodeIfPresent(Bool.self, forKey: .otpSent)
        otpChannel = try container.decodeIfPresent(String.self, forKey: .otpChannel)
        expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)
        emailVerified = try container.decodeIfPresent(Bool.self, forKey: .emailVerified)
    }
}

struct MessageResponse: Codable, Sendable {
    let message: String
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
    }
}
