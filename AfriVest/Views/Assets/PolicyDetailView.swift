//
//  PolicyDetailView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 26/12/2025.
//

import SwiftUI

struct PolicyDetailView: View {
    let policy: InsurancePolicy
    @StateObject private var viewModel: PolicyDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(policy: InsurancePolicy) {
        self.policy = policy
        _viewModel = StateObject(wrappedValue: PolicyDetailViewModel(policy: policy))
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header Card
                    headerCard
                    
                    // Coverage Card
                    coverageCard
                    
                    // Claims Section
                    claimsSection
                    
                    // File Claim Button
                    if policy.status.lowercased() == "active" {
                        fileClaimButton
                    }
                }
                .padding(Spacing.screenHorizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Policy Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showFileClaimSheet) {
            FileClaimView(policy: policy) {
                viewModel.loadClaims()
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .onAppear {
            viewModel.loadClaims()
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(policy.policyNumber)
                        .font(AppFont.heading3())
                        .foregroundColor(Color.textPrimary)
                    
                    Text(policy.policyTypeText)
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Status Badge
                Text(policy.status.uppercased())
                    .font(AppFont.footnote())
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Divider()
                .background(Color.borderDefault)
            
            if let partner = policy.partner {
                Text("Provider: \(partner.name)")
                    .font(AppFont.bodySmall())
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
    
    // MARK: - Coverage Card
    private var coverageCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Coverage Details")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            HStack(spacing: Spacing.md) {
                coverageItem(title: "Coverage", value: policy.coverageAmount)
                coverageItem(title: "Premium", value: policy.premiumAmount)
            }
            
            Divider()
                .background(Color.borderDefault)
            
            HStack {
                Text("Start Date")
                    .font(AppFont.bodyRegular())
                    .foregroundColor(Color.textSecondary)
                
                Spacer()
                
                Text(formatDate(policy.startDate))
                    .font(AppFont.bodyRegular())
                    .foregroundColor(Color.textPrimary)
            }
            
            HStack {
                Text("End Date")
                    .font(AppFont.bodyRegular())
                    .foregroundColor(Color.textSecondary)
                
                Spacer()
                
                Text(formatDate(policy.endDate))
                    .font(AppFont.bodyRegular())
                    .foregroundColor(Color.textPrimary)
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
    
    private func coverageItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFont.bodySmall())
                .foregroundColor(Color.textSecondary)
            
            Text(value)
                .font(AppFont.bodyLarge())
                .foregroundColor(Color.primaryGold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Claims Section
    private var claimsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Claims History")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            if viewModel.claims.isEmpty {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(Color.textSecondary.opacity(0.5))
                    
                    Text("No claims filed")
                        .font(AppFont.bodyRegular())
                        .foregroundColor(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
            } else {
                ForEach(viewModel.claims) { claim in
                    ClaimCard(claim: claim)
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
    
    // MARK: - File Claim Button
    private var fileClaimButton: some View {
        Button(action: {
            viewModel.showFileClaimSheet = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                
                Text("File New Claim")
                    .font(AppFont.bodyLarge())
            }
            .foregroundColor(Color.buttonPrimaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.buttonPrimary)
            .cornerRadius(Spacing.radiusMedium)
        }
    }
    
    // MARK: - Helpers
    private var statusColor: Color {
        switch policy.status.lowercased() {
        case "active": return Color.successGreen
        case "expired": return Color.textSecondary
        case "cancelled": return Color.errorRed
        case "pending": return Color.warningYellow
        default: return Color.textSecondary
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Claim Card
struct ClaimCard: View {
    let claim: InsuranceClaim
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(claim.claimNumber)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.textPrimary)
                    
                    Text(claim.claimType.capitalized)
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                Text(claim.status.uppercased())
                    .font(AppFont.footnote())
                    .foregroundColor(claimStatusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(claimStatusColor.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Divider()
                .background(Color.borderDefault)
            
            HStack {
                Text("Claim Amount")
                    .font(AppFont.bodySmall())
                    .foregroundColor(Color.textSecondary)
                
                Spacer()
                
                Text(claim.amountFormatted)
                    .font(AppFont.bodyRegular())
                    .foregroundColor(Color.primaryGold)
            }
            
            HStack {
                Text("Filed")
                    .font(AppFont.bodySmall())
                    .foregroundColor(Color.textSecondary)
                
                Spacer()
                
                Text(formatDate(claim.createdAt))
                    .font(AppFont.bodyRegular())
                    .foregroundColor(Color.textSecondary)
            }
            
            if let description = claim.description {
                Text(description)
                    .font(AppFont.bodySmall())
                    .foregroundColor(Color.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(Spacing.md)
        .background(Color.backgroundDark2)
        .cornerRadius(Spacing.radiusMedium)
    }
    
    private var claimStatusColor: Color {
        switch claim.status.lowercased() {
        case "approved": return Color.successGreen
        case "rejected": return Color.errorRed
        case "pending": return Color.warningYellow
        case "processing": return Color.primaryGold
        default: return Color.textSecondary
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
