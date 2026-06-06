//
//  CurrencySelectionViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 19/05/2026.
//

import SwiftUI
import Combine
import Alamofire

@MainActor
class CurrencySelectionViewModel: ObservableObject {
    @Published var defaultCurrency   = UserDefaultsManager.shared.defaultCurrency ?? "UGX"
    @Published var secondaryCurrency = UserDefaultsManager.shared.secondaryCurrency ?? ""
    @Published var isLoading         = false
    @Published var errorMessage: String?
    
    struct Currency {
        let code: String
        let name: String
        let flag: String
    }
    
    static let supported: [Currency] = [
        Currency(code: "UGX", name: "Ugandan Shilling",  flag: "🇺🇬"),
        Currency(code: "USD", name: "US Dollar",          flag: "🇺🇸"),
        Currency(code: "GBP", name: "British Pound",      flag: "🇬🇧"),
        Currency(code: "EUR", name: "Euro",               flag: "🇪🇺"),
        Currency(code: "KES", name: "Kenyan Shilling",    flag: "🇰🇪"),
        Currency(code: "NGN", name: "Nigerian Naira",     flag: "🇳🇬"),
        Currency(code: "ZAR", name: "South African Rand", flag: "🇿🇦"),
        Currency(code: "CAD", name: "Canadian Dollar",    flag: "🇨🇦"),
        Currency(code: "AED", name: "UAE Dirham",         flag: "🇦🇪"),
    ]
    
    func saveCurrency() async -> Bool {
        guard !defaultCurrency.isEmpty else {
            errorMessage = "Please select a primary currency."
            return false
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            var body: [String: Any] = [
                "default_currency": defaultCurrency
            ]
            if !secondaryCurrency.isEmpty {
                body["secondary_currency"] = secondaryCurrency
            } else {
                body["secondary_currency"] = ""
            }
            let _: EmptyDataResponse = try await APIClient.shared.request(
                "/profile/currency",
                method: .post,
                parameters: body,
                requiresAuth: true
            )
            UserDefaultsManager.shared.defaultCurrency   = defaultCurrency
            UserDefaultsManager.shared.secondaryCurrency = secondaryCurrency.isEmpty ? nil : secondaryCurrency
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
