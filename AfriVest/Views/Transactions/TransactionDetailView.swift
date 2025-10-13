//
//  TransactionDetailView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 11/10/2025.
//

import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(Color.textPrimary)
                    }
                    
                    Text("Transaction Details")
                        .font(AppFont.heading3())
                        .foregroundColor(Color.textPrimary)
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.vertical, Spacing.md)
                
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        // Status Badge
                        statusBadge
                            .padding(.top, Spacing.md)
                        
                        // Amount
                        amountView
                            .padding(.bottom, Spacing.lg)
                        
                        // Transaction Details Card
                        transactionDetailsCard
                        
                        // Payment Details Card
                        paymentDetailsCard
                        
                        // Recipient Details Card (if transfer)
                        if transaction.type == "transfer" {
                            if let otherParty = transaction.otherParty {
                                otherPartyDetailsCard(otherParty: otherParty)
                            } else if let recipient = transaction.recipient {
                                otherPartyDetailsCard(otherParty: recipient)
                            }
                        }
                        
                        // Additional Details Card
                        additionalDetailsCard
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.bottom, Spacing.lg)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        Text(transaction.status.capitalized)
            .font(AppFont.bodySmall())
            .foregroundColor(statusTextColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(statusBackgroundColor)
            .cornerRadius(4)
    }
    
    // MARK: - Amount View
    private var amountView: some View {
        Text(formattedAmount)
            .font(AppFont.heading1())
            .foregroundColor(amountColor)
    }
    
    // MARK: - Transaction Details Card
    private var transactionDetailsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            DetailRow(label: "Reference", value: transaction.reference)
            Divider().background(Color.borderDefault)
            DetailRow(label: "Type", value: transactionTypeDisplayName)
            Divider().background(Color.borderDefault)
            DetailRow(label: "Date", value: formattedDate)
            Divider().background(Color.borderDefault)
            DetailRow(label: "Description", value: transactionDescription, isMultiline: true)
        }
        .padding(Spacing.md)
        .background(Color("3A3A3A"))
        .cornerRadius(Spacing.radiusMedium)
    }
    
    // MARK: - Payment Details Card
    private var paymentDetailsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Payment Details")
                .font(AppFont.bodyLarge())
                .foregroundColor(Color.textPrimary)
                .padding(.bottom, Spacing.xs)
            
            DetailRow(label: "Fee", value: formattedFee)
            Divider().background(Color.borderDefault)
            DetailRow(label: "Total", value: formattedTotal, valueFont: AppFont.bodyLarge())
            Divider().background(Color.borderDefault)
            DetailRow(label: "Payment Channel", value: paymentChannel)
        }
        .padding(Spacing.md)
        .background(Color("3A3A3A"))
        .cornerRadius(Spacing.radiusMedium)
    }
    
    // MARK: - Recipient Details Card
    private func otherPartyDetailsCard(otherParty: Recipient) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Dynamic title based on direction
            Text(otherPartyTitle)
                .font(AppFont.bodyLarge())
                .foregroundColor(Color.textPrimary)
                .padding(.bottom, Spacing.xs)
            
            DetailRow(label: "Name", value: otherParty.name)
            Divider().background(Color.borderDefault)
            DetailRow(label: "Email", value: otherParty.email, isMultiline: true)
        }
        .padding(Spacing.md)
        .background(Color("3A3A3A"))
        .cornerRadius(Spacing.radiusMedium)
    }

    private var otherPartyTitle: String {
        switch transaction.direction {
        case "sent":
            return "Recipient Details"
        case "received":
            return "Sender Details"
        default:
            return "Other Party"
        }
    }
    
    // MARK: - Additional Details Card
    private var additionalDetailsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Additional Details")
                .font(AppFont.bodyLarge())
                .foregroundColor(Color.textPrimary)
                .padding(.bottom, Spacing.xs)
            
            DetailRow(label: "External Ref", value: externalReference, isMultiline: true)
            Divider().background(Color.borderDefault)
            DetailRow(label: "Completed At", value: completedAt)
        }
        .padding(Spacing.md)
        .background(Color("3A3A3A"))
        .cornerRadius(Spacing.radiusMedium)
    }
    
    // MARK: - Computed Properties
    
    private var statusTextColor: Color {
        switch transaction.status {
        case "success":
            return Color.successGreen
        case "failed":
            return Color.errorRed
        case "pending":
            return Color.warningYellow
        default:
            return Color.textSecondary
        }
    }
    
    private var statusBackgroundColor: Color {
        statusTextColor.opacity(0.2)
    }
    
    private var formattedAmount: String {
        // Determine sign based on direction and type
        let sign: String
        if transaction.direction == "received" {
            sign = "+"
        } else if transaction.type == "deposit" {
            sign = "+"
        } else {
            sign = "-"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        
        if let formatted = formatter.string(from: NSNumber(value: transaction.amountDouble)) {
            return "\(sign) \(formatted) \(transaction.currency)"
        }
        
        return "\(sign) \(transaction.amount) \(transaction.currency)"
    }
    
    private var amountColor: Color {
        // Color based on direction for transfers
        if transaction.type == "transfer" {
            switch transaction.direction {
            case "received":
                return Color.successGreen
            case "sent":
                return Color.errorRed
            default:
                return Color.textPrimary
            }
        }
        
        // Color for other types
        switch transaction.type {
        case "deposit":
            return Color.successGreen
        case "withdrawal":
            return Color.errorRed
        default:
            return Color.textPrimary
        }
    }
    
    private var transactionTypeDisplayName: String {
        switch transaction.type {
        case "deposit":
            return "Deposit"
        case "withdrawal":
            return "Withdrawal"
        case "transfer":
            return "Transfer"
        case "bill_payment":
            return "Bill Payment"
        case "insurance":
            return "Insurance"
        case "investment":
            return "Investment"
        case "gold_purchase":
            return "Gold Purchase"
        case "crypto_purchase":
            return "Crypto Purchase"
        default:
            return transaction.type.capitalized
        }
    }
    
    private var transactionDescription: String {
        if let desc = transaction.description, !desc.isEmpty {
            return desc
        }
        return "No description"
    }
    
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = dateFormatter.date(from: transaction.createdAt) else {
            return transaction.createdAt
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy 'at' hh:mm a"
        return displayFormatter.string(from: date)
    }
    
    private var formattedFee: String {
        guard let feeAmount = transaction.feeAmount, let fee = Double(feeAmount), fee > 0 else {
            return "0.00 \(transaction.currency)"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        
        if let formatted = formatter.string(from: NSNumber(value: fee)) {
            return "\(formatted) \(transaction.currency)"
        }
        
        return "\(feeAmount) \(transaction.currency)"
    }
    
    private var formattedTotal: String {
        let total: Double
        
        if let totalAmount = transaction.totalAmount, let totalValue = Double(totalAmount) {
            total = totalValue
        } else {
            let amount = transaction.amountDouble
            let fee = Double(transaction.feeAmount ?? "0") ?? 0
            total = amount + fee
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        
        if let formatted = formatter.string(from: NSNumber(value: total)) {
            return "\(formatted) \(transaction.currency)"
        }
        
        return String(format: "%.2f %@", total, transaction.currency)
    }
    
    private var paymentChannel: String {
        transaction.paymentChannel?.capitalized ?? "N/A"
    }
    
    private var externalReference: String {
        transaction.externalReference ?? "N/A"
    }
    
    private var completedAt: String {
        guard let completedAt = transaction.completedAt else {
            return "Not completed"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = dateFormatter.date(from: completedAt) else {
            return completedAt
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy 'at' hh:mm a"
        return displayFormatter.string(from: date)
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let label: String
    let value: String
    var isMultiline: Bool = false
    var valueFont: Font = AppFont.bodyRegular()
    
    var body: some View {
        HStack(alignment: isMultiline ? .top : .center) {
            Text(label)
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(valueFont)
                .foregroundColor(Color.textPrimary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

