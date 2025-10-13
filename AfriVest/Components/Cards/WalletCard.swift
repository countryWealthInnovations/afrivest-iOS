//
//  WalletCard.swift
//  AfriVest
//
//  Created on 2025
//  Location: AfriVest/Components/Cards/WalletCard.swift
//

import SwiftUI

struct WalletCard: View {
    let wallet: Wallet
    let isAmountHidden: Bool
    let walletType: WalletType
    let onToggleVisibility: () -> Void
    let onAction: () -> Void
    
    enum WalletType {
        case deposit
        case interest
        
        var icon: String {
            switch self {
            case .deposit:
                return "wallet.bifold"
            case .interest:
                return "chart.line.uptrend.xyaxis"
            }
        }
        
        var title: String {
            switch self {
            case .deposit:
                return "Deposit Wallet"
            case .interest:
                return "Interest Wallet"
            }
        }
        
        var actionTitle: String {
            switch self {
            case .deposit:
                return "Deposit"
            case .interest:
                return "Withdraw"
            }
        }
        
        var actionIcon: String {
            switch self {
            case .deposit:
                return "chevron.down"
            case .interest:
                return "chevron.up"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Wallet Icon
            HStack {
                Image(systemName: walletType.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color.primaryGold)
                
                Spacer()
            }
            
            // Wallet Title with Hide Toggle
            HStack {
                Text(walletType.title)
                    .font(AppFont.bodyRegular())
                    .foregroundColor(Color.textSecondary)
                
                Spacer()
                
                Button(action: onToggleVisibility) {
                    Image(systemName: isAmountHidden ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.textSecondary)
                }
            }
            
            Spacer()
            
            // Balance Amount
            Text(formatBalance())
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
                .padding(.vertical, Spacing.xs)
            
            // Action Button
            Button(action: onAction) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: walletType.actionIcon)
                        .font(.system(size: 14))
                    
                    Text(walletType.actionTitle)
                        .font(AppFont.bodySmall())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color.primaryGold)
                .foregroundColor(Color.buttonPrimaryText)
                .cornerRadius(Spacing.radiusMedium)
            }
        }
        .padding(Spacing.md)
        .frame(height: 180)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
    }
    
    private func formatBalance() -> String {
        if isAmountHidden {
            return "•• \(wallet.currency)"
        }
        
        guard let amount = Double(wallet.balance) else {
            return "0.00 \(wallet.currency)"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        
        if let formatted = formatter.string(from: NSNumber(value: amount)) {
            return "\(formatted) \(wallet.currency)"
        }
        
        return "\(wallet.balance) \(wallet.currency)"
    }
}

// MARK: - Preview Helper
private func createMockWallet(id: Int, currency: String, balance: String) -> Wallet {
    let jsonString = """
    {
        "id": \(id),
        "currency": "\(currency)",
        "balance": "\(balance)",
        "status": "active",
        "formatted_balance": "\(balance) \(currency)",
        "last_transaction_at": null,
        "total_incoming": null,
        "total_outgoing": null,
        "created_at": null,
        "wallet_type": null
    }
    """
    
    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    return try! decoder.decode(Wallet.self, from: data)
}

// MARK: - Preview
struct WalletCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                WalletCard(
                    wallet: createMockWallet(id: 1, currency: "UGX", balance: "500000.00"),
                    isAmountHidden: false,
                    walletType: .deposit,
                    onToggleVisibility: {},
                    onAction: {}
                )
                
                WalletCard(
                    wallet: createMockWallet(id: 2, currency: "UGX", balance: "150000.00"),
                    isAmountHidden: false,
                    walletType: .interest,
                    onToggleVisibility: {},
                    onAction: {}
                )
            }
            .padding()
        }
        .appBackground()
    }
}
