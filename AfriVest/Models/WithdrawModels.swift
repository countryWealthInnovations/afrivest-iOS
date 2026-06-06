//
//  WithdrawModels.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 13/10/2025.
//

import Foundation

// MARK: - Withdraw Request
struct WithdrawRequest: Codable {
    let amount: Double
    let currency: String
    let walletCurrency: String
    let network: String
    let phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case amount, currency, network
        case walletCurrency = "wallet_currency"
        case phoneNumber    = "phone_number"
    }
}

struct BankWithdrawRequest: Codable {
    let amount: Double
    let currency: String
    let walletCurrency: String
    let bankCode: String
    let accountNumber: String
    let accountName: String
    
    enum CodingKeys: String, CodingKey {
        case amount, currency
        case walletCurrency  = "wallet_currency"
        case bankCode        = "bank_code"
        case accountNumber   = "account_number"
        case accountName     = "account_name"
    }
}

// MARK: - Withdraw Response
struct WithdrawResponse: Codable, Sendable {
    let transactionId: Int
    let reference: String
    let amount: String
    let totalFee: Double?
    let totalDebited: Double?
    let currency: String
    let walletCurrency: String?
    let network: String?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case transactionId  = "transaction_id"
        case reference, amount, currency, network, status
        case walletCurrency = "wallet_currency"
        case totalFee       = "total_fee"
        case totalDebited   = "total_debited"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        transactionId  = try container.decode(Int.self, forKey: .transactionId)
        reference      = try container.decode(String.self, forKey: .reference)
        amount         = try container.decode(String.self, forKey: .amount)
        totalFee       = try container.decodeIfPresent(Double.self, forKey: .totalFee)
        totalDebited   = try container.decodeIfPresent(Double.self, forKey: .totalDebited)
        currency       = try container.decode(String.self, forKey: .currency)
        walletCurrency = try container.decodeIfPresent(String.self, forKey: .walletCurrency)
        network        = try container.decodeIfPresent(String.self, forKey: .network)
        status         = try container.decodeIfPresent(String.self, forKey: .status)
    }
}
