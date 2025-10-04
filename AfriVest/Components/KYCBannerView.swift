//
//  KYCBannerView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI

struct KYCBannerView: View {
    @Binding var isVisible: Bool
    let onTap: () -> Void
    
    var body: some View {
        if isVisible {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "person.badge.shield.checkmark")
                    .foregroundColor(.warningYellow)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("KYC Verification Pending")
                        .font(AppFont.label())
                        .foregroundColor(.textPrimary)
                    
                    Text("Complete KYC to unlock full features")
                        .font(AppFont.bodySmall())
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button(action: onTap) {
                    Text("Complete")
                        .font(AppFont.label())
                        .foregroundColor(.primaryGold)
                }
            }
            .padding(Spacing.md)
            .background(Color.warningYellow.opacity(0.15))
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(Color.warningYellow, lineWidth: 1)
            )
            .padding(.horizontal, Spacing.screenHorizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
