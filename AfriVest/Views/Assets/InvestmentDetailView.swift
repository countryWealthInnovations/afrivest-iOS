//
//  InvestmentDetailView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 26/12/2025.
//

import SwiftUI

struct InvestmentDetailView: View {
    let investment: UserInvestment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header Card
                    headerCard
                    
                    // Performance Card
                    performanceCard
                    
                    // Maturity Tracking
                    maturityCard
                    
                    // Returns Calculator
                    returnsCalculator
                    
                    // Product Details
                    productDetails
                }
                .padding(Spacing.screenHorizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Investment Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(investment.product?.name ?? "Investment")
                        .font(AppFont.heading3())
                        .foregroundColor(Color.textPrimary)
                    
                    Text(investment.product?.partner?.name ?? "")
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Status Badge
                Text(investment.status.uppercased())
                    .font(AppFont.footnote())
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Divider()
                .background(Color.borderDefault)
            
            Text(investment.investmentCode)
                .font(AppFont.bodySmall())
                .foregroundColor(Color.textSecondary)
        }
        .padding(Spacing.md)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .stroke(Color.borderDefault, lineWidth: 1)
        )
    }
    
    // MARK: - Performance Card
    private var performanceCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Performance")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            HStack(spacing: Spacing.md) {
                performanceItem(
                    title: "Invested",
                    value: investment.amountInvestedFormatted,
                    color: Color.textPrimary
                )
                
                performanceItem(
                    title: "Current Value",
                    value: investment.currentValueFormatted,
                    color: Color.primaryGold
                )
            }
            
            HStack(spacing: Spacing.md) {
                performanceItem(
                    title: "Returns",
                    value: calculateReturns(),
                    color: Color.successGreen
                )
                
                performanceItem(
                    title: "Returns %",
                    value: String(format: "%.2f%%", investment.returnsPercentage),
                    color: Color.successGreen
                )
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
    
    private func performanceItem(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFont.bodySmall())
                .foregroundColor(Color.textSecondary)
            
            Text(value)
                .font(AppFont.bodyLarge())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Maturity Card
    private var maturityCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Maturity Tracking")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                maturityRow(label: "Purchase Date", value: formatDate(investment.purchaseDate))
                
                if let maturityDate = investment.maturityDate {
                    maturityRow(label: "Maturity Date", value: formatDate(maturityDate))
                    
                    Divider()
                        .background(Color.borderDefault)
                    
                    // Progress Bar
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Text("Progress")
                                .font(AppFont.bodySmall())
                                .foregroundColor(Color.textSecondary)
                            
                            Spacer()
                            
                            Text(progressText)
                                .font(AppFont.bodySmall())
                                .foregroundColor(Color.primaryGold)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.borderDefault)
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.primaryGold)
                                    .frame(width: geometry.size.width * progressPercentage, height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                    
                    Divider()
                        .background(Color.borderDefault)
                    
                    maturityRow(label: "Days Remaining", value: daysRemaining)
                }
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
    
    private func maturityRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textPrimary)
        }
    }
    
    // MARK: - Returns Calculator
    private var returnsCalculator: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Projected Returns")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                projectedRow(label: "At 3 Months", value: calculateProjected(months: 3))
                projectedRow(label: "At 6 Months", value: calculateProjected(months: 6))
                projectedRow(label: "At 12 Months", value: calculateProjected(months: 12))
                projectedRow(label: "At Maturity", value: calculateProjected(months: monthsToMaturity))
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
    
    private func projectedRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.successGreen)
        }
    }
    
    // MARK: - Product Details
    private var productDetails: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Product Details")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            if let product = investment.product {
                VStack(spacing: Spacing.sm) {
                    detailRow(label: "Category", value: product.category?.name ?? "N/A")
                    detailRow(label: "Risk Level", value: product.riskLevelLabel)
                    detailRow(label: "Expected Returns", value: calculateActualReturns())
                }
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
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textPrimary)
        }
    }
    
    // MARK: - Helpers
    private var statusColor: Color {
        switch investment.status.lowercased() {
        case "active": return Color.successGreen
        case "matured": return Color.primaryGold
        case "pending": return Color.warningYellow
        default: return Color.textSecondary
        }
    }
    
    private func calculateReturns() -> String {
        let invested = Double(investment.amountInvested) ?? 0
        let current = Double(investment.currentValue) ?? 0
        let returns = current - invested
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return "+\(formatter.string(from: NSNumber(value: returns)) ?? "0") \(investment.currency)"
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private var progressPercentage: CGFloat {
        guard let maturityDate = investment.maturityDate else { return 0 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let purchase = formatter.date(from: investment.purchaseDate),
              let maturity = formatter.date(from: maturityDate) else { return 0 }
        
        let now = Date()
        let totalDays = maturity.timeIntervalSince(purchase)
        let elapsedDays = now.timeIntervalSince(purchase)
        
        guard totalDays > 0 else { return 0 }
        return min(max(CGFloat(elapsedDays / totalDays), 0), 1)
    }
    
    private var progressText: String {
        return String(format: "%.1f%%", progressPercentage * 100)
    }
    
    private var daysRemaining: String {
        guard let maturityDate = investment.maturityDate else { return "N/A" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let maturity = formatter.date(from: maturityDate) else { return "N/A" }
        
        let days = Calendar.current.dateComponents([.day], from: Date(), to: maturity).day ?? 0
        return days > 0 ? "\(days) days" : "Matured"
    }
    
    private var monthsToMaturity: Int {
        guard let maturityDate = investment.maturityDate else { return 12 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let purchase = formatter.date(from: investment.purchaseDate),
              let maturity = formatter.date(from: maturityDate) else { return 12 }
        
        return Calendar.current.dateComponents([.month], from: purchase, to: maturity).month ?? 12
    }
    
    private func calculateProjected(months: Int) -> String {
        let invested = Double(investment.amountInvested) ?? 0
        // Use returns_percentage from UserInvestment instead of product
        let annualRate = investment.returnsPercentage
        
        if annualRate == 0.0 {
            return "N/A"
        }
        
        let monthlyRate = annualRate / 12 / 100
        let projected = invested * monthlyRate * Double(months)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return "+\(formatter.string(from: NSNumber(value: projected)) ?? "0") \(investment.currency)"
    }
    
    private func calculateActualReturns() -> String {
        let invested = Double(investment.amountInvested) ?? 0.0
        let current = Double(investment.currentValue) ?? 0.0
        
        if invested > 0 && current > invested {
            let actualReturn = ((current - invested) / invested) * 100
            return String(format: "%.2f%% actual", actualReturn)
        }
        return "N/A"
    }
}
