//
//  Wallet.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import Foundation

struct Wallet: Codable, Identifiable {
let id: Int
let currency: String
let balance: String
let status: String
let formattedBalance: String
let lastTransactionAt: String?
let totalIncoming: String?
let totalOutgoing: String?
let createdAt: String?


enum CodingKeys: String, CodingKey {
    case id, currency, balance, status
    case formattedBalance = "formatted_balance"
    case lastTransactionAt = "last_transaction_at"
    case totalIncoming = "total_incoming"
    case totalOutgoing = "total_outgoing"
    case createdAt = "created_at"
}

var balanceDouble: Double {
    return Double(balance) ?? 0.0
}

var isActive: Bool {
    return status == "active"
}

var currencySymbol: String {
    switch currency {
    case "USD": return "$"
    case "EUR": return "€"
    case "GBP": return "£"
    default: return currency
    }
}

}
