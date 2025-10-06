//
//  User.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//
import Foundation

struct User: Codable, Identifiable, Sendable {
    let id: Int?
    let name: String
    let email: String
    let phoneNumber: String?
    let role: String?
    let status: String
    let avatarUrl: String?
    let emailVerified: Bool?
    let kycVerified: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, role, status
        case phoneNumber = "phone_number"
        case avatarUrl = "avatar_url"
        case emailVerified = "email_verified"
        case kycVerified = "kyc_verified"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Dashboard response doesn't include id, phone_number, role, etc.
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.role = try container.decodeIfPresent(String.self, forKey: .role)
        self.status = try container.decode(String.self, forKey: .status)
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        self.emailVerified = try container.decodeIfPresent(Bool.self, forKey: .emailVerified)
        self.kycVerified = try container.decodeIfPresent(Bool.self, forKey: .kycVerified)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    
    var isActive: Bool {
        return status == "active"
    }
    
    var isVerified: Bool {
        return emailVerified ?? false
    }
}
