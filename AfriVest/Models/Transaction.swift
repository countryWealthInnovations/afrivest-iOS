//
//  Transaction.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

// File Path: AfriVest/AfriVest/Models/Transaction.swift

import Foundation

struct Transaction: Codable, Identifiable {
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


enum CodingKeys: String, CodingKey {
    case id, reference, type, amount, currency, status, description
    case feeAmount = "fee_amount"
    case totalAmount = "total_amount"
    case paymentChannel = "payment_channel"
    case externalReference = "external_reference"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case completedAt = "completed_at"
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
