//
//  NotificationSettingsView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 27/12/2025.
//


import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var viewModel = NotificationSettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.md) {
                    // Push Notifications
                    NotificationToggleRow(
                        icon: "bell.badge.fill",
                        title: "Push Notifications",
                        subtitle: "Receive alerts on your device",
                        isEnabled: $viewModel.pushEnabled
                    )
                    
                    // Email Notifications
                    NotificationToggleRow(
                        icon: "envelope.fill",
                        title: "Email Notifications",
                        subtitle: "Receive updates via email",
                        isEnabled: $viewModel.emailEnabled
                    )
                    
                    // SMS Notifications
                    NotificationToggleRow(
                        icon: "message.fill",
                        title: "SMS Notifications",
                        subtitle: "Receive text messages",
                        isEnabled: $viewModel.smsEnabled
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.top, Spacing.lg)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.primaryGold.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(Color.primaryGold)
                    .font(.system(size: 22))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(Color.textPrimary)
                
                Text(subtitle)
                    .font(AppFont.bodySmall())
                    .foregroundColor(Color.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(Color.primaryGold)
        }
        .padding(Spacing.md)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
    }
}
