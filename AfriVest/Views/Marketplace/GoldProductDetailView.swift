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
                    if let short = viewModel.product.shortDescription {
                        descriptionSection(short)
                    }
                    if let full = viewModel.product.description,
                       full != viewModel.product.shortDescription {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Full Description").font(AppFont.heading3()).foregroundColor(Color.textPrimary)
                            Text(stripHTML(full)).font(AppFont.bodyRegular()).foregroundColor(Color.textSecondary)
                        }
                    }
                    if let features = viewModel.product.features {
                        featuresSection(features)
                    }
                    if let terms = viewModel.product.termsConditions {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Terms & Conditions").font(AppFont.heading3()).foregroundColor(Color.textPrimary)
                            Text(terms).font(AppFont.bodyRegular()).foregroundColor(Color.textSecondary)
                        }
                    }
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
    
    private let userCurrency: String = UserDefaultsManager.shared.defaultCurrency ?? "UGX"
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        let raw = Double(viewModel.product.minInvestment) ?? 0
        let rate = CurrencyConverter.getRate(from: viewModel.product.currency, to: userCurrency)
        let convertedPerGram = raw * rate
        
        return VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                statCard(title: "Price/gram (\(viewModel.product.currency))", value: viewModel.product.minInvestmentFormatted, color: Color.primaryGold)
                statCard(title: "Price/gram (\(userCurrency))", value: "\(userCurrency) \(FeeCalculator.formatCurrency(convertedPerGram))", color: Color.successGreen)
            }
            HStack(spacing: Spacing.md) {
                statCard(title: "Expected Returns", value: returnsText, color: Color.successGreen)
                statCard(title: "Storage", value: "Secure Vault", color: Color.textPrimary)
            }
            HStack(spacing: Spacing.md) {
                statCard(title: "Availability", value: viewModel.product.availabilityStatus.capitalized, color: Color.textPrimary)
                statCard(title: "Rating", value: "\(viewModel.product.ratingAverage) (\(viewModel.product.ratingCount))", color: Color.primaryGold)
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
            Text(stripHTML(description))
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
        }
    }
    
    private func stripHTML(_ html: String) -> String {
        var result = html
        result = result.replacingOccurrences(of: "<li>", with: "\n• ", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "</li>", with: "", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "<br>", with: "\n", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "<br/>", with: "\n", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "<p>", with: "", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "</p>", with: "\n", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
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
                let totalBase = grams * pricePerGram
                let rate = CurrencyConverter.getRate(from: viewModel.product.currency, to: userCurrency)
                let totalConverted = totalBase * rate
                VStack(spacing: Spacing.xs) {
                    HStack {
                        Text("Total (\(viewModel.product.currency)):")
                            .font(AppFont.bodyRegular()).foregroundColor(Color.textSecondary)
                        Spacer()
                        Text("\(viewModel.product.currency) \(formatAmount(String(totalBase)))")
                            .font(AppFont.bodyLarge()).foregroundColor(Color.primaryGold)
                    }
                    HStack {
                        Text("Total (\(userCurrency)):")
                            .font(AppFont.bodyRegular()).foregroundColor(Color.textSecondary)
                        Spacer()
                        Text("\(userCurrency) \(FeeCalculator.formatCurrency(totalConverted))")
                            .font(AppFont.bodyLarge()).foregroundColor(Color.successGreen)
                    }
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
