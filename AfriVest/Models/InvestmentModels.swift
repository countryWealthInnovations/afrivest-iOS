//
//  InvestmentModels.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//

import Foundation

// MARK: - Investment Category (Full - not used in product listing)
struct InvestmentCategory: Codable, Identifiable, Sendable {
    let id: Int
    let name: String
    let slug: String
    let description: String?
    let icon: String?
    let displayOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, icon
        case displayOrder = "display_order"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        displayOrder = try container.decode(Int.self, forKey: .displayOrder)
    }
}

// MARK: - Investment Partner (Full - not used in product listing)
struct InvestmentPartner: Codable, Sendable {
    let id: Int
    let name: String
    let logoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case logoUrl = "logo_url"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        logoUrl = try container.decodeIfPresent(String.self, forKey: .logoUrl)
    }
}

// MARK: - Simplified Category (from API product listing)
struct InvestmentCategorySimple: Codable, Sendable {
    let name: String
    let slug: String
    let icon: String?
    
    enum CodingKeys: String, CodingKey {
        case name, slug, icon
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
    }
}

// MARK: - Simplified Partner (from API product listing)
struct InvestmentPartnerSimple: Codable, Sendable {
    let name: String
    let logo: String?
    
    enum CodingKeys: String, CodingKey {
        case name, logo
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        logo = try container.decodeIfPresent(String.self, forKey: .logo)
    }
    
    // For compatibility
    var logoUrl: String? { logo }
}

// MARK: - Investment Product
struct InvestmentProduct: Codable, Identifiable, Sendable {
    let id: Int
    let title: String
    let slug: String
    let shortDescription: String?
    let featuredImage: String?
    let price: String
    let currency: String
    let minInvestment: String
    let minInvestmentFormatted: String
    let expectedReturns: String
    let riskLevel: String
    let riskLevelLabel: String
    let durationLabel: String
    let availabilityStatus: String
    let isFeatured: Bool
    let ratingAverage: String
    let ratingCount: Int
    let category: InvestmentCategorySimple?
    let partner: InvestmentPartnerSimple?
    let features: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, slug, currency, price, category, partner
        case shortDescription = "short_description"
        case featuredImage = "featured_image"
        case minInvestment = "min_investment"
        case minInvestmentFormatted = "min_investment_formatted"
        case expectedReturns = "expected_returns"
        case riskLevel = "risk_level"
        case riskLevelLabel = "risk_level_label"
        case durationLabel = "duration_label"
        case availabilityStatus = "availability_status"
        case isFeatured = "is_featured"
        case ratingAverage = "rating_average"
        case ratingCount = "rating_count"
        case features
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        slug = try container.decode(String.self, forKey: .slug)
        shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription)
        featuredImage = try container.decodeIfPresent(String.self, forKey: .featuredImage)
        price = try container.decode(String.self, forKey: .price)
        currency = try container.decode(String.self, forKey: .currency)
        minInvestment = try container.decode(String.self, forKey: .minInvestment)
        minInvestmentFormatted = try container.decode(String.self, forKey: .minInvestmentFormatted)
        expectedReturns = try container.decode(String.self, forKey: .expectedReturns)
        riskLevel = try container.decode(String.self, forKey: .riskLevel)
        riskLevelLabel = try container.decode(String.self, forKey: .riskLevelLabel)
        durationLabel = try container.decode(String.self, forKey: .durationLabel)
        availabilityStatus = try container.decode(String.self, forKey: .availabilityStatus)
        isFeatured = try container.decode(Bool.self, forKey: .isFeatured)
        ratingAverage = try container.decode(String.self, forKey: .ratingAverage)
        ratingCount = try container.decode(Int.self, forKey: .ratingCount)
        category = try container.decodeIfPresent(InvestmentCategorySimple.self, forKey: .category)
        partner = try container.decodeIfPresent(InvestmentPartnerSimple.self, forKey: .partner)
        features = try container.decodeIfPresent([String].self, forKey: .features)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(slug, forKey: .slug)
        try container.encodeIfPresent(shortDescription, forKey: .shortDescription)
        try container.encodeIfPresent(featuredImage, forKey: .featuredImage)
        try container.encode(price, forKey: .price)
        try container.encode(currency, forKey: .currency)
        try container.encode(minInvestment, forKey: .minInvestment)
        try container.encode(minInvestmentFormatted, forKey: .minInvestmentFormatted)
        try container.encode(expectedReturns, forKey: .expectedReturns)
        try container.encode(riskLevel, forKey: .riskLevel)
        try container.encode(riskLevelLabel, forKey: .riskLevelLabel)
        try container.encode(durationLabel, forKey: .durationLabel)
        try container.encode(availabilityStatus, forKey: .availabilityStatus)
        try container.encode(isFeatured, forKey: .isFeatured)
        try container.encode(ratingAverage, forKey: .ratingAverage)
        try container.encode(ratingCount, forKey: .ratingCount)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(partner, forKey: .partner)
        try container.encodeIfPresent(features, forKey: .features)
    }
    
    // Computed properties for compatibility
    var name: String { title }
    var description: String? { shortDescription }
    var imageUrl: String? { featuredImage }
    var minimumInvestment: String { minInvestmentFormatted }
    var expectedReturnMin: String { expectedReturns }
    var expectedReturnMax: String? { nil }
    var lockInPeriodMonths: Int? { nil }
    
    var riskLevelColor: String {
        switch riskLevel.lowercased() {
        case "very_low": return "success_green"
        case "low": return "success_green"
        case "medium": return "warning_yellow"
        case "high": return "error_red"
        case "very_high": return "error_red"
        default: return "text_secondary"
        }
    }
    
    var riskLevelText: String {
        riskLevelLabel
    }
}

