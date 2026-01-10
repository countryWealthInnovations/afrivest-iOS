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
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case user
        case otpSent = "otp_sent"
        case otpChannel = "otp_channel"
        case expiresIn = "expires_in"
        case emailVerified = "email_verified"
        case message = "message"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decodeIfPresent(User.self, forKey: .user)
        otpSent = try container.decodeIfPresent(Bool.self, forKey: .otpSent)
        otpChannel = try container.decodeIfPresent(String.self, forKey: .otpChannel)
        expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)
        emailVerified = try container.decodeIfPresent(Bool.self, forKey: .emailVerified)
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
}

struct MessageResponse: Codable, Sendable {
    let message: String
    let otpSent: Bool?
    let otpCode: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case otpSent = "otp_sent"
        case otpCode = "otp_code"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        otpSent = try container.decodeIfPresent(Bool.self, forKey: .otpSent)
        otpCode = try container.decodeIfPresent(String.self, forKey: .otpCode)
    }
}

struct EmptyDataResponse: Codable, Sendable {
    nonisolated init() {}
    
    nonisolated init(from decoder: Decoder) throws {
        // Empty implementation for endpoints that return no data field
    }
}
