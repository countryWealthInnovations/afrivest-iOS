//
//  HomeViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 06/10/2025.
//

import Foundation
import SwiftUI
import Alamofire
import Combine
import Contacts

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
    @Published var matchedContacts: [AppContact] = []
    @Published var contactsPermissionDenied = false
    
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
    
    func loadContactsIfAuthorized() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .notDetermined, .denied, .restricted:
            contactsPermissionDenied = true
        default:
            // .authorized and .limited (iOS 18+) can both enumerate
            Task { await fetchAndMatchContacts() }
        }
    }
    
    func requestContactsPermission() {
        Task {
            let store = CNContactStore()
            do {
                let granted = try await store.requestAccess(for: .contacts)
                if granted {
                    contactsPermissionDenied = false
                    await fetchAndMatchContacts()
                } else {
                    contactsPermissionDenied = true
                }
            } catch {
                contactsPermissionDenied = true
            }
        }
    }
    
    private func fetchAndMatchContacts() async {
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        var phones: [String] = []
        var emails: [String] = []
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                for p in contact.phoneNumbers { phones.append(p.value.stringValue.replacingOccurrences(of: " ", with: "")) }
                for e in contact.emailAddresses { emails.append((e.value as String).lowercased()) }
            }
        } catch { return }
        
        guard !phones.isEmpty || !emails.isEmpty else { return }
        
        do {
            let body = LookupBody(phones: Array(phones.prefix(500)), emails: Array(emails.prefix(500)))
            let bodyDict = try JSONSerialization.jsonObject(with: JSONEncoder().encode(body)) as? [String: Any] ?? [:]
            let response: LookupData = try await APIClient.shared.request(
                "/contacts/lookup",
                method: .post,
                parameters: bodyDict,
                requiresAuth: true
            )
            let matched = response.contacts.map {
                AppContact(id: UUID().uuidString, name: $0.name,
                           phoneNumber: $0.phone, email: nil,
                           userId: $0.user_id, isRegistered: true)
            }
            self.matchedContacts = matched
        } catch {
            print("Home contact lookup failed: \(error)")
        }
    }
    
    func loadFeaturedInvestments() {
        Task {
            do {
                let products = try await InvestmentService.shared.getFeaturedProducts()
                self.featuredInvestments = Array(products.prefix(10))
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
    
    // Investment summary is a raw sum already in the user's currency; do not re-convert.
    func formatInvestmentValue(_ value: Double) -> String {
        let currency = UserDefaultsManager.shared.defaultCurrency ?? "UGX"
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
        return "\(formatted) \(currency)"
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
