//
//  FeeCalculator.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 13/10/2025.
//


import Foundation

struct FeeCalculator {
    static func calculateFee(for amount: Double) -> Double {
        if amount < 125_000 {
            return 1_000.0
        } else {
            return amount * 0.012 // 1.2%
        }
    }
    
    static func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}