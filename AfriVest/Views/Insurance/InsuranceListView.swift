//
//  InsuranceListView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//

import SwiftUI

struct InsuranceListView: View {
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
                                    InsuranceProductDetailView(product: product)
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
            .navigationTitle("Insurance Products")
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
                viewModel.loadProducts(categorySlug: "insurance")
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
            Image(systemName: "shield.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.textSecondary.opacity(0.5))
            
            Text("No insurance products available")
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}
