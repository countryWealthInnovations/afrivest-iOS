//
//  SendMoneyView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 13/10/2025.
//

import SwiftUI
import Contacts

struct SendMoneyView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SendMoneyViewModel()
    
    var body: some View {
        ZStack {
            Color.backgroundDark1.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        // Search Bar
                        //searchSection
                        
                        // Always show manual entry (contacts hidden for now)
                        manualEntrySection
                        
//                        // Contacts List or Manual Entry
//                        if viewModel.showManualEntry {
//                            manualEntrySection
//                        } else {
//                            contactsSection
//                        }
                        
                        // Transfer Form (shows when recipient selected)
                        if viewModel.selectedContact != nil {
                            transferFormSection
                        }
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.top, Spacing.md)
                }
            }
            
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // loadContacts() commented out - not using phone contacts for now
            viewModel.showManualEntry = true // Show manual entry by default
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("Done") {
                dismiss()
            }
        } message: {
            if let transaction = viewModel.completedTransaction {
                Text("Sent \(transaction.amount) \(transaction.currency) to \(transaction.recipient)")
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            Text("Send Money")
                .h2Style()
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.top, Spacing.md)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Search Recipient")
                .labelStyle()
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textSecondary)
                
                TextField("Phone or Email", text: $viewModel.searchQuery)
                    .font(AppFont.bodyRegular())
                    .foregroundColor(.textPrimary)
                    .autocapitalization(.none)
                    // Removed auto-filter - not using contacts anymore
                    // .onChange(of: viewModel.searchQuery) { _ in
                    //     viewModel.filterContacts()
                    // }
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: { viewModel.searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding()
            .background(Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(Color.borderDefault, lineWidth: 1)
            )
            
            // Manual Entry Toggle
            Button(action: { viewModel.showManualEntry.toggle() }) {
                HStack {
                    Image(systemName: viewModel.showManualEntry ? "person.crop.circle.fill" : "person.crop.circle.badge.plus")
                        .foregroundColor(.primaryGold)
                    Text(viewModel.showManualEntry ? "Back to Contacts" : "Enter Manually")
                        .font(AppFont.bodyRegular())
                        .foregroundColor(.primaryGold)
                }
            }
        }
    }
    
    // MARK: - Contacts Section
    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Select Recipient")
                .labelStyle()
            
            if viewModel.filteredContacts.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.filteredContacts, id: \.id) { contact in
                    contactRow(contact: contact)
                }
            }
        }
    }
    
    // MARK: - Contact Row
    private func contactRow(contact: AppContact) -> some View {
        Button(action: { viewModel.selectContact(contact) }) {
            HStack(spacing: Spacing.md) {
                // Avatar
                Circle()
                    .fill(contact.isRegistered ? Color.primaryGold.opacity(0.3) : Color.textSecondary.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(contact.name.prefix(1).uppercased())
                            .font(AppFont.heading3())
                            .foregroundColor(contact.isRegistered ? .primaryGold : .textSecondary)
                    )
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(.textPrimary)
                    
                    Text(contact.displayIdentifier)
                        .font(AppFont.bodySmall())
                        .foregroundColor(.textSecondary)
                    
                    if contact.isRegistered {
                        Text("✓ Registered")
                            .font(AppFont.bodySmall())
                            .foregroundColor(.successGreen)
                    } else {
                        Text("Not on AfriVest")
                            .font(AppFont.bodySmall())
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                if viewModel.selectedContact?.id == contact.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primaryGold)
                }
            }
            .padding(Spacing.md)
            .background(viewModel.selectedContact?.id == contact.id ? Color.primaryGold.opacity(0.1) : Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(viewModel.selectedContact?.id == contact.id ? Color.primaryGold : Color.borderDefault, lineWidth: 1)
            )
        }
        .disabled(!contact.isRegistered)
        .opacity(contact.isRegistered ? 1.0 : 0.5)
    }
    
    // MARK: - Manual Entry Section
    private var manualEntrySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Enter Recipient Details")
                .labelStyle()
            
            AppTextField(
                label: "Phone Number or Email",
                placeholder: "+256700000000 or email@example.com",
                text: $viewModel.manualRecipient,
                keyboardType: .emailAddress
            )
            
            PrimaryButton(
                title: "Search User",
                action: { viewModel.searchManualRecipient() },
                isLoading: viewModel.isSearching,
                isEnabled: !viewModel.manualRecipient.isEmpty
            )
        }
    }
    
    // MARK: - Transfer Form Section
    private var transferFormSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Divider().background(Color.borderDefault)
            
            Text("Transfer Details")
                .font(AppFont.heading3())
                .foregroundColor(.textPrimary)
            
            // Amount
            AppTextField(
                label: "Amount (UGX)",
                placeholder: "Enter amount (min 5,000)",
                text: $viewModel.amount,
                keyboardType: .decimalPad
            )
            
            // Description
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Description (Optional)")
                    .labelStyle()
                
                TextField("What's this for?", text: $viewModel.description)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(.textPrimary)
                    .padding()
                    .background(Color.inputBackground)
                    .cornerRadius(Spacing.radiusMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                            .stroke(Color.borderDefault, lineWidth: 1)
                    )
            }
            
            // Summary
            VStack(spacing: Spacing.sm) {
                summaryRow(label: "Recipient", value: viewModel.selectedContact?.name ?? "")
                summaryRow(label: "Amount", value: "\(viewModel.amount) UGX")
                summaryRow(label: "Fee", value: "0.00 UGX")
                Divider().background(Color.borderDefault)
                summaryRow(label: "Total", value: "\(viewModel.amount) UGX", isTotal: true)
            }
            .padding(Spacing.md)
            .background(Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
            
            // Send Button
            PrimaryButton(
                title: "Send Money",
                action: { viewModel.initiateTransfer() },
                isLoading: viewModel.isLoading,
                isEnabled: viewModel.isFormValid
            )
        }
    }
    
    // MARK: - Summary Row
    private func summaryRow(label: String, value: String, isTotal: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(isTotal ? AppFont.bodyLarge() : AppFont.bodyRegular())
                .foregroundColor(isTotal ? .textPrimary : .textSecondary)
            
            Spacer()
            
            Text(value)
                .font(isTotal ? AppFont.heading3() : AppFont.bodyRegular())
                .foregroundColor(isTotal ? .primaryGold : .textPrimary)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 50))
                .foregroundColor(.textSecondary)
            
            Text("No contacts found")
                .font(AppFont.bodyLarge())
                .foregroundColor(.textSecondary)
            
            Text("Try searching or entering manually")
                .font(AppFont.bodySmall())
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }
}
