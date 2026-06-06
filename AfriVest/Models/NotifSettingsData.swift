//
//  NotifSettingsData.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 20/05/2026.
//

import Foundation

struct NotifSettingsData: Codable, Sendable {
    let push_enabled: Bool
    let email_enabled: Bool
    let sms_enabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case push_enabled, email_enabled, sms_enabled
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        push_enabled  = try c.decode(Bool.self, forKey: .push_enabled)
        email_enabled = try c.decode(Bool.self, forKey: .email_enabled)
        sms_enabled   = try c.decode(Bool.self, forKey: .sms_enabled)
    }
}

struct NotifSettingsResponse: Codable, Sendable {
    let success: Bool
    let data: NotifSettingsData
    
    enum CodingKeys: String, CodingKey {
        case success, data
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        success = try c.decode(Bool.self, forKey: .success)
        data    = try c.decode(NotifSettingsData.self, forKey: .data)
    }
}

struct NotifEmpty: Codable, Sendable {
    nonisolated init() {}
    nonisolated init(from decoder: Decoder) throws {}
}
