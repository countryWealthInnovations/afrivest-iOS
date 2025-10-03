//
//  AuthResponse.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import Foundation

struct AuthResponse: Codable, Sendable {
    let user: User
    let token: String
    let otpSent: Bool?
    let otpChannel: String?
    
    enum CodingKeys: String, CodingKey {
        case user, token
        case otpSent = "otp_sent"
        case otpChannel = "otp_channel"
    }
}