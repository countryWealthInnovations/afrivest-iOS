//
//  Wallet.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//
import Foundation

struct Wallet: Codable, Identifiable, Sendable {
    let id: Int
    let currency: String
    let balance: String
    let status: String
    let walletType: String?
    let formattedBalance: String?
    let lastTransactionAt: String?
    let totalIncoming: String?
    let totalOutgoing: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, currency, balance, status
        case walletType = "wallet_type"
        case formattedBalance = "formatted_balance"
        case lastTransactionAt = "last_transaction_at"
        case totalIncoming = "total_incoming"
        case totalOutgoing = "total_outgoing"
        case createdAt = "created_at"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle optional id (dashboard response doesn't include it)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.currency = try container.decode(String.self, forKey: .currency)
        self.balance = try container.decode(String.self, forKey: .balance)
        self.status = try container.decode(String.self, forKey: .status)
        self.walletType = try container.decodeIfPresent(String.self, forKey: .walletType)
        
        // formattedBalance is optional in dashboard response
        self.formattedBalance = try container.decodeIfPresent(String.self, forKey: .formattedBalance)
        self.lastTransactionAt = try container.decodeIfPresent(String.self, forKey: .lastTransactionAt)
        self.totalIncoming = try container.decodeIfPresent(String.self, forKey: .totalIncoming)
        self.totalOutgoing = try container.decodeIfPresent(String.self, forKey: .totalOutgoing)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
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
