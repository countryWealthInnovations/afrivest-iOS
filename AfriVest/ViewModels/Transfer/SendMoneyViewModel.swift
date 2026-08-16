//
//  SendMoneyViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 13/10/2025.
//

import Foundation
import Contacts
import Combine
import Alamofire

// MARK: - Contact Lookup Models
struct LookupBody: Codable, Sendable {
    let phones: [String]
    let emails: [String]
}

struct LookupMatchedContact: Codable, Sendable {
    let user_id: Int
    let name: String
    let phone: String?
    let avatar_url: String?
    
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        user_id   = try c.decode(Int.self,    forKey: .user_id)
        name      = try c.decode(String.self, forKey: .name)
        phone     = try c.decodeIfPresent(String.self, forKey: .phone)
        avatar_url = try c.decodeIfPresent(String.self, forKey: .avatar_url)
    }
    
    enum CodingKeys: String, CodingKey {
        case user_id, name, phone, avatar_url
    }
}

struct LookupData: Codable, Sendable {
    let contacts: [LookupMatchedContact]
    
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        contacts = try c.decode([LookupMatchedContact].self, forKey: .contacts)
    }
    
    enum CodingKeys: String, CodingKey { case contacts }
}

struct LookupResponse: Codable, Sendable {
    let success: Bool
    let data: LookupData
    
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        success = try c.decode(Bool.self,      forKey: .success)
        data    = try c.decode(LookupData.self, forKey: .data)
    }
    
    enum CodingKeys: String, CodingKey { case success, data }
}

@MainActor
class SendMoneyViewModel: ObservableObject {
    @Published var contacts: [AppContact] = []
    @Published var filteredContacts: [AppContact] = []
    @Published var selectedContact: AppContact?
    
    @Published var searchQuery: String = ""
    @Published var manualRecipient: String = ""
    @Published var amount: String = ""
    @Published var description: String = ""
    
    @Published var showManualEntry: Bool = false
    @Published var isLoading: Bool = false
    @Published var isSearching: Bool = false
    @Published var showError: Bool = false
    @Published var showSuccess: Bool = false
    @Published var errorMessage: String = ""
    
    @Published var completedTransaction: TransferTransaction?
    @Published var scannedUuid: String?
    
    private let transferService = TransferService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var senderCurrency: String {
        UserDefaultsManager.shared.defaultCurrency ?? "UGX"
    }
    
    var minimumAmount: Double {
        switch senderCurrency {
        case "UGX": return 5000
        case "KES": return 50
        case "NGN": return 500
        default: return 1
        }
    }
    
    var isFormValid: Bool {
        let hasRecipient = selectedContact?.userId != nil || scannedUuid != nil
        guard hasRecipient,
              let amountValue = Double(amount),
              amountValue >= minimumAmount else {
            return false
        }
        return true
    }
    
    func selectScannedUuid(_ uuid: String) {
        scannedUuid = uuid
        selectedContact = AppContact(
            id: UUID().uuidString, name: "Loading...",
            phoneNumber: nil, email: nil, userId: nil, isRegistered: true
        )
        Task {
            do {
                let response = try await transferService.lookupByUuid(uuid)
                if response.found, let user = response.user {
                    selectedContact = AppContact(
                        id: UUID().uuidString, name: user.name,
                        phoneNumber: user.phoneNumber, email: user.email ?? "",
                        userId: user.id, isRegistered: true
                    )
                }
            } catch {
                errorMessage = "Could not load recipient details"
                showError = true
            }
        }
    }
    
    // MARK: - Load Contacts
    func loadContacts() {
        Task {
            isLoading = true
            
            // Request contact access
            let store = CNContactStore()
            do {
                try await store.requestAccess(for: .contacts)
                await fetchContacts()
            } catch {
                errorMessage = "Unable to access contacts"
                showError = true
            }
            
            isLoading = false
        }
    }
    
