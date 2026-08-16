//
//  User.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//
import Foundation

struct User: Codable, Identifiable, Sendable {
    let id: Int?
    let uuid: String?
    let name: String
    let email: String
    let phoneNumber: String?
    let role: String?
    let status: String
    let avatarUrl: String?
    let emailVerified: Bool?
    let phoneVerified: Bool?
    let kycVerified: Bool?
    let defaultCurrency: String?
    let secondaryCurrency: String?
    let requiresCurrencySetup: Bool?
    let kycBannerHidden: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, uuid, name, email, role, status
        case phoneNumber = "phone_number"
        case avatarUrl = "avatar_url"
        case emailVerified = "email_verified"
        case phoneVerified = "phone_verified"
        case kycVerified = "kyc_verified"
        case defaultCurrency = "default_currency"
        case secondaryCurrency = "secondary_currency"
        case requiresCurrencySetup = "requires_currency_setup"
        case kycBannerHidden = "kyc_banner_hidden"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Custom memberwise initializer
    init(
        id: Int?,
        uuid: String? = nil,
        name: String,
        email: String,
        phoneNumber: String? = nil,
        role: String? = nil,
        status: String,
        avatarUrl: String? = nil,
        emailVerified: Bool? = nil,
        phoneVerified: Bool? = nil,
        kycVerified: Bool? = nil,
        defaultCurrency: String? = nil,
        secondaryCurrency: String? = nil,
        requiresCurrencySetup: Bool? = nil,
        kycBannerHidden: Bool? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.role = role
        self.status = status
        self.avatarUrl = avatarUrl
        self.emailVerified = emailVerified
        self.phoneVerified = phoneVerified
        self.kycVerified = kycVerified
        self.defaultCurrency = defaultCurrency
        self.secondaryCurrency = secondaryCurrency
        self.requiresCurrencySetup = requiresCurrencySetup
        self.kycBannerHidden = kycBannerHidden
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Dashboard response doesn't include id, phone_number, role, etc.
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.uuid = try container.decodeIfPresent(String.self, forKey: .uuid)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.role = try container.decodeIfPresent(String.self, forKey: .role)
        self.status = try container.decode(String.self, forKey: .status)
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        self.emailVerified = try container.decodeIfPresent(Bool.self, forKey: .emailVerified)
        self.phoneVerified = try container.decodeIfPresent(Bool.self, forKey: .phoneVerified)
        self.kycVerified = try container.decodeIfPresent(Bool.self, forKey: .kycVerified)
        self.defaultCurrency = try container.decodeIfPresent(String.self, forKey: .defaultCurrency)
        self.secondaryCurrency = try container.decodeIfPresent(String.self, forKey: .secondaryCurrency)
        self.requiresCurrencySetup = try container.decodeIfPresent(Bool.self, forKey: .requiresCurrencySetup)
        self.kycBannerHidden = try container.decodeIfPresent(Bool.self, forKey: .kycBannerHidden)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    
    var isActive: Bool {
        return status == "active"
    }
    
    var isVerified: Bool {
        return emailVerified ?? false
    }
    
    var isPhoneVerified: Bool {
        return phoneVerified ?? false
    }
    
    var isKycVerified: Bool {
        return kycVerified ?? false
    }
}
