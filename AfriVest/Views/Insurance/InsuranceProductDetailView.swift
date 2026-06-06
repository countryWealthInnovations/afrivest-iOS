//
//  InsuranceProductDetailView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 26/12/2025.
//

import SwiftUI

struct InsuranceProductDetailView: View {
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
                        descriptionSection(title: "About This Policy", text: short)
                    }
                    if let full = viewModel.product.description,
                       full != viewModel.product.shortDescription {
                        descriptionSection(title: "Policy Details", text: full)
                    }
                    if let features = viewModel.product.features {
                        coverageSection(features)
                    }
                    if let terms = viewModel.product.termsConditions {
                        descriptionSection(title: "Terms & Conditions", text: terms)
                    }
                    if let docs = viewModel.product.documents, !docs.isEmpty {
                        documentsSection(docs)
                    }
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
            Text("Your insurance purchase was successful!")
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
                    Image(systemName: "shield.fill")
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
                }
            }
        }
    }
    
    private let userCurrency: String = UserDefaultsManager.shared.defaultCurrency ?? "UGX"
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        let raw = Double(viewModel.product.minInvestment) ?? 0
        let rate = CurrencyConverter.getRate(from: viewModel.product.currency, to: userCurrency)
        let converted = raw * rate
        
        return VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                statCard(title: "Premium (\(viewModel.product.currency))", value: viewModel.product.minInvestmentFormatted, color: Color.primaryGold)
                statCard(title: "Premium (\(userCurrency))", value: "\(userCurrency) \(FeeCalculator.formatCurrency(converted))", color: Color.successGreen)
            }
            HStack(spacing: Spacing.md) {
                statCard(title: "Policy Period", value: viewModel.product.durationLabel, color: Color.textPrimary)
                statCard(title: "Coverage", value: "\(viewModel.product.currency) \(formatAmount(viewModel.product.price))", color: Color.primaryGold)
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
    private func descriptionSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title).font(AppFont.heading3()).foregroundColor(Color.textPrimary)
            Text(text.strippedHTML)
                .font(AppFont.bodyRegular()).foregroundColor(Color.textSecondary)
        }
    }
    
    private func documentsSection(_ docs: [InvestmentDocument]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Documents").font(AppFont.heading3()).foregroundColor(Color.textPrimary)
            ForEach(docs) { doc in
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "doc.fill").foregroundColor(Color.primaryGold)
                    Text(doc.title).font(AppFont.bodyRegular()).foregroundColor(Color.textPrimary)
                    Spacer()
                    if let url = doc.url, let link = URL(string: url) {
                        Link(destination: link) {
                            Image(systemName: "arrow.down.circle").foregroundColor(Color.primaryGold)
                        }
                    }
                }
                .padding(Spacing.sm)
                .background(Color.inputBackground)
                .cornerRadius(Spacing.radiusSmall)
            }
        }
    }
    
    // MARK: - Coverage Details
    private func coverageSection(_ features: [String]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Coverage Details")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Image(systemName: "checkmark.shield.fill")
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
            Text("Purchase Policy")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            // Amount Input (Premium)
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Premium Amount (\(viewModel.product.currency))")
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
                if let amt = Double(viewModel.amount), amt > 0 {
                    let rate = CurrencyConverter.getRate(from: viewModel.product.currency, to: userCurrency)
                    Text("≈ \(userCurrency) \(FeeCalculator.formatCurrency(amt * rate))")
                        .font(AppFont.footnote()).foregroundColor(Color.primaryGold)
                }
            }
            
            // Purchase Button
            Button(action: {
                viewModel.purchaseProduct()
            }) {
                Text("Purchase Policy")
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
    private func formatAmount(_ amount: String) -> String {
        guard let value = Double(amount) else { return amount }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? amount
    }
}

private extension String {
    var strippedHTML: String {
        var result = self
        result = result.replacingOccurrences(of: "<li>", with: "\n• ")
        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return result
    }
}