    private func fetchContacts() async {
        let store = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        var fetchedContacts: [AppContact] = []
        
        do {
            try store.enumerateContacts(with: request) { contact, stop in
                let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                
                // Get phone numbers
                for phoneNumber in contact.phoneNumbers {
                    let number = phoneNumber.value.stringValue
                    fetchedContacts.append(AppContact(
                        id: UUID().uuidString,
                        name: name.isEmpty ? "Unknown" : name,
                        phoneNumber: number,
                        email: nil,
                        userId: nil,
                        isRegistered: false
                    ))
                }
                
                // Get emails
                for email in contact.emailAddresses {
                    let emailString = email.value as String
                    fetchedContacts.append(AppContact(
                        id: UUID().uuidString,
                        name: name.isEmpty ? "Unknown" : name,
                        phoneNumber: nil,
                        email: emailString,
                        userId: nil,
                        isRegistered: false
                    ))
                }
            }
            
            // Check which contacts are registered
            await checkRegisteredUsers(fetchedContacts)
            
        } catch {
            print("Failed to fetch contacts: \(error)")
        }
    }
    
    // MARK: - Check Registered Users (bulk lookup)
    private func checkRegisteredUsers(_ contacts: [AppContact]) async {
        let phones = contacts.compactMap { $0.phoneNumber }
        let emails = contacts.compactMap { $0.email }
        
        guard !phones.isEmpty || !emails.isEmpty else { return }
        
        do {
            let body = LookupBody(phones: phones, emails: emails)
            let bodyDict = try JSONSerialization.jsonObject(
                with: JSONEncoder().encode(body)
            ) as? [String: Any] ?? [:]
            let response: LookupData = try await APIClient.shared.request(
                "/contacts/lookup",
                method: .post,
                parameters: bodyDict,
                requiresAuth: true
            )
            
            // Build a quick lookup dict from phone → matched user
            var phoneMap: [String: LookupMatchedContact] = [:]
            for match in response.contacts {
                if let p = match.phone { phoneMap[p] = match }
            }
            
            let registered: [AppContact] = contacts.compactMap { contact in
                if let phone = contact.phoneNumber, let match = phoneMap[phone] {
                    return AppContact(id: contact.id, name: match.name,
                                      phoneNumber: phone, email: contact.email,
                                      userId: match.user_id, isRegistered: true)
                }
                return nil
            }
            
            self.contacts = registered
            self.filteredContacts = registered
            
        } catch {
            print("Contact lookup failed: \(error)")
        }
    }
    
    // MARK: - Filter Contacts
    func filterContacts() {
        if searchQuery.isEmpty {
            filteredContacts = contacts.filter { $0.isRegistered }
        } else {
            filteredContacts = contacts.filter { contact in
                contact.isRegistered && (
                    contact.name.localizedCaseInsensitiveContains(searchQuery) ||
                    contact.phoneNumber?.contains(searchQuery) == true ||
                    contact.email?.localizedCaseInsensitiveContains(searchQuery) == true
                )
            }
        }
    }
    
    // MARK: - Select Contact
    func selectContact(_ contact: AppContact) {
        selectedContact = contact
    }
    
    // MARK: - Search Manual Recipient
    func searchManualRecipient() {
        Task {
            isSearching = true
            
            do {
                let response = try await transferService.searchUser(phoneOrEmail: manualRecipient)
                
                if response.found, let user = response.user {
                    let contact = AppContact(
                        id: UUID().uuidString,
                        name: user.name,
                        phoneNumber: user.phoneNumber,
                        email: user.email,
                        userId: user.id,
                        isRegistered: true
                    )
                    selectedContact = contact
                    // Don't hide manual entry anymore since contacts section is hidden
                    // showManualEntry = false
                } else {
                    errorMessage = "User not found on AfriVest"
                    showError = true
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isSearching = false
        }
    }
    
    // MARK: - Initiate Transfer
    func initiateTransfer() {
        guard selectedContact != nil,
              let amountValue = Double(amount) else {
            return
        }
        let userId = selectedContact?.userId ?? 0
        
        Task {
            isLoading = true
            
            do {
                let userCurrency = UserDefaultsManager.shared.defaultCurrency ?? "UGX"
                let response = try await transferService.transferP2P(
                    recipientId: scannedUuid == nil ? userId : nil,
                    recipientUuid: scannedUuid,
                    amount: amountValue,
                    currency: userCurrency,
                    description: description.isEmpty ? nil : description
                )
                
                completedTransaction = response.transaction
                showSuccess = true
                
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isLoading = false
        }
    }
}
