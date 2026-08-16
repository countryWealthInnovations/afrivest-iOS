//
//  BankTransferConfirmationView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 08/07/2026.
//

import SwiftUI
import Combine

struct BankTransferConfirmationView: View {
    @Environment(\.presentationMode) var presentationMode
    let details: BankTransferDetails
    
    @State private var timeRemaining: TimeInterval?
    @State private var copiedField: String?
    @State private var isConfirmed: Bool = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let statusPollTimer = Timer.publish(every: 8, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.backgroundDark1.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text(details.type == .bankTransfer ? "Bank Transfer Details" : "Pay With Bank Details")
                        .h2Style()
                    Spacer()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.top, Spacing.md)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        
                        if isConfirmed {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.successGreen)
                                Text("Payment confirmed. Your wallet has been credited.")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.successGreen)
                            }
                            .padding(Spacing.md)
                            .background(Color.inputBackground)
                            .cornerRadius(Spacing.radiusMedium)
                        }
                        
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            if details.type == .bankTransfer {
                                detailRow(label: "Bank Name", value: details.bankName ?? "N/A", copyable: false)
                                detailRow(label: "Account Number", value: details.accountNumber ?? "N/A", copyable: true, fieldKey: "account")
                            } else {
                                detailRow(label: "Sort Code", value: details.sortCode ?? "N/A", copyable: true, fieldKey: "sort")
                                detailRow(label: "Account Number", value: details.accountNumber ?? "N/A", copyable: true, fieldKey: "account")
                            }
                            
                            detailRow(label: "Amount", value: "\(details.currency) \(details.amount)", copyable: false)
                            detailRow(label: "Reference", value: details.reference, copyable: true, fieldKey: "reference")
                            
                            if let remaining = timeRemaining, remaining > 0, !isConfirmed {
                                detailRow(label: "Expires In", value: formatTime(remaining), copyable: false)
                            }
                        }
                        .padding(Spacing.md)
                        .background(Color.inputBackground)
                        .cornerRadius(Spacing.radiusMedium)
                        
                        if !isConfirmed {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.textSecondary)
                                Text("Open your banking app now to complete the transfer. Your wallet will be credited automatically once payment is confirmed.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(Spacing.md)
                            .background(Color.inputBackground)
                            .cornerRadius(Spacing.radiusMedium)
                        }
                        
                        PrimaryButton(
                            title: "Done",
                            action: {
                                presentationMode.wrappedValue.dismiss()
                            },
                            isLoading: false,
                            isEnabled: true
                        )
                    }
                    .padding(Spacing.screenHorizontal)
                    .padding(.top, Spacing.md)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupTimer()
            checkStatus()
        }
        .onReceive(timer) { _ in
            guard var remaining = timeRemaining, !isConfirmed else { return }
            remaining -= 1
            timeRemaining = max(remaining, 0)
        }
        .onReceive(statusPollTimer) { _ in
            if !isConfirmed {
                checkStatus()
            }
        }
    }
    
    private func checkStatus() {
        Task {
            if let status = try? await DepositService.shared.checkDepositStatus(transactionId: details.transactionId) {
                if status.status.lowercased() == "success" || status.status.lowercased() == "successful" {
                    BankTransferDetails.clear()
                    isConfirmed = true
                }
            }
        }
    }
    
    private func setupTimer() {
        guard let expiration = details.expiration else { return }
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: expiration) {
            timeRemaining = date.timeIntervalSinceNow
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func detailRow(label: String, value: String, copyable: Bool, fieldKey: String = "") -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
                Text(value)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(.textPrimary)
            }
            Spacer()
            if copyable {
                Button(action: {
                    UIPasteboard.general.string = value
                    copiedField = fieldKey
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if copiedField == fieldKey { copiedField = nil }
                    }
                }) {
                    Text(copiedField == fieldKey ? "Copied" : "Copy")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primaryGold)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}