// MARK: - Investment Product Simple
struct InvestmentProductSimple: Codable, Sendable {
    let id: Int
    let title: String
    let slug: String
    let featuredImage: String?
    let category: InvestmentCategorySimple?
    let partner: InvestmentPartnerSimple?
    let riskLevel: String?
    let riskLevelLabel: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, slug, category, partner
        case featuredImage = "featured_image"
        case riskLevel = "risk_level"
        case riskLevelLabel = "risk_level_label"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        slug = try container.decode(String.self, forKey: .slug)
        featuredImage = try container.decodeIfPresent(String.self, forKey: .featuredImage)
        category = try container.decodeIfPresent(InvestmentCategorySimple.self, forKey: .category)
        partner = try container.decodeIfPresent(InvestmentPartnerSimple.self, forKey: .partner)
        riskLevel = try container.decodeIfPresent(String.self, forKey: .riskLevel)
        riskLevelLabel = try container.decodeIfPresent(String.self, forKey: .riskLevelLabel)
    }
}

// MARK: - Purchase Investment Request
struct PurchaseInvestmentRequest: Codable, Sendable {
    let productId: Int
    let amount: Double
    let currency: String
    let payoutFrequency: String?
    let autoReinvest: Bool?
    
    enum CodingKeys: String, CodingKey {
        case amount, currency
        case productId = "product_id"
        case payoutFrequency = "payout_frequency"
        case autoReinvest = "auto_reinvest"
    }
}

// MARK: - Transaction Info (simplified for purchase response)
struct TransactionInfo: Codable, Sendable {
    let id: Int
    let reference: String
    let amount: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, reference, amount, status
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        reference = try container.decode(String.self, forKey: .reference)
        amount = try container.decode(String.self, forKey: .amount)
        status = try container.decode(String.self, forKey: .status)
    }
}

// MARK: - User Investment
struct UserInvestment: Codable, Identifiable, Sendable {
    let id: Int
    let userId: Int?
    let productId: Int?
    let product: InvestmentProductSimple?
    let investmentCode: String
    let amountInvested: String
    let amountInvestedFormatted: String
    let currency: String
    let status: String
    let purchaseDate: String
    let maturityDate: String?
    let currentValue: String
    let currentValueFormatted: String
    let returnsPercentage: Double
    let returnsEarned: String?
    let payoutFrequency: String?
    let autoReinvest: Bool?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, product, currency, status
        case userId = "user_id"
        case productId = "product_id"
        case investmentCode = "investment_code"
        case amountInvested = "amount_invested"
        case amountInvestedFormatted = "amount_invested_formatted"
        case purchaseDate = "purchase_date"
        case maturityDate = "maturity_date"
        case currentValue = "current_value"
        case currentValueFormatted = "current_value_formatted"
        case returnsPercentage = "returns_percentage"
        case returnsEarned = "returns_earned"
        case payoutFrequency = "payout_frequency"
        case autoReinvest = "auto_reinvest"
        case createdAt = "created_at"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        productId = try container.decodeIfPresent(Int.self, forKey: .productId)
        product = try container.decodeIfPresent(InvestmentProductSimple.self, forKey: .product)
        investmentCode = try container.decode(String.self, forKey: .investmentCode)
        amountInvested = try container.decode(String.self, forKey: .amountInvested)
        amountInvestedFormatted = try container.decode(String.self, forKey: .amountInvestedFormatted)
        currency = try container.decode(String.self, forKey: .currency)
        status = try container.decode(String.self, forKey: .status)
        purchaseDate = try container.decode(String.self, forKey: .purchaseDate)
        maturityDate = try container.decodeIfPresent(String.self, forKey: .maturityDate)
        currentValue = try container.decode(String.self, forKey: .currentValue)
        currentValueFormatted = try container.decode(String.self, forKey: .currentValueFormatted)
        returnsPercentage = try container.decode(Double.self, forKey: .returnsPercentage)
        returnsEarned = try container.decodeIfPresent(String.self, forKey: .returnsEarned)
        payoutFrequency = try container.decodeIfPresent(String.self, forKey: .payoutFrequency)
        autoReinvest = try container.decodeIfPresent(Bool.self, forKey: .autoReinvest)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }
    
    var statusColor: String {
        switch status.lowercased() {
        case "active": return "success_green"
        case "matured": return "primary_gold"
        case "withdrawn": return "text_secondary"
        case "pending": return "warning_yellow"
        default: return "text_secondary"
        }
    }
    
    var computedReturnsEarned: String {
        if let returns = returnsEarned {
            return returns
        }
        let invested = Double(amountInvested) ?? 0.0
        let current = Double(currentValue) ?? 0.0
        return String(format: "%.2f", current - invested)
    }
}

// MARK: - Purchase Investment Response
struct PurchaseInvestmentResponse: Codable, Sendable {
    let investment: UserInvestment
    let transaction: TransactionInfo
    
    enum CodingKeys: String, CodingKey {
        case investment, transaction
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        investment = try container.decode(UserInvestment.self, forKey: .investment)
        transaction = try container.decode(TransactionInfo.self, forKey: .transaction)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(investment, forKey: .investment)
        try container.encode(transaction, forKey: .transaction)
    }
}
