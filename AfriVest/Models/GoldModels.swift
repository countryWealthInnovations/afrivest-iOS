//
//  GoldModels.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//

import Foundation

// MARK: - Gold Price
struct GoldPrice: Codable, Sendable {
    let pricePerGramUsd: Double
    let pricePerGramUgx: Double
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case pricePerGramUsd = "price_per_gram_usd"
        case pricePerGramUgx = "price_per_gram_ugx"
        case lastUpdated = "last_updated"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pricePerGramUsd = try container.decode(Double.self, forKey: .pricePerGramUsd)
        pricePerGramUgx = try container.decode(Double.self, forKey: .pricePerGramUgx)
        lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
    }
    
    func formattedUgxPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return "UGX \(formatter.string(from: NSNumber(value: pricePerGramUgx)) ?? "0")/g"
    }
    
    func formattedUsdPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return "USD \(formatter.string(from: NSNumber(value: pricePerGramUsd)) ?? "0")/g"
    }
}
