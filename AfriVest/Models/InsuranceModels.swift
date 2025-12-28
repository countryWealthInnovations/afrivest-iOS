//
//  InsuranceModels.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//

import Foundation

// MARK: - Insurance Provider
struct InsuranceProvider: Codable, Identifiable, Sendable {
    let id: Int
    let name: String
    let logoUrl: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case logoUrl = "logo_url"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        logoUrl = try container.decodeIfPresent(String.self, forKey: .logoUrl)
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }
}

// MARK: - Beneficiary
struct Beneficiary: Codable, Sendable {
    let name: String
    let relationship: String
    let percentage: Int
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        relationship = try container.decode(String.self, forKey: .relationship)
        percentage = try container.decode(Int.self, forKey: .percentage)
    }
}

// MARK: - Purchase Insurance Policy Request
struct PurchaseInsurancePolicyRequest: Codable, Sendable {
    let partnerId: Int
    let policyType: String
    let coverageAmount: Double
    let premiumAmount: Double
    let premiumFrequency: String
    let beneficiaries: [Beneficiary]
    let startDate: String
    let endDate: String
    let autoDeductWallet: Bool?
    let walletId: Int?
    
    enum CodingKeys: String, CodingKey {
        case beneficiaries
        case partnerId = "partner_id"
        case policyType = "policy_type"
        case coverageAmount = "coverage_amount"
        case premiumAmount = "premium_amount"
        case premiumFrequency = "premium_frequency"
        case startDate = "start_date"
        case endDate = "end_date"
        case autoDeductWallet = "auto_deduct_wallet"
        case walletId = "wallet_id"
    }
}

// MARK: - Insurance Policy
struct InsurancePolicy: Codable, Identifiable, Sendable {
    let id: Int
    let userId: Int?
    let partnerId: Int?
    let partner: InsuranceProvider?
    let policyNumber: String
    let policyType: String
    let policyTypeLabel: String?
    let providerName: String?
    let coverageAmount: String
    let premiumAmount: String
    let premiumFrequency: String
    let status: String
    let startDate: String
    let endDate: String
    let nextPaymentDate: String?
    let daysToExpiry: Int?
    let beneficiaries: [Beneficiary]?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, partner, status, beneficiaries
        case userId = "user_id"
        case partnerId = "partner_id"
        case policyNumber = "policy_number"
        case policyType = "policy_type"
        case policyTypeLabel = "policy_type_label"
        case providerName = "provider_name"
        case coverageAmount = "coverage_amount"
        case premiumAmount = "premium_amount"
        case premiumFrequency = "premium_frequency"
        case startDate = "start_date"
        case endDate = "end_date"
        case nextPaymentDate = "next_payment_date"
        case daysToExpiry = "days_to_expiry"
        case createdAt = "created_at"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        partnerId = try container.decodeIfPresent(Int.self, forKey: .partnerId)
        partner = try container.decodeIfPresent(InsuranceProvider.self, forKey: .partner)
        policyNumber = try container.decode(String.self, forKey: .policyNumber)
        policyType = try container.decode(String.self, forKey: .policyType)
        policyTypeLabel = try container.decodeIfPresent(String.self, forKey: .policyTypeLabel)
        providerName = try container.decodeIfPresent(String.self, forKey: .providerName)
        coverageAmount = try container.decode(String.self, forKey: .coverageAmount)
        premiumAmount = try container.decode(String.self, forKey: .premiumAmount)
        premiumFrequency = try container.decode(String.self, forKey: .premiumFrequency)
        status = try container.decode(String.self, forKey: .status)
        startDate = try container.decode(String.self, forKey: .startDate)
        endDate = try container.decode(String.self, forKey: .endDate)
        nextPaymentDate = try container.decodeIfPresent(String.self, forKey: .nextPaymentDate)
        daysToExpiry = try container.decodeIfPresent(Int.self, forKey: .daysToExpiry)
        beneficiaries = try container.decodeIfPresent([Beneficiary].self, forKey: .beneficiaries)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }
    
    var statusColor: String {
        switch status.lowercased() {
        case "active": return "success_green"
        case "expired": return "text_secondary"
        case "cancelled": return "error_red"
        case "pending": return "warning_yellow"
        default: return "text_secondary"
        }
    }
    
    var policyTypeText: String {
        policyTypeLabel ?? policyType.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

// MARK: - Insurance Claim
struct InsuranceClaim: Codable, Identifiable, Sendable {
    let id: Int
    let claimNumber: String
    let policyId: Int
    let claimType: String
    let amount: String
    let amountFormatted: String
    let status: String
    let description: String?
    let incidentDate: String
    let createdAt: String
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status, description
        case claimNumber = "claim_number"
        case policyId = "policy_id"
        case claimType = "claim_type"
        case amount
        case amountFormatted = "amount_formatted"
        case incidentDate = "incident_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        claimNumber = try container.decode(String.self, forKey: .claimNumber)
        policyId = try container.decode(Int.self, forKey: .policyId)
        claimType = try container.decode(String.self, forKey: .claimType)
        amount = try container.decode(String.self, forKey: .amount)
        amountFormatted = try container.decode(String.self, forKey: .amountFormatted)
        status = try container.decode(String.self, forKey: .status)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        incidentDate = try container.decode(String.self, forKey: .incidentDate)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}
