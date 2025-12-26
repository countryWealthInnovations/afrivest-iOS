//
//  MarketplaceView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//


import SwiftUI

struct MarketplaceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        NavigationLink {
                            GoldMarketplaceView()
                        } label: {
                            marketplaceCard(
                                icon: "circle.fill",
                                title: "Gold",
                                description: "Buy physical gold bars and coins"
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.top, Spacing.md)
                }
            }
            .navigationTitle("Marketplace")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.textPrimary)
                    }
                }
            }
        }
    }
    
    private func marketplaceCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(Color.primaryGold)
                .frame(width: 60, height: 60)
                .background(Color.primaryGold.opacity(0.1))
                .cornerRadius(Spacing.radiusMedium)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFont.heading3())
                    .foregroundColor(Color.textPrimary)
                
                Text(description)
                    .font(AppFont.bodySmall())
                    .foregroundColor(Color.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.textSecondary)
        }
        .padding(Spacing.md)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .stroke(Color.borderDefault, lineWidth: 1)
        )
    }
}