//
//  InvestmentProductsView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//

import SwiftUI

struct InvestmentProductsView: View {
    @StateObject private var viewModel = InvestmentViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showSortSheet = false
    
    let categories = [
        ("All", nil),
        ("Treasury Bonds", "treasury-bonds"),
        ("Unit Trusts", "unit-trusts"),
        ("Fixed Deposits", "fixed-deposits"),
        ("Real Estate", "real-estate")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Section
                    filterSection
                    
                    // Products List
                    ScrollView {
                        LazyVStack(spacing: Spacing.md) {
                            if viewModel.products.isEmpty && !viewModel.isLoading {
                                emptyStateView
                            } else {
                                ForEach(viewModel.products) { product in
                                    NavigationLink {
                                        ProductDetailView(product: product)
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
            }
            .navigationTitle("Investment Products")
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
                viewModel.loadProducts()
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .sheet(isPresented: $showSortSheet) {
                sortSheet
            }
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Category Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(categories, id: \.0) { category in
                        FilterChip(
                            title: category.0,
                            isSelected: viewModel.selectedCategorySlug == category.1,
                            color: Color.primaryGold,
                            action: {
                                viewModel.filterByCategory(category.1)
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.screenHorizontal)
            }
            
            // Sort Button
            Button(action: { showSortSheet = true }) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 14))
                    Text("Sort")
                        .font(AppFont.bodyRegular())
                }
                .foregroundColor(Color.primaryGold)
                .padding(.horizontal, Spacing.screenHorizontal)
            }
        }
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm)
    }
    
    // MARK: - Sort Sheet
    private var sortSheet: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Sort By")
                    .font(AppFont.heading2())
                    .foregroundColor(Color.textPrimary)
                Spacer()
                Button(action: { showSortSheet = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.textSecondary)
                }
            }
            .padding(Spacing.md)
            
            Divider()
                .background(Color.borderDefault)
            
            // Sort Options
            VStack(spacing: 0) {
                sortOption("Returns (High to Low)", value: "returns_high")
                sortOption("Returns (Low to High)", value: "returns_low")
                sortOption("Min Investment (Low to High)", value: "min_investment_low")
                sortOption("Min Investment (High to Low)", value: "min_investment_high")
            }
        }
        .background(Color.backgroundDark1)
        .presentationDetents([.height(300)])
    }
    
    private func sortOption(_ title: String, value: String) -> some View {
        Button(action: {
            viewModel.sortProducts(value)
            showSortSheet = false
        }) {
            HStack {
                Text(title)
                    .font(AppFont.bodyRegular())
                    .foregroundColor(Color.textPrimary)
                Spacer()
                if viewModel.selectedSortOption == value {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.primaryGold)
                }
            }
            .padding(Spacing.md)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(Color.textSecondary.opacity(0.5))
            
            Text("No products available")
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}


// MARK: - Product Card
struct ProductCard: View {
    let product: InvestmentProduct
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Top Section
            HStack(alignment: .top, spacing: Spacing.md) {
                // Product Image/Icon
                AsyncImage(url: URL(string: product.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.primaryGold)
                }
                .frame(width: 48, height: 48)
                .background(Color.primaryGold.opacity(0.1))
                .cornerRadius(Spacing.radiusSmall)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.textPrimary)
                        .lineLimit(2)
                    
                    Text(product.partner?.name ?? product.category?.name ?? "")
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Risk Badge
                Text(product.riskLevelText.uppercased())
                    .font(AppFont.footnote())
                    .foregroundColor(riskColor(product.riskLevelColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(riskColor(product.riskLevelColor).opacity(0.1))
                    .cornerRadius(4)
            }
            
            // Stats Section
            HStack(spacing: Spacing.lg) {
                // Returns
                VStack(alignment: .leading, spacing: 4) {
                    Text(returnsText)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.primaryGold)
                    
                    Text("Expected Returns")
                        .font(AppFont.footnote())
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Lock-in Period
                VStack(alignment: .leading, spacing: 4) {
                    Text(lockInText)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.textPrimary)
                    
                    Text("Lock-in Period")
                        .font(AppFont.footnote())
                        .foregroundColor(Color.textSecondary)
                }
            }
            
            Divider()
                .background(Color.borderDefault)
            
            // Minimum Investment
            VStack(alignment: .leading, spacing: 4) {
                Text(product.minimumInvestment)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(Color.primaryGold)
                
                Text("Minimum Investment")
                    .font(AppFont.footnote())
                    .foregroundColor(Color.textSecondary)
            }
        }
        .padding(Spacing.md)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .stroke(Color.borderDefault, lineWidth: 1)
        )
    }
    
    private var returnsText: String {
        if product.expectedReturns == "0.00" {
            return "No Retuns"
        }
        return "\(product.expectedReturns)% p.a"
    }
    
    private var lockInText: String {
        return product.durationLabel
    }
    private func riskColor(_ colorName: String) -> Color {
        switch colorName {
        case "success_green": return Color.successGreen
        case "warning_yellow": return Color.warningYellow
        case "error_red": return Color.errorRed
        default: return Color.textSecondary
        }
    }
}
