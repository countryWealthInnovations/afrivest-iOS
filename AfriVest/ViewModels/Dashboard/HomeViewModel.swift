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
    @Published var user: User?
    @Published var wallets: [Wallet] = []
    @Published var recentTransactions: [Transaction] = []
    @Published var statistics: DashboardStatistics?
    
    // UI State
    @Published var isAmountHidden = false
    @Published var isOtherCurrenciesExpanded = false
    @Published var greeting = ""
    
    // All wallets go to deposit section, separated by currency
    var depositWallets: [Wallet] {
        wallets
    }
    
    // UGX wallet for deposit
    var depositWallet: Wallet? {
        wallets.first { $0.currency == "UGX" }
    }
    
    // Interest wallet - always nil (unpopulated by default)
    var interestWallet: Wallet? {
        return nil
    }
    
    // Other currency wallets (non-UGX)
    var otherCurrencyWallets: [Wallet] {
        wallets.filter { $0.currency != "UGX" }
    }
    
    init() {
        updateGreeting()
    }
    
    // MARK: - Load Dashboard Data
    func loadDashboard() {
        isLoading = true
        errorMessage = nil
        
        WalletService.shared.getDashboard { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    self?.user = response.user
                    self?.wallets = response.wallets
                    self?.recentTransactions = response.recentTransactions
                    self?.statistics = response.statistics
                    print("✅ Dashboard loaded: \(response.wallets.count) wallets")
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Dashboard load error: \(error.localizedDescription)")
                    
                    // Fallback to wallets endpoint
                    self?.loadWalletsFallback()
                }
            }
        }
    }
    
    // MARK: - Fallback to Wallets Endpoint
    private func loadWalletsFallback() {
        WalletService.shared.getWallets { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wallets):
                    self?.wallets = wallets
                    print("✅ Wallets loaded (fallback): \(wallets.count) wallets")
                    
                case .failure(let error):
                    self?.errorMessage = "Failed to load data: \(error.localizedDescription)"
                    print("❌ Wallets fallback error: \(error.localizedDescription)")
                }
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
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        
        if let formatted = formatter.string(from: NSNumber(value: amount)) {
            return "\(formatted) \(currency)"
        }
        
        return "\(balance) \(currency)"
    }
    
    // MARK: - Refresh Data
    func refresh() {
        loadDashboard()
        updateGreeting()
    }
}
