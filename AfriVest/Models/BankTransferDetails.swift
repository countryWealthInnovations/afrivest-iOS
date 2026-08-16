//
//  BankTransferDetails.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 08/07/2026.
//

import Foundation

struct BankTransferDetails: Codable {
    enum TransferType: String, Codable {
        case bankTransfer
        case payWithBankUK
    }

    let type: TransferType
    let transactionId: Int
    let bankName: String?
    let sortCode: String?
    let accountNumber: String?
    let amount: String
    let currency: String
    let reference: String
    let expiration: String?

    private static let storageKey = "pending_bank_transfer_details"

    static func save(_ details: BankTransferDetails) {
        if let data = try? JSONEncoder().encode(details) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    static func load() -> BankTransferDetails? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(BankTransferDetails.self, from: data)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
