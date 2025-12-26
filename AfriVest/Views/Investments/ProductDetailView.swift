//
//  ProductDetailView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 26/12/2025.
//

import SwiftUI

struct ProductDetailView: View {
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
        .navigationTitle(viewModel.product.name)
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
            Text("Your purchase was successful!")
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
                // Product Image
                AsyncImage(url: URL(string: viewModel.product.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color.primaryGold)
                }
                .frame(width: 80, height: 80)
                .background(Color.primaryGold.opacity(0.1))
                .cornerRadius(Spacing.radiusMedium)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(viewModel.product.name)
                        .font(AppFont.heading3())
                        .foregroundColor(Color.textPrimary)
                    
                    if let partner = viewModel.product.partner {
                        Text(partner.name)
                            .font(AppFont.bodyRegular())
                            .foregroundColor(Color.textSecondary)
                    }
                    
                    // Risk Badge
                    Text(viewModel.product.riskLevelText.uppercased())
                        .font(AppFont.footnote())
                        .foregroundColor(riskColor(viewModel.product.riskLevelColor))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(riskColor(viewModel.product.riskLevelColor).opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                statCard(
                    title: "Expected Returns",
                    value: returnsText,
                    color: Color.primaryGold
                )
                
                statCard(
                    title: "Duration",
                    value: viewModel.product.durationLabel,
                    color: Color.textPrimary
                )
            }
            
            HStack(spacing: Spacing.md) {
                statCard(
                    title: "Minimum",
                    value: viewModel.product.minInvestmentFormatted,
                    color: Color.primaryGold
                )
                
                statCard(
                    title: "Currency",
                    value: viewModel.product.currency,
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
            Text("About")
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
            Text("Key Features")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.successGreen)
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
            Text("Purchase")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            // Amount Input
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Amount (\(viewModel.product.currency))")
                    .font(AppFont.bodySmall())
                    .foregroundColor(Color.textSecondary)
                
                TextField("Enter amount", text: $viewModel.amount)
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
                
                Text("Minimum: \(viewModel.product.minInvestmentFormatted)")
                    .font(AppFont.footnote())
                    .foregroundColor(Color.textSecondary)
            }
            
            // Purchase Button
            Button(action: {
                viewModel.purchaseProduct()
            }) {
                Text("Purchase Now")
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
            return "No Returns"
        }
        return "\(viewModel.product.expectedReturns)% p.a"
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
