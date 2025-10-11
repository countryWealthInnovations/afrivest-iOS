//
//  TransactionListItem.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 06/10/2025.
//

import SwiftUI

struct TransactionListItem: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Transaction Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transactionDescription)
                    .font(AppFont.bodyRegular())
                    .foregroundColor(Color.textPrimary)
                
                Text(formattedDate)
                    .font(AppFont.footnote())
                    .foregroundColor(Color.textSecondary)
            }
            
            Spacer()
            
            // Amount and Status
            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedAmount)
                    .font(AppFont.bodyRegular())
                    .bold()
                    .foregroundColor(amountColor)
                
                // Status Badge
                Text(transaction.status.capitalized)
                    .font(AppFont.footnote())
                    .foregroundColor(statusTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusBackgroundColor)
                    .cornerRadius(4)
            }
        }
        .padding(Spacing.xs)
        .background(Color("3A3A3A"))
        .cornerRadius(Spacing.radiusMedium)
    }
    
    // MARK: - Computed Properties
    
    private var iconName: String {
        switch transaction.type {
        case "deposit":
            return "arrow.down.circle.fill"
        case "withdrawal":
            return "arrow.up.circle.fill"
        case "transfer":
            return "arrow.left.arrow.right.circle.fill"
        case "bill_payment":
            return "doc.text.fill"
        case "insurance":
            return "shield.fill"
        case "investment":
            return "chart.line.uptrend.xyaxis"
        case "gold_purchase":
            return "circle.fill"
        case "crypto_purchase":
            return "bitcoinsign.circle.fill"
        default:
            return "dollarsign.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch transaction.type {
        case "deposit":
            return Color.successGreen
        case "withdrawal":
            return Color.errorRed
        default:
            return Color.primaryGold
        }
    }
    
    private var iconBackgroundColor: Color {
        iconColor.opacity(0.2)
    }
    
    private var transactionDescription: String {
        if let desc = transaction.description, !desc.isEmpty {
            return desc
        }
        
        if transaction.type == "transfer", let recipient = transaction.recipient {
            return "Transfer to \(recipient.name)"
        }
        
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
            return "Transaction"
        }
    }
    
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = dateFormatter.date(from: transaction.createdAt) else {
            // Fallback for API responses without microseconds
            let fallbackFormatter = DateFormatter()
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            fallbackFormatter.timeZone = TimeZone(identifier: "UTC")
            if let fallbackDate = fallbackFormatter.date(from: transaction.createdAt) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM d, yyyy"
                return displayFormatter.string(from: fallbackDate)
            }
            return transaction.createdAt
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy"
        return displayFormatter.string(from: date)
    }
    
    
    private var formattedAmount: String {
        guard let amount = Double(transaction.amount) else {
            return transaction.amount
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        
        let sign = transaction.type == "deposit" ? "+" : "-"
        
        if let formatted = formatter.string(from: NSNumber(value: amount)) {
            return "\(sign) \(formatted) \(transaction.currency)"
        }
        
        return "\(sign) \(transaction.amount) \(transaction.currency)"
    }
    
    private var amountColor: Color {
        switch transaction.type {
        case "deposit":
            return Color.successGreen
        case "withdrawal":
            return Color.errorRed
        default:
            return Color.textPrimary
        }
    }
    
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
}

// MARK: - Preview
struct TransactionListItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            TransactionListItem(
                transaction: Transaction(
                    id: 1,
                    reference: "TXN-123",
                    type: "deposit",
                    amount: "50000.00",
                    feeAmount: "0.00",
                    totalAmount: "50000.00",
                    currency: "UGX",
                    status: "success",
                    paymentChannel: "flutterwave",
                    externalReference: nil,
                    description: "Card deposit",
                    createdAt: "2025-01-15T10:30:00Z",
                    updatedAt: "2025-01-15T10:35:00Z",
                    completedAt: "2025-01-15T10:35:00Z",
                    recipient: nil
                )
            )
            TransactionListItem(
                transaction: Transaction(
                    id: 2,
                    reference: "TXN-124",
                    type: "withdrawal",
                    amount: "25000.00",
                    feeAmount: "500.00",
                    totalAmount: "25500.00",
                    currency: "UGX",
                    status: "pending",
                    paymentChannel: "mtn",
                    externalReference: nil,
                    description: "Mobile money withdrawal",
                    createdAt: "2025-01-15T11:00:00Z",
                    updatedAt: "2025-01-15T11:00:00Z",
                    completedAt: nil,
                    recipient: nil
                )
            )
            
        }
        .padding()
        .appBackground()
    }
}
