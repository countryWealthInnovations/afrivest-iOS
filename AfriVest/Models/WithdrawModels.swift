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
    let network: String
    let phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case amount, currency, network
        case phoneNumber = "phone_number"
    }
}

// MARK: - Withdraw Response
struct WithdrawResponse: Codable, Sendable {
    let transactionId: Int
    let reference: String
    let amount: String
    let currency: String
    let network: String
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case reference, amount, currency, network, status
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transactionId = try container.decode(Int.self, forKey: .transactionId)
        reference = try container.decode(String.self, forKey: .reference)
        amount = try container.decode(String.self, forKey: .amount)
        currency = try container.decode(String.self, forKey: .currency)
        network = try container.decode(String.self, forKey: .network)
        status = try container.decodeIfPresent(String.self, forKey: .status)
    }
}
