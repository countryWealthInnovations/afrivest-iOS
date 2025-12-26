//
//  GoldProductDetailView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 26/12/2025.
//


import SwiftUI

struct GoldProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(product: InvestmentProduct) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Product Header
                    productHeader
                    
                    // Stats Grid
                    statsGrid
                    
                    Divider()
                        .background(Color.borderDefault)
                    
                    // Description
                    if let description = viewModel.product.shortDescription {
                        descriptionSection(description)
                    }
                    
                    // Features
                    if let features = viewModel.product.features {
                        featuresSection(features)
                    }
                    
                    // Purchase Section
                    purchaseSection
                }
                .padding(Spacing.screenHorizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Gold Investment")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .alert("Success", isPresented: $viewModel.purchaseSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your gold purchase was successful!")
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
    }
    
    // MARK: - Product Header
    private var productHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                // Gold Icon
                Circle()
                    .fill(Color.primaryGold.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color.primaryGold)
                    )
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(viewModel.product.name)
                        .font(AppFont.heading3())
                        .foregroundColor(Color.textPrimary)
                    
                    if let partner = viewModel.product.partner {
                        Text(partner.name)
                            .font(AppFont.bodyRegular())
                            .foregroundColor(Color.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                statCard(
                    title: "Price Per Gram",
                    value: viewModel.product.minInvestmentFormatted,
                    color: Color.primaryGold
                )
                
                statCard(
                    title: "Expected Returns",
                    value: returnsText,
                    color: Color.successGreen
                )
            }
            
            HStack(spacing: Spacing.md) {
                statCard(
                    title: "Minimum Purchase",
                    value: formatAmount(viewModel.product.minInvestment),
                    color: Color.primaryGold
                )
                
                statCard(
                    title: "Storage",
                    value: "Secure Vault",
                    color: Color.textPrimary
                )
            }
        }
    }
    
    private func statCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(AppFont.bodySmall())
                .foregroundColor(Color.textSecondary)
            
            Text(value)
                .font(AppFont.bodyLarge())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .stroke(Color.borderDefault, lineWidth: 1)
        )
    }
    
    // MARK: - Description
    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("About Gold Investment")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            Text(description)
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
        }
    }
    
    // MARK: - Features
    private func featuresSection(_ features: [String]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Benefits")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.primaryGold)
                            .font(.system(size: 16))
                        
                        Text(feature)
                            .font(AppFont.bodyRegular())
                            .foregroundColor(Color.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Purchase Section
    private var purchaseSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Purchase Gold")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            // Amount Input (in grams)
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Amount in Grams")
                    .font(AppFont.bodySmall())
                    .foregroundColor(Color.textSecondary)
                
                TextField("Enter grams", text: $viewModel.amount)
                    .keyboardType(.decimalPad)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(Color.textPrimary)
                    .padding(Spacing.md)
                    .background(Color.inputBackground)
                    .cornerRadius(Spacing.radiusMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                            .stroke(viewModel.isAmountValid ? Color.borderActive : Color.borderDefault, lineWidth: 1)
                    )
                
                Text("Minimum: 10 grams")
                    .font(AppFont.footnote())
                    .foregroundColor(Color.textSecondary)
            }
            
            // Total Cost
            if let grams = Double(viewModel.amount), grams > 0,
               let pricePerGram = Double(viewModel.product.minInvestment) {
                HStack {
                    Text("Total Cost:")
                        .font(AppFont.bodyRegular())
                        .foregroundColor(Color.textSecondary)
                    
                    Spacer()
                    
                    Text("\(formatAmount(String(grams * pricePerGram))) \(viewModel.product.currency)")
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.primaryGold)
                }
                .padding(.vertical, Spacing.sm)
            }
            
            // Purchase Button
            Button(action: {
                viewModel.purchaseProduct()
            }) {
                Text("Purchase Gold")
                    .font(AppFont.bodyLarge())
                    .foregroundColor(Color.buttonPrimaryText)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(viewModel.isAmountValid ? Color.buttonPrimary : Color.buttonDisabled)
                    .cornerRadius(Spacing.radiusMedium)
            }
            .disabled(!viewModel.isAmountValid || viewModel.isLoading)
        }
        .padding(Spacing.md)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .stroke(Color.borderDefault, lineWidth: 1)
        )
    }
    
    // MARK: - Helpers
    private var returnsText: String {
        if viewModel.product.expectedReturns == "0.00" || viewModel.product.expectedReturns.isEmpty {
            return "Market Based"
        }
        return "\(viewModel.product.expectedReturns)% p.a"
    }
    
    private func formatAmount(_ amount: String) -> String {
        guard let value = Double(amount) else { return amount }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? amount
    }
}
