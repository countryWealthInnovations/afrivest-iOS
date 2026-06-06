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
    static func flutterwaveCollectionFee(amount: Double, currency: String, method: String) -> Double {
        let cur = currency.uppercased()
        if method == "card" || method == "international_card" {
            let pct: Double = ["GHS": 2.6, "NGN": 2.0, "ZAR": 2.9][cur] ?? 4.8
            return (amount * pct / 100).rounded(toPlaces: 2)
        }
        let pct: Double = [
            "UGX": 3.0, "KES": 2.9, "TZS": 2.5, "RWF": 3.5,
            "ZMW": 3.0, "NGN": 2.0, "GHS": 2.0, "XAF": 2.0,
            "XOF": 2.5, "ZAR": 2.5
        ][cur] ?? 3.0
        return (amount * pct / 100).rounded(toPlaces: 2)
    }
    
    static func flutterwavePayoutFee(amount: Double, currency: String, method: String) -> Double {
        let cur = currency.uppercased()
        if method == "bank_transfer" {
            let rate = CurrencyConverter.getRate(from: "UGX", to: cur)
            return (5000.0 * rate).rounded(toPlaces: 2)
        }
        switch cur {
        case "UGX": return amount < 125000 ? 1000 : (amount * 1.2 / 100).rounded(toPlaces: 2)
        case "KES": return 100
        case "TZS": return amount < 40000 ? 500 : (amount * 1.5 / 100).rounded(toPlaces: 2)
        case "RWF": return 500
        case "ZMW": return (amount * 2.0 / 100).rounded(toPlaces: 2)
        case "NGN": return amount <= 5000 ? 10 : amount <= 50000 ? 25 : 50
        case "GHS": return (amount * 1.5 / 100).rounded(toPlaces: 2)
        case "XAF", "XOF": return 1500
        default: return (amount * 1.5 / 100).rounded(toPlaces: 2)
        }
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
