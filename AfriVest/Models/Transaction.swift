//
//  Transaction.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import Foundation

struct Transaction: Codable, Identifiable, Sendable {
    let id: Int
    let reference: String
    let type: String
    let amount: String
    let feeAmount: String?
    let totalAmount: String?
    let currency: String
    let status: String
    let paymentChannel: String?
    let externalReference: String?
    let description: String?
    let createdAt: String
    let updatedAt: String?
    let completedAt: String?
    let recipient: Recipient?
    
    enum CodingKeys: String, CodingKey {
        case id, reference, type, amount, currency, status, description
        case feeAmount = "fee_amount"
        case totalAmount = "total_amount"
        case paymentChannel = "payment_channel"
        case externalReference = "external_reference"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
        case recipient
    }
    
    init(
        id: Int,
        reference: String,
        type: String,
        amount: String,
        feeAmount: String? = nil,
        totalAmount: String? = nil,
        currency: String,
        status: String,
        paymentChannel: String? = nil,
        externalReference: String? = nil,
        description: String? = nil,
        createdAt: String,
        updatedAt: String? = nil,
        completedAt: String? = nil,
        recipient: Recipient? = nil
    ) {
        self.id = id
        self.reference = reference
        self.type = type
        self.amount = amount
        self.feeAmount = feeAmount
        self.totalAmount = totalAmount
        self.currency = currency
        self.status = status
        self.paymentChannel = paymentChannel
        self.externalReference = externalReference
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.recipient = recipient
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        reference = try container.decode(String.self, forKey: .reference)
        type = try container.decode(String.self, forKey: .type)
        amount = try container.decode(String.self, forKey: .amount)
        feeAmount = try container.decodeIfPresent(String.self, forKey: .feeAmount)
        totalAmount = try container.decodeIfPresent(String.self, forKey: .totalAmount)
        currency = try container.decode(String.self, forKey: .currency)
        status = try container.decode(String.self, forKey: .status)
        paymentChannel = try container.decodeIfPresent(String.self, forKey: .paymentChannel)
        externalReference = try container.decodeIfPresent(String.self, forKey: .externalReference)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        completedAt = try container.decodeIfPresent(String.self, forKey: .completedAt)
        recipient = try container.decodeIfPresent(Recipient.self, forKey: .recipient)
    }
    
    var amountDouble: Double {
        return Double(amount) ?? 0.0
    }
    
    var isPending: Bool { status == "pending" }
    var isSuccess: Bool { status == "success" }
    var isFailed: Bool { status == "failed" }
    
    // Format amount with currency
    func getFormattedAmount() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        if let number = numberFormatter.number(from: amount) {
            let formattedNumber = numberFormatter.string(from: number) ?? amount
            return "\(formattedNumber) \(currency)"
        }
        
        return "\(amount) \(currency)"
    }
}

struct Recipient: Codable, Sendable {
    let name: String
    let email: String
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, email
    }
}
