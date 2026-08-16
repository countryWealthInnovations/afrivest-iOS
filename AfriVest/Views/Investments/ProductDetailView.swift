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
    
    private let userCurrency: String = UserDefaultsManager.shared.defaultCurrency ?? "UGX"
    
    init(product: InvestmentProduct) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    productHeader
                    statsGrid
                    Divider().background(Color.borderDefault)
                    // Short description
                    if let short = viewModel.product.shortDescription {
                        descriptionSection(title: "About", text: short)
                    }
                    // Full description (only if different from short)
                    if let full = viewModel.product.description,
                       full != viewModel.product.shortDescription {
                        descriptionSection(title: "Full Description", text: full)
                    }
                    if let features = viewModel.product.features {
                        featuresSection(features)
                    }
                    if let terms = viewModel.product.termsConditions {
                        descriptionSection(title: "Terms & Conditions", text: terms)
                    }
                    unitsSection
                    returnsProjectionSection
                    if let docs = viewModel.product.documents, !docs.isEmpty {
                        documentsSection(docs)
                    }
                    if let reviews = viewModel.product.reviews, !reviews.isEmpty {
                        reviewsSection(reviews)
                    }
                    purchaseSection
                }
                .padding(Spacing.screenHorizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(viewModel.product.name)
        .navigationBarTitleDisplayMode(.inline)
        .overlay { if viewModel.isLoading { LoadingOverlay() } }
        .alert("Success", isPresented: $viewModel.purchaseSuccess) {
            Button("OK") { dismiss() }
        } message: { Text("Your purchase was successful!") }
            .sheet(item: $viewModel.agreementToShow) { agreement in
                InvestmentAgreementSheet(
                    title: agreement.title,
                    bodyText: agreement.body,
                    onAccept: { viewModel.acceptAgreementAndContinue() },
                    onCancel: { viewModel.agreementToShow = nil }
                )
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let error = viewModel.errorMessage { Text(error) }
            }
    }
    
    // MARK: - Header
    private var productHeader: some View {
        HStack(spacing: Spacing.md) {
            AsyncImage(url: URL(string: viewModel.product.imageUrl ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
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
                if let category = viewModel.product.category {
                    Text(category.name)
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                Text(viewModel.product.riskLevelText.uppercased())
                    .font(AppFont.footnote())
                    .foregroundColor(riskColor(viewModel.product.riskLevelColor))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(riskColor(viewModel.product.riskLevelColor).opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                statCard(title: "Expected Returns", value: returnsText, color: Color.primaryGold)
                statCard(title: "Duration", value: viewModel.product.durationLabel, color: Color.textPrimary)
            }
            HStack(spacing: Spacing.md) {
                statCard(title: "Min Investment (\(viewModel.product.currency))", value: viewModel.product.minInvestmentFormatted, color: Color.primaryGold)
                statCard(title: "Min in \(userCurrency)", value: convertedMinInvestment, color: Color.successGreen)
            }
            HStack(spacing: Spacing.md) {
                statCard(title: "Availability", value: viewModel.product.availabilityStatus.capitalized, color: Color.textPrimary)
                statCard(title: "Rating", value: "\(viewModel.product.ratingAverage) (\(viewModel.product.ratingCount))", color: Color.primaryGold)
            }
        }
    }
    
    // MARK: - Returns Projection
    private var returnsProjectionSection: some View {
        let minRaw = Double(viewModel.product.minInvestment) ?? 0
        let returnsRate = Double(viewModel.product.expectedReturns) ?? 0
        let annualReturn = minRaw * returnsRate / 100
        let rate = CurrencyConverter.getRate(from: viewModel.product.currency, to: userCurrency)
        let annualInUserCurrency = annualReturn * rate
        
        return VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Returns Projection (on minimum)")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            HStack(spacing: Spacing.md) {
                projectionCard(
                    title: "Annual (\(viewModel.product.currency))",
                    value: "\(viewModel.product.currency) \(formatSmartCurrency(annualReturn))"
                )
                projectionCard(
                    title: "Annual (\(userCurrency))",
                    value: "\(userCurrency) \(formatSmartCurrency(annualInUserCurrency))"
                )
            }
        }
    }
    
    private func formatSmartCurrency(_ value: Double) -> String {
        if value == 0 { return "0" }
        if value >= 1 { return FeeCalculator.formatCurrency(value) }
        // Small value — show up to 4 significant decimal places
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.4f", value)
    }
    
    private func projectionCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(AppFont.bodySmall())
                .foregroundColor(Color.textSecondary)
            Text(value)
                .font(AppFont.bodyLarge())
                .foregroundColor(Color.successGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
        .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
    }
    
    // MARK: - Description
    private func descriptionSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title).font(AppFont.heading3()).foregroundColor(Color.textPrimary)
            Text(stripHTML(text)).font(AppFont.bodyRegular()).foregroundColor(Color.textSecondary)
        }
    }
    
    private func stripHTML(_ html: String) -> String {
        var result = html
        result = result.replacingOccurrences(of: "<li>", with: "\n• ", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "</li>", with: "", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "<br>", with: "\n", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "<br/>", with: "\n", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "<br />", with: "\n", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "<p>", with: "", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "</p>", with: "\n", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "\n\n\n", with: "\n\n", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Features
    private func featuresSection(_ features: [String]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Key Features").font(AppFont.heading3()).foregroundColor(Color.textPrimary)
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.successGreen).font(.system(size: 16))
                        Text(feature).font(AppFont.bodyRegular()).foregroundColor(Color.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Units Section
    private var unitsSection: some View {
        let total = viewModel.product.totalUnits
        let available = viewModel.product.unitsAvailable
        guard total != nil || available != nil else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Availability").font(AppFont.heading3()).foregroundColor(Color.textPrimary)
                HStack(spacing: Spacing.md) {
                    if let total = total {
                        statCard(title: "Total Units", value: "\(total)", color: Color.textPrimary)
                    }
                    if let available = available {
                        statCard(title: "Units Available", value: "\(available)", color: available > 0 ? Color.successGreen : Color.errorRed)
                    }
                }
            }
        )
    }
    
    // MARK: - Documents Section
    private func documentsSection(_ docs: [InvestmentDocument]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Documents").font(AppFont.heading3()).foregroundColor(Color.textPrimary)
            ForEach(docs) { doc in
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "doc.fill")
                        .foregroundColor(Color.primaryGold)
                        .font(.system(size: 16))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(doc.title).font(AppFont.bodyRegular()).foregroundColor(Color.textPrimary)
                        if let label = doc.typeLabel {
                            Text(label).font(AppFont.footnote()).foregroundColor(Color.textSecondary)
                        }
                    }
                    Spacer()
                    if let url = doc.url, let link = URL(string: url) {
                        Link(destination: link) {
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(Color.primaryGold)
                        }
                    }
                }
                .padding(Spacing.sm)
                .background(Color.inputBackground)
                .cornerRadius(Spacing.radiusSmall)
            }
        }
    }
    
    // MARK: - Reviews Section
    private func reviewsSection(_ reviews: [InvestmentReview]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Reviews (\(reviews.count))").font(AppFont.heading3()).foregroundColor(Color.textPrimary)
            ForEach(reviews) { review in
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= review.rating ? "star.fill" : "star")
                                    .foregroundColor(Color.primaryGold)
                                    .font(.system(size: 12))
                            }
                        }
                        Spacer()
                        if review.isVerifiedPurchase {
                            Text("✓ Verified").font(AppFont.footnote()).foregroundColor(Color.successGreen)
                        }
                    }
                    if let title = review.title {
                        Text(title).font(AppFont.bodyLarge()).foregroundColor(Color.textPrimary)
                    }
                    if let body = review.review {
                        Text(body).font(AppFont.bodyRegular()).foregroundColor(Color.textSecondary)
                    }
                    if let name = review.userName {
                        Text("— \(name)").font(AppFont.footnote()).foregroundColor(Color.textSecondary)
                    }
                }
                .padding(Spacing.md)
                .background(Color.inputBackground)
                .cornerRadius(Spacing.radiusMedium)
            }
        }
    }
    
    // MARK: - Purchase Section
    private var purchaseSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Purchase").font(AppFont.heading3()).foregroundColor(Color.textPrimary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Auto-Reinvest Returns").font(AppFont.bodyRegular()).foregroundColor(Color.textPrimary)
                    Text("Automatically reinvest your returns").font(AppFont.bodySmall()).foregroundColor(Color.textSecondary)
                }
                Spacer()
                Toggle("", isOn: $viewModel.autoReinvest).labelsHidden().tint(Color.primaryGold)
            }
            .padding(.bottom, Spacing.sm)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Amount (\(viewModel.product.currency))")
                    .font(AppFont.bodySmall()).foregroundColor(Color.textSecondary)
                TextField("Enter amount", text: $viewModel.amount)
                    .keyboardType(.decimalPad)
                    .font(AppFont.bodyLarge()).foregroundColor(Color.textPrimary)
                    .padding(Spacing.md)
                    .background(Color.inputBackground)
                    .cornerRadius(Spacing.radiusMedium)
                    .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .stroke(viewModel.isAmountValid ? Color.borderActive : Color.borderDefault, lineWidth: 1))
                Text("Minimum: \(viewModel.product.minInvestmentFormatted)")
                    .font(AppFont.footnote()).foregroundColor(Color.textSecondary)
                
                // Show equivalent in user currency
                if let amt = Double(viewModel.amount), amt > 0 {
                    let rate = CurrencyConverter.getRate(from: viewModel.product.currency, to: userCurrency)
                    let converted = amt * rate
                    Text("≈ \(userCurrency) \(FeeCalculator.formatCurrency(converted))")
                        .font(AppFont.footnote()).foregroundColor(Color.primaryGold)
                }
            }
            
            Button(action: { viewModel.purchaseProduct() }) {
                Text("Purchase Now")
                    .font(AppFont.bodyLarge()).foregroundColor(Color.buttonPrimaryText)
                    .frame(maxWidth: .infinity).padding(Spacing.md)
                    .background(viewModel.isAmountValid ? Color.buttonPrimary : Color.buttonDisabled)
                    .cornerRadius(Spacing.radiusMedium)
            }
            .disabled(!viewModel.isAmountValid || viewModel.isLoading)
        }
        .padding(Spacing.md)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
        .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
    }
    
    // MARK: - Helpers
    private var convertedMinInvestment: String {
        let raw = Double(viewModel.product.minInvestment) ?? 0
        let productCurrency = viewModel.product.currency
        guard userCurrency != productCurrency, raw > 0 else {
            return "\(productCurrency) \(FeeCalculator.formatCurrency(raw))"
        }
        let rate = CurrencyConverter.getRate(from: productCurrency, to: userCurrency)
        return "\(userCurrency) \(FeeCalculator.formatCurrency(raw * rate))"
    }
    
    private var returnsText: String {
        if viewModel.product.expectedReturns == "0.00" || viewModel.product.expectedReturns.isEmpty {
            return "No Returns"
        }
        return "\(viewModel.product.expectedReturns)% p.a"
    }
    
    private func statCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title).font(AppFont.bodySmall()).foregroundColor(Color.textSecondary)
            Text(value).font(AppFont.bodyLarge()).foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
        .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
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

