//
//  TransferModels.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 13/10/2025.
//

import Foundation

// MARK: - P2P Transfer Request
struct P2PTransferRequest: Codable {
    let recipientId: Int
    let amount: Double
    let currency: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case recipientId = "recipient_id"
        case amount, currency, description
    }
}

// MARK: - P2P Transfer Response
struct P2PTransferResponse: Codable, Sendable {
    let transaction: TransferTransaction
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transaction = try container.decode(TransferTransaction.self, forKey: .transaction)
    }
    
    enum CodingKeys: String, CodingKey {
        case transaction
    }
}

struct TransferTransaction: Codable, Sendable {
    let id: Int
    let reference: String
    let amount: String
    let fee: String
    let total: Double
    let currency: String
    let status: String
    let sender: String
    let recipient: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, reference, amount, fee, total, currency, status, sender, recipient
        case createdAt = "created_at"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        reference = try container.decode(String.self, forKey: .reference)
        amount = try container.decode(String.self, forKey: .amount)
        fee = try container.decode(String.self, forKey: .fee)
        total = try container.decode(Double.self, forKey: .total)
        currency = try container.decode(String.self, forKey: .currency)
        status = try container.decode(String.self, forKey: .status)
        sender = try container.decode(String.self, forKey: .sender)
        recipient = try container.decode(String.self, forKey: .recipient)
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }
}

// MARK: - Contact Model
struct AppContact: Identifiable, Hashable {
    let id: String // Keep UUID for SwiftUI list identification
    let name: String
    let phoneNumber: String?
    let email: String?
    let userId: Int? // Backend user ID is Int
    let isRegistered: Bool
    
    var displayIdentifier: String {
        if let phone = phoneNumber {
            return phone
        } else if let email = email {
            return email
        }
        return "Unknown"
    }
}

// MARK: - User Search Response
struct UserSearchResponse: Codable, Sendable {
    let found: Bool
    let user: SearchedUser?
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        found = try container.decode(Bool.self, forKey: .found)
        user = try container.decodeIfPresent(SearchedUser.self, forKey: .user)
    }
    
    enum CodingKeys: String, CodingKey {
        case found, user
    }
}

struct SearchedUser: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email
        case phoneNumber = "phone_number"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
    }
}
