//
//  HomeViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 06/10/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profile: ProfileData?
    @Published var wallets: [Wallet] = []
    
    // UI State
    @Published var isAmountHidden = false
    @Published var isOtherCurrenciesExpanded = false
    @Published var greeting = ""
    @Published var featuredInvestments: [InvestmentProduct] = []
    
    // Computed property for user (for backwards compatibility)
    var user: User? {
        guard let profile = profile else { return nil }
        
        return User(
            id: profile.id,
            name: profile.name,
            email: profile.email,
            phoneNumber: profile.phoneNumber,
            role: profile.role,
            status: profile.status,
            avatarUrl: profile.avatarUrl,
            emailVerified: profile.emailVerified,
            kycVerified: profile.kycVerified,
            createdAt: profile.createdAt,
            updatedAt: nil
        )
    }
    
    // All wallets go to deposit section, separated by currency
    var depositWallets: [Wallet] {
        wallets
    }
    
    // Primary currency wallet — falls back to UGX
    var depositWallet: Wallet? {
        let preferred = UserDefaultsManager.shared.defaultCurrency ?? "UGX"
        return wallets.first { $0.currency == preferred }
        ?? wallets.first { $0.currency == "UGX" }
        ?? wallets.first
    }
    
    // Investment summary from profile
    var investmentSummary: InvestmentSummary? {
        return profile?.investmentSummary
    }
    
    // Check if user has investments
    var hasInvestments: Bool {
        guard let summary = investmentSummary else { return false }
        return summary.activeInvestmentsCount > 0
    }
    
    // Other currency wallets (non-UGX)
    var otherCurrencyWallets: [Wallet] {
        wallets.filter { $0.currency != "UGX" }
    }
    
    init() {
        updateGreeting()
    }
    
    // MARK: - Load Profile with Caching
    func loadDashboard() {
        // Check if we have cached data
        let hasCachedData = UserDefaultsManager.shared.getCachedProfile() != nil
        
        // Only show loading if no cached data
        if !hasCachedData {
            isLoading = true
        }
        
        errorMessage = nil
        
        ProfileService.shared.getProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let profileData):
                    self?.profile = profileData
                    self?.wallets = profileData.wallets
                    self!.loadFeaturedInvestments()
                case .failure(let error):
                    // Only show error if we don't have cached data
                    if !hasCachedData {
                        self?.errorMessage = error.localizedDescription
                        print("❌ Profile load error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func loadFeaturedInvestments() {
        Task {
            do {
                let products = try await InvestmentService.shared.getFeaturedProducts()
                self.featuredInvestments = Array(products.prefix(3))
            } catch {
                print("❌ Failed to load featured investments: \(error)")
            }
        }
    }
    
    // MARK: - Update Greeting Based on Time
    func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            greeting = "Good morning!"
        case 12..<17:
            greeting = "Good afternoon!"
        case 17..<21:
            greeting = "Good evening!"
        default:
            greeting = "Good night!"
        }
    }
    
    // MARK: - Toggle Amount Visibility
    func toggleAmountVisibility() {
        isAmountHidden.toggle()
    }
    
    // MARK: - Toggle Other Currencies
    func toggleOtherCurrencies() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isOtherCurrenciesExpanded.toggle()
        }
    }
    
    // MARK: - Format Balance
    func formatBalance(_ balance: String, currency: String) -> String {
        if isAmountHidden {
            return "•• \(currency)"
        }
        
        guard let amount = Double(balance) else {
            return "0.00 \(currency)"
        }
        
        let preferredCurrency = UserDefaultsManager.shared.defaultCurrency ?? "UGX"
        let rate = CurrencyConverter.getRate(from: currency, to: preferredCurrency)
        let converted = amount * rate
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        
        let formatted = formatter.string(from: NSNumber(value: converted)) ?? String(format: "%.2f", converted)
        return "\(formatted) \(preferredCurrency)"
    }
    
    // MARK: - Refresh Data
    func refresh() {
        loadDashboard()
        updateGreeting()
    }
    
    // MARK: - Force Refresh (clears cache)
    func forceRefresh() {
        isLoading = true
        errorMessage = nil
        
        ProfileService.shared.forceRefresh { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let profileData):
                    self?.profile = profileData
                    self?.wallets = profileData.wallets
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Profile force refresh error: \(error.localizedDescription)")
                }
            }
        }
    }
}
