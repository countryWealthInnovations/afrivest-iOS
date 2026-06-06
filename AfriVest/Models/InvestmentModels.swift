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
    let id: Int?
    let name: String
    let slug: String
    let icon: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, icon
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
    }
}

// MARK: - Simplified Partner (from API product listing)
struct InvestmentPartnerSimple: Codable, Sendable {
    let id: Int?
    let name: String
    let logo: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, logo
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
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
    let description: String?
    let featuredImage: String?
    let price: String
    let currency: String
    let minInvestment: String
    let minInvestmentFormatted: String
    let maxInvestment: String?
    let expectedReturns: String
    let riskLevel: String
    let riskLevelLabel: String?
    let durationLabel: String
    let durationMonths: Int?
    let maturityDate: String?
    let availabilityStatus: String
    let totalUnits: Int?
    let unitsAvailable: Int?
    let isFeatured: Bool
    let ratingAverage: String
    let ratingCount: Int
    let requiresKyc: Bool?
    let termsConditions: String?
    let category: InvestmentCategorySimple?
    let partner: InvestmentPartnerSimple?
    let features: [String]?
    let documents: [InvestmentDocument]?
    let reviews: [InvestmentReview]?
    let similarProducts: [InvestmentProduct]?
    let statistics: InvestmentStatistics?
    
    enum CodingKeys: String, CodingKey {
        case id, title, slug, currency, price, category, partner, features, documents, reviews
        case similarProducts = "similar_products"
        case statistics
        case shortDescription = "short_description"
        case description
        case featuredImage = "featured_image"
        case minInvestment = "min_investment"
        case minInvestmentFormatted = "min_investment_formatted"
        case maxInvestment = "max_investment"
        case expectedReturns = "expected_returns"
        case riskLevel = "risk_level"
        case riskLevelLabel = "risk_level_label"
        case durationLabel = "duration_label"
        case durationMonths = "duration_months"
        case maturityDate = "maturity_date"
        case availabilityStatus = "availability_status"
        case totalUnits = "total_units"
        case unitsAvailable = "units_available"
        case isFeatured = "is_featured"
        case ratingAverage = "rating_average"
        case ratingCount = "rating_count"
        case requiresKyc = "requires_kyc"
        case termsConditions = "terms_conditions"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        slug = try container.decode(String.self, forKey: .slug)
        shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        featuredImage = try container.decodeIfPresent(String.self, forKey: .featuredImage)
        price = try container.decode(String.self, forKey: .price)
        currency = try container.decode(String.self, forKey: .currency)
        minInvestment = try container.decode(String.self, forKey: .minInvestment)
        minInvestmentFormatted = (try? container.decode(String.self, forKey: .minInvestmentFormatted)) ?? minInvestment
        maxInvestment = try container.decodeIfPresent(String.self, forKey: .maxInvestment)
        expectedReturns = try container.decode(String.self, forKey: .expectedReturns)
        riskLevel = try container.decode(String.self, forKey: .riskLevel)
        riskLevelLabel = try container.decodeIfPresent(String.self, forKey: .riskLevelLabel)
        durationLabel = (try? container.decode(String.self, forKey: .durationLabel)) ?? ""
        if let s = try? container.decodeIfPresent(String.self, forKey: .durationMonths) {
            durationMonths = Int(s)
        } else {
            durationMonths = try? container.decodeIfPresent(Int.self, forKey: .durationMonths)
        }
        maturityDate = try container.decodeIfPresent(String.self, forKey: .maturityDate)
        availabilityStatus = (try? container.decode(String.self, forKey: .availabilityStatus)) ?? "available"
        // API returns these as String or Int
        if let s = try? container.decodeIfPresent(String.self, forKey: .totalUnits) {
            totalUnits = Int(s)
        } else {
            totalUnits = try? container.decodeIfPresent(Int.self, forKey: .totalUnits)
        }
        if let s = try? container.decodeIfPresent(String.self, forKey: .unitsAvailable) {
            unitsAvailable = Int(s)
        } else {
            unitsAvailable = try? container.decodeIfPresent(Int.self, forKey: .unitsAvailable)
        }
        isFeatured = (try? container.decode(Bool.self, forKey: .isFeatured)) ?? false
        ratingAverage = (try? container.decode(String.self, forKey: .ratingAverage)) ?? "0.0"
        ratingCount = (try? container.decode(Int.self, forKey: .ratingCount)) ?? 0
        requiresKyc = try container.decodeIfPresent(Bool.self, forKey: .requiresKyc)
        termsConditions = try container.decodeIfPresent(String.self, forKey: .termsConditions)
        category = try container.decodeIfPresent(InvestmentCategorySimple.self, forKey: .category)
        partner = try container.decodeIfPresent(InvestmentPartnerSimple.self, forKey: .partner)
        features = try container.decodeIfPresent([String].self, forKey: .features)
        documents = try container.decodeIfPresent([InvestmentDocument].self, forKey: .documents)
        reviews = try container.decodeIfPresent([InvestmentReview].self, forKey: .reviews)
        similarProducts = try container.decodeIfPresent([InvestmentProduct].self, forKey: .similarProducts)
        statistics = try container.decodeIfPresent(InvestmentStatistics.self, forKey: .statistics)
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
        riskLevelLabel ?? riskLevel.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

// MARK: - Investment Statistics
struct InvestmentStatistics: Decodable, Sendable {
    let totalInvested: Double?
    let investorsCount: Int?
    let unitsSold: String?
    let unitsAvailable: String?
    let views: Int?
    
    enum CodingKeys: String, CodingKey {
        case totalInvested = "total_invested"
        case investorsCount = "investors_count"
        case unitsSold = "units_sold"
        case unitsAvailable = "units_available"
        case views
        case rating // ignored but must be present to not fail
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let d = try? container.decodeIfPresent(Double.self, forKey: .totalInvested) {
            totalInvested = d
        } else if let i = try? container.decodeIfPresent(Int.self, forKey: .totalInvested) {
            totalInvested = Double(i)
        } else {
            totalInvested = nil
        }
        investorsCount = try container.decodeIfPresent(Int.self, forKey: .investorsCount)
        unitsSold = try container.decodeIfPresent(String.self, forKey: .unitsSold)
        unitsAvailable = try container.decodeIfPresent(String.self, forKey: .unitsAvailable)
        views = try container.decodeIfPresent(Int.self, forKey: .views)
        // rating nested object is ignored — no property needed, just don't fail
    }
}

// MARK: - Investment Document
struct InvestmentDocument: Codable, Identifiable, Sendable {
    let id: Int
    let title: String
    let type: String?
    let typeLabel: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, type, url
        case typeLabel = "type_label"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        typeLabel = try container.decodeIfPresent(String.self, forKey: .typeLabel)
        url = try container.decodeIfPresent(String.self, forKey: .url)
    }
}

// MARK: - Investment Review
struct InvestmentReview: Codable, Identifiable, Sendable {
    let id: Int
    let rating: Int
    let title: String?
    let review: String?
    let userName: String?
    let isVerifiedPurchase: Bool
    let helpfulCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, rating, title, review
        case userName = "user_name"
        case isVerifiedPurchase = "is_verified_purchase"
        case helpfulCount = "helpful_count"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        rating = try container.decode(Int.self, forKey: .rating)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        review = try container.decodeIfPresent(String.self, forKey: .review)
        userName = try container.decodeIfPresent(String.self, forKey: .userName)
        isVerifiedPurchase = (try? container.decode(Bool.self, forKey: .isVerifiedPurchase)) ?? false
        helpfulCount = (try? container.decode(Int.self, forKey: .helpfulCount)) ?? 0
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
