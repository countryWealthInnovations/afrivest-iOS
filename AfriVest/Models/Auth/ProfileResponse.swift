//
//  ProfileResponse.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 08/10/2025.
//

import Foundation

struct ProfileData: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
    let phoneNumber: String?
    let role: String
    let status: String
    let emailVerified: Bool
    let kycVerified: Bool
    let kycStatus: String
    let avatarUrl: String?
    let defaultAllocationSettings: AllocationSettings?
    let investmentRiskProfile: String?
    let createdAt: String
    let wallets: [Wallet]
    let investmentSummary: InvestmentSummary?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, role, status
        case phoneNumber = "phone_number"
        case emailVerified = "email_verified"
        case kycVerified = "kyc_verified"
        case kycStatus = "kyc_status"
        case avatarUrl = "avatar_url"
        case defaultAllocationSettings = "default_allocation_settings"
        case investmentRiskProfile = "investment_risk_profile"
        case createdAt = "created_at"
        case wallets
        case investmentSummary = "investment_summary"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.role = try container.decode(String.self, forKey: .role)
        self.status = try container.decode(String.self, forKey: .status)
        self.emailVerified = try container.decode(Bool.self, forKey: .emailVerified)
        self.kycVerified = try container.decode(Bool.self, forKey: .kycVerified)
        self.kycStatus = try container.decode(String.self, forKey: .kycStatus)
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        self.defaultAllocationSettings = try container.decodeIfPresent(AllocationSettings.self, forKey: .defaultAllocationSettings)
        self.investmentRiskProfile = try container.decodeIfPresent(String.self, forKey: .investmentRiskProfile)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.wallets = try container.decode([Wallet].self, forKey: .wallets)
        self.investmentSummary = try container.decodeIfPresent(InvestmentSummary.self, forKey: .investmentSummary)
    }
}

struct InvestmentSummary: Codable, Sendable {
    let totalInvested: Double
    let currentValue: Double
    let interestEarned: Double
    let interestPercentage: Double
    let activeInvestmentsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case totalInvested = "total_invested"
        case currentValue = "current_value"
        case interestEarned = "interest_earned"
        case interestPercentage = "interest_percentage"
        case activeInvestmentsCount = "active_investments_count"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.totalInvested = try container.decode(Double.self, forKey: .totalInvested)
        self.currentValue = try container.decode(Double.self, forKey: .currentValue)
        self.interestEarned = try container.decode(Double.self, forKey: .interestEarned)
        self.interestPercentage = try container.decode(Double.self, forKey: .interestPercentage)
        self.activeInvestmentsCount = try container.decode(Int.self, forKey: .activeInvestmentsCount)
    }
}

struct AllocationSettings: Codable, Sendable {
    let p2p: Int
    let insurance: Int
    let investment: Int
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.p2p = try container.decode(Int.self, forKey: .p2p)
        self.insurance = try container.decode(Int.self, forKey: .insurance)
        self.investment = try container.decode(Int.self, forKey: .investment)
    }
}
