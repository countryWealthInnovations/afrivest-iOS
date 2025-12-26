//
//  GoldMarketplaceView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//

import SwiftUI

struct GoldMarketplaceView: View {
    @StateObject private var viewModel = InvestmentViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        if viewModel.products.isEmpty && !viewModel.isLoading {
                            emptyStateView
                        } else {
                            ForEach(viewModel.products) { product in
                                NavigationLink {
                                    GoldProductDetailView(product: product)
                                } label: {
                                    ProductCard(product: product)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, 90)
                }
            }
            .navigationTitle("Gold Marketplace")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.textPrimary)
                    }
                }
            }
            .onAppear {
                viewModel.loadProducts(categorySlug: "gold")
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.primaryGold.opacity(0.5))
            
            Text("No gold products available")
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}
