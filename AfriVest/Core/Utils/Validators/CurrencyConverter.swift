//
//  CurrencyConverter.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 26/05/2026.
//


import Foundation

struct CurrencyConverter {
    
    /// Rates stored in UserDefaults are UGX-based:
    /// key = target currency, value = how many of that currency 1 UGX buys
    /// e.g. "GBP": 0.000213 means 1 UGX = 0.000213 GBP
    static func getRate(from: String, to: String) -> Double {
        guard from != to else { return 1.0 }
        
        // Fallback rates: 1 UGX = X foreign
        let ugxToForeign: [String: Double] = [
            "USD": 0.000270,
            "GBP": 0.000213,
            "EUR": 0.000250,
            "KES": 0.035714,
            "NGN": 0.400000,
            "ZAR": 0.005000,
            "CAD": 0.000370,
            "AED": 0.000992,
            "GHS": 0.004167,
            "TZS": 0.680000,
            "RWF": 0.370000,
            "ZMW": 0.007250,
        ]
        
        let stored = UserDefaultsManager.shared.object(forKey: "forex_rates") as? [String: Double] ?? [:]
        
        // Rate: 1 UGX = X [currency]
        func ugxRate(_ currency: String) -> Double {
            if currency == "UGX" { return 1.0 }
            return stored[currency] ?? ugxToForeign[currency] ?? 0.0001
        }
        
        let fromRate = ugxRate(from)  // 1 UGX = fromRate [from]
        let toRate = ugxRate(to)      // 1 UGX = toRate [to]
        
        // Convert: from → UGX → to
        // 1 [from] = (1/fromRate) UGX = (toRate/fromRate) [to]
        if fromRate == 0 { return 0 }
        return toRate / fromRate
    }
}
