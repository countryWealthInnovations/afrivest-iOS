//
//  SendMoneyViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 13/10/2025.
//

import Foundation
import Contacts
import Combine

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
    
    private let transferService = TransferService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var isFormValid: Bool {
        guard selectedContact != nil,
              let amountValue = Double(amount),
              amountValue >= 10000 else {
            return false
        }
        return true
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
    
    // MARK: - Check Registered Users
    private func checkRegisteredUsers(_ contacts: [AppContact]) async {
        var updatedContacts: [AppContact] = []
        
        for contact in contacts {
            let query = contact.phoneNumber ?? contact.email ?? ""
            
            do {
                let response = try await transferService.searchUser(phoneOrEmail: query)
                
                if response.found, let user = response.user {
                    updatedContacts.append(AppContact(
                        id: contact.id,
                        name: user.name,
                        phoneNumber: contact.phoneNumber,
                        email: contact.email,
                        userId: user.id,
                        isRegistered: true
                    ))
                } else {
                    updatedContacts.append(contact)
                }
            } catch {
                updatedContacts.append(contact)
            }
        }
        
        self.contacts = updatedContacts
        self.filteredContacts = updatedContacts.filter { $0.isRegistered }
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
        guard let contact = selectedContact,
              let userId = contact.userId,
              let amountValue = Double(amount) else {
            return
        }
        
        Task {
            isLoading = true
            
            do {
                let response = try await transferService.transferP2P(
                    recipientId: userId,
                    amount: amountValue,
                    currency: "UGX",
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
