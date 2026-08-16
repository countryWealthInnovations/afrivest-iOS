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
    @State private var showScanner = false
    
    var preselectedContact: AppContact? = nil
    
    var body: some View {
        ZStack {
            Color.backgroundDark1.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        recipientSearchSection
                        
                        if viewModel.selectedContact != nil {
                            transferFormSection
                        }
                        
                        manualEntrySection
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
            viewModel.loadContacts()
            if let contact = preselectedContact, contact.userId != nil {
                viewModel.selectContact(contact)
            }
        }
        .sheet(isPresented: $showScanner) {
            ScanQrView { uuid in
                viewModel.selectScannedUuid(uuid)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("Done") { dismiss() }
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
            Text("Send Money").h2Style()
            Spacer()
            Button(action: { showScanner = true }) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primaryGold)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.top, Spacing.md)
    }
    
    // MARK: - Recipient Search with inline dropdown
    private var recipientSearchSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recipient").labelStyle()
            
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textSecondary)
                    
                    TextField("Search by name, phone or email", text: $viewModel.searchQuery)
                        .font(AppFont.bodyRegular())
                        .foregroundColor(.textPrimary)
                        .autocapitalization(.none)
                        .onChange(of: viewModel.searchQuery) { _ in
                            if viewModel.selectedContact == nil {
                                viewModel.filterContacts()
                            }
                        }
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: {
                            viewModel.searchQuery = ""
                            viewModel.filteredContacts = []
                            viewModel.selectedContact = nil
                        }) {
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
                
                // Dropdown — only when typing and no contact selected yet
                if !viewModel.searchQuery.isEmpty && viewModel.selectedContact == nil {
                    VStack(spacing: 0) {
                        if viewModel.filteredContacts.isEmpty {
                            Text("No users found on AfriVest")
                                .font(AppFont.bodySmall())
                                .foregroundColor(.textSecondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.inputBackground)
                        } else {
                            ForEach(viewModel.filteredContacts.prefix(5), id: \.id) { contact in
                                Button(action: {
                                    viewModel.selectContact(contact)
                                    viewModel.searchQuery = contact.name
                                    viewModel.filteredContacts = []
                                }) {
                                    HStack(spacing: Spacing.sm) {
                                        Circle()
                                            .fill(Color.primaryGold.opacity(0.3))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Text(contact.name.prefix(1).uppercased())
                                                    .font(AppFont.bodyLarge())
                                                    .foregroundColor(.primaryGold)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(contact.name)
                                                .font(AppFont.bodyRegular())
                                                .foregroundColor(.textPrimary)
                                            Text(contact.displayIdentifier)
                                                .font(AppFont.bodySmall())
                                                .foregroundColor(.textSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.successGreen)
                                            .font(.system(size: 14))
                                    }
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.vertical, Spacing.sm)
                                }
                                Divider().background(Color.borderDefault)
                            }
                        }
                    }
                    .background(Color.inputBackground)
                    .cornerRadius(Spacing.radiusMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                            .stroke(Color.borderDefault, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                }
            }
            
            // Selected contact pill
            if let contact = viewModel.selectedContact {
                HStack {
                    Text("To: \(contact.name)")
                        .font(AppFont.bodySmall())
                        .foregroundColor(.primaryGold)
                    Spacer()
                    Button(action: {
                        viewModel.selectedContact = nil
                        viewModel.searchQuery = ""
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color.primaryGold.opacity(0.1))
                .cornerRadius(Spacing.radiusMedium)
            }
        }
    }
    
    // MARK: - Manual Entry Section
    private var manualEntrySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Button(action: { viewModel.showManualEntry.toggle() }) {
                HStack {
                    Image(systemName: viewModel.showManualEntry ? "chevron.up" : "person.crop.circle.badge.plus")
                        .foregroundColor(.primaryGold)
                    Text(viewModel.showManualEntry ? "Hide manual entry" : "Enter phone/email manually")
                        .font(AppFont.bodyRegular())
                        .foregroundColor(.primaryGold)
                }
            }
            
            if viewModel.showManualEntry {
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
    }
    
    // MARK: - Transfer Form Section
    private var transferFormSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Divider().background(Color.borderDefault)
            
            Text("Transfer Details")
                .font(AppFont.heading3())
                .foregroundColor(.textPrimary)
            
            AppTextField(
                label: "Amount (\(viewModel.senderCurrency))",
                placeholder: "Enter amount",
                text: $viewModel.amount,
                keyboardType: .decimalPad
            )
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Description (Optional)").labelStyle()
                
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
            
            VStack(spacing: Spacing.sm) {
                summaryRow(label: "Recipient", value: viewModel.selectedContact?.name ?? "")
                summaryRow(label: "You Send", value: "\(viewModel.amount) \(viewModel.senderCurrency)")
                summaryRow(label: "Fee", value: "0.00 \(viewModel.senderCurrency)")
                Divider().background(Color.borderDefault)
                summaryRow(label: "Total", value: "\(viewModel.amount) \(viewModel.senderCurrency)", isTotal: true)
                // Recipient conversion shown after transfer completes
            }
            .padding(Spacing.md)
            .background(Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
            
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
}
