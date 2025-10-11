//
//  DepositStatusView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 10/10/2025.
//

import SwiftUI

struct DepositStatusView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = DepositViewModel()
    
    let transactionId: Int
    let reference: String
    let amount: String
    let currency: String
    let network: String
    
    @State private var shouldDismiss = false
    
    var body: some View {
        ZStack {
            Color.backgroundDark1.ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                if let status = viewModel.transactionStatus {
                    // Show status based on transaction state
                    switch status.status {
                    case "success":
                        SuccessView(status: status, onDone: {
                            shouldDismiss = true
                        })
                    case "failed":
                        FailureView(status: status, onRetry: {
                            presentationMode.wrappedValue.dismiss()
                        }, onCancel: {
                            shouldDismiss = true
                        })
                    default:
                        LoadingView(reference: reference, amount: amount, currency: currency, network: network)
                    }
                } else {
                    LoadingView(reference: reference, amount: amount, currency: currency, network: network)
                }
                
                Spacer()
            }
            .padding(Spacing.screenHorizontal)
        }
        .fullScreenCover(isPresented: $shouldDismiss) {
            DashboardView() // Navigate to dashboard
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    let reference: String
    let amount: String
    let currency: String
    let network: String
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(2)
                .tint(.primaryGold)
            
            Text("Processing Payment...")
                .h2Style()
            
            Text("Please approve the payment on your phone")
                .bodyRegularStyle()
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            // Transaction Details
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Transaction Details")
                    .bodyRegularStyle()
                    .foregroundColor(.textSecondary)
                
                Text(reference)
                    .bodyLargeStyle()
                
                Text("\(amount) \(currency)")
                    .h2Style()
                    .foregroundColor(.primaryGold)
                    .padding(.top, Spacing.xs)
                
                Text("\(network) Mobile Money")
                    .bodyRegularStyle()
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.md)
            .background(Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
        }
    }
}

// MARK: - Success View
struct SuccessView: View {
    let status: TransactionStatus
    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.successGreen)
            
            Text("Deposit Successful!")
                .h1Style()
                .foregroundColor(.successGreen)
            
            Text("Your wallet has been credited")
                .bodyRegularStyle()
                .foregroundColor(.textSecondary)
            
            VStack(spacing: Spacing.md) {
                InfoRow(label: "Amount", value: "\(status.amount) \(status.currency)")
                InfoRow(label: "Reference", value: status.reference)
                InfoRow(label: "Network", value: status.network ?? "Mobile Money")
                InfoRow(label: "Status", value: "Completed", valueColor: .successGreen)
            }
            .padding(Spacing.md)
            .background(Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
            
            PrimaryButton(
                title: "Done",
                action: onDone,
                isLoading: false,
                isEnabled: true
            )
            .padding(.top, Spacing.md)
        }
    }
}

// MARK: - Failure View
struct FailureView: View {
    let status: TransactionStatus
    let onRetry: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.errorRed)
            
            Text("Payment Failed")
                .h1Style()
                .foregroundColor(.errorRed)
            
            Text(status.error?.message ?? "Transaction was not completed")
                .bodyRegularStyle()
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            if let action = status.error?.action {
                Text(action)
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)
            }
            
            VStack(spacing: Spacing.md) {
                InfoRow(label: "Amount", value: "\(status.amount) \(status.currency)")
                InfoRow(label: "Reference", value: status.reference)
                InfoRow(label: "Status", value: "Failed", valueColor: .errorRed)
            }
            .padding(Spacing.md)
            .background(Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
            
            if status.error?.canRetry == true {
                HStack(spacing: Spacing.sm) {
                    Button(action: onRetry) {
                        Text("Try Again")
                            .font(AppFont.button())
                            .foregroundColor(.buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: Spacing.buttonHeight)
                            .background(Color.primaryGold)
                            .cornerRadius(Spacing.radiusMedium)
                    }
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(AppFont.button())
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: Spacing.buttonHeight)
                            .background(Color.buttonDisabled)
                            .cornerRadius(Spacing.radiusMedium)
                    }
                }
            } else {
                PrimaryButton(
                    title: "Close",
                    action: onCancel,
                    isLoading: false,
                    isEnabled: true
                )
            }
        }
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .textPrimary
    
    var body: some View {
        HStack {
            Text(label)
                .bodyRegularStyle()
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .bodyLargeStyle()
                .foregroundColor(valueColor)
        }
    }
}
