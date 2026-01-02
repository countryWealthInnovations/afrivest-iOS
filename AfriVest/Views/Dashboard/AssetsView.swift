//
//  AssetsView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI

struct AssetsView: View {
    @StateObject private var viewModel = AssetsViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Tab Selector
                tabSelector
                
                // Content
                TabView(selection: $viewModel.selectedTab) {
                    investmentsTab
                        .tag(0)
                    
                    policiesTab
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .onAppear {
            if viewModel.investments.isEmpty && viewModel.policies.isEmpty {
                viewModel.loadData()
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.investments.isEmpty && viewModel.policies.isEmpty {
                LoadingOverlay()
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("My Assets")
                .font(AppFont.heading1())
                .foregroundColor(Color.textPrimary)
            
            if !viewModel.investments.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Total Value")
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                    
                    Text("UGX \(formatAmount(viewModel.totalInvestmentValue))")
                        .font(AppFont.heading2())
                        .foregroundColor(Color.primaryGold)
                    
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                        Text("+UGX \(formatAmount(viewModel.totalReturns))")
                            .font(AppFont.bodySmall())
                    }
                    .foregroundColor(Color.successGreen)
                }
                .padding(Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.backgroundDark1)
                .cornerRadius(Spacing.radiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .stroke(Color.borderDefault, lineWidth: 1)
                )
            }
        }
        .padding(Spacing.screenHorizontal)
        .padding(.top, Spacing.md)
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "Investments (\(viewModel.investments.count))", index: 0)
            tabButton(title: "Insurance (\(viewModel.policies.count))", index: 1)
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.vertical, Spacing.md)
    }
    
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation {
                viewModel.selectedTab = index
            }
        }) {
            Text(title)
                .font(AppFont.bodyRegular())
                .foregroundColor(viewModel.selectedTab == index ? Color.primaryGold : Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background(
                    viewModel.selectedTab == index
                    ? Color.primaryGold.opacity(0.1)
                    : Color.clear
                )
                .cornerRadius(Spacing.radiusSmall)
        }
    }
    
    // MARK: - Investments Tab
    private var investmentsTab: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                if viewModel.investments.isEmpty {
                    emptyState(
                        icon: "chart.line.uptrend.xyaxis",
                        message: "No investments yet",
                        description: "Start investing to see your portfolio here"
                    )
                } else {
                    ForEach(viewModel.investments) { investment in
                        NavigationLink {
                            InvestmentDetailView(investment: investment)
                        } label: {
                            InvestmentCard(investment: investment)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, 90)
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
    
    // MARK: - Policies Tab
    private var policiesTab: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                if viewModel.policies.isEmpty {
                    emptyState(
                        icon: "shield.fill",
                        message: "No insurance policies",
                        description: "Purchase insurance to see your policies here"
                    )
                } else {
                    ForEach(viewModel.policies) { policy in
                        NavigationLink {
                            PolicyDetailView(policy: policy)
                        } label: {
                            PolicyCard(policy: policy)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, 90)
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
    
    // MARK: - Empty State
    private func emptyState(icon: String, message: String, description: String) -> some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(Color.textSecondary.opacity(0.5))
            
            Text(message)
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            Text(description)
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Helper
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}

// MARK: - Investment Card
struct InvestmentCard: View {
    let investment: UserInvestment
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(investment.product?.title ?? "Investment")
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.textPrimary)
                    
                    Text(investment.product?.partner?.name ?? "")
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Status Badge
                Text(investment.status.uppercased())
                    .font(AppFont.footnote())
                    .foregroundColor(statusColor(investment.statusColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(investment.statusColor).opacity(0.1))
                    .cornerRadius(4)
            }
            
            Divider()
                .background(Color.borderDefault)
            
            // Stats
            HStack(spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Value")
                        .font(AppFont.footnote())
                        .foregroundColor(Color.textSecondary)
                    
                    Text(investment.currentValue)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.primaryGold)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Returns")
                        .font(AppFont.footnote())
                        .foregroundColor(Color.textSecondary)
                    
                    Text("+\(investment.returnsEarned ?? "0")")
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.successGreen)
                }
            }
            
            // Purchase Date
            Text("Purchased: \(formatDate(investment.purchaseDate))")
                .font(AppFont.footnote())
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
    
    private func statusColor(_ colorName: String) -> Color {
        switch colorName {
        case "success_green": return Color.successGreen
        case "primary_gold": return Color.primaryGold
        case "warning_yellow": return Color.warningYellow
        case "error_red": return Color.errorRed
        default: return Color.textSecondary
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Policy Card
struct PolicyCard: View {
    let policy: InsurancePolicy
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(policy.policyNumber)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.textPrimary)
                    
                    Text(policy.policyTypeText)
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Status Badge
                Text(policy.status.uppercased())
                    .font(AppFont.footnote())
                    .foregroundColor(statusColor(policy.statusColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(policy.statusColor).opacity(0.1))
                    .cornerRadius(4)
            }
            
            Divider()
                .background(Color.borderDefault)
            
            // Stats
            HStack(spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Coverage")
                        .font(AppFont.footnote())
                        .foregroundColor(Color.textSecondary)
                    
                    Text(policy.coverageAmount)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.primaryGold)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Premium")
                        .font(AppFont.footnote())
                        .foregroundColor(Color.textSecondary)
                    
                    Text(policy.premiumAmount)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.textPrimary)
                }
            }
            
            // Provider
            if let partner = policy.partner {
                Text("Provider: \(partner.name)")
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
    
    private func statusColor(_ colorName: String) -> Color {
        switch colorName {
        case "success_green": return Color.successGreen
        case "primary_gold": return Color.primaryGold
        case "warning_yellow": return Color.warningYellow
        case "error_red": return Color.errorRed
        default: return Color.textSecondary
        }
    }
}
