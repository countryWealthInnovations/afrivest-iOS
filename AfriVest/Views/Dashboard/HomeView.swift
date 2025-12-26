//
//  HomeView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//  Location: AfriVest/Views/Dashboard/HomeView.swift
//

import SwiftUI
import Kingfisher

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showDepositView = false
    @State private var showWithdrawView = false
    @State private var showKYCBanner = true
    @State private var showKYCAlert = false
    @State private var showInvestmentProducts = false
    @State private var showInsuranceList = false
    @State private var showGoldMarketplace = false
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // KYC Banner
                if !isKYCVerified() {
                    KYCBannerView(isVisible: $showKYCBanner) {
                        showKYCAlert = true
                    }
                    .padding(.top, Spacing.md)
                }
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header Section
                        headerSection
                        
                        // Wallet Cards Section
                        walletCardsSection
                        
                        // Quick Actions
                        quickActionsSection
                        
                        // Hot Investment Opportunities
                        investmentOpportunitiesSection
                        
                        // Quick Send or Receive Money
                        quickSendReceiveSection
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, 90) // Space for FAB
                }
            }
        }
        .onAppear {
            viewModel.loadDashboard()
        }
        .refreshable {
            viewModel.refresh()
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
        )
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .alert("KYC Verification", isPresented: $showKYCAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("KYC verification screen coming soon!")
        }
        .fullScreenCover(isPresented: $showDepositView) {
            DepositView()
        }
        .fullScreenCover(isPresented: $showWithdrawView) {
            // WithdrawView() // To be implemented
            Text("Withdraw View - Coming Soon")
                .background(AppTheme.backgroundGradient.ignoresSafeArea())
        }
        .fullScreenCover(isPresented: $showInvestmentProducts) {
            InvestmentProductsView()
        }
        .fullScreenCover(isPresented: $showInsuranceList) {
            InsuranceListView()
        }
        .fullScreenCover(isPresented: $showGoldMarketplace) {
            GoldMarketplaceView()
        }
    }
    
    // MARK: - KYC Helper
    private func isKYCVerified() -> Bool {
        return UserDefaultsManager.shared.kycVerified
    }
    
    // MARK: - User Avatar
    private var userAvatar: some View {
        Group {
            if let avatarUrl = viewModel.user?.avatarUrl,
               !avatarUrl.isEmpty,
               avatarUrl != "https://afrivest.co/images/default-avatar.png",
               let url = URL(string: avatarUrl) {
                // Show custom avatar image
                KFImage(url)
                    .placeholder {
                        Circle()
                            .fill(Color.primaryGold.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay(
                                ProgressView()
                                    .tint(Color.primaryGold)
                            )
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.primaryGold.opacity(0.5), lineWidth: 1)
                    )
            } else {
                // Show initials for default avatar
                Circle()
                    .fill(Color.primaryGold.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(getUserInitials())
                            .font(AppFont.heading2())
                            .foregroundColor(Color.primaryGold)
                    )
            }
        }
    }
    
    // MARK: - Get User Initials
    private func getUserInitials() -> String {
        guard let name = viewModel.user?.name else { return "U" }
        
        let nameComponents = name.split(separator: " ")
        
        if nameComponents.count >= 2 {
            // Get first letter of first name and first letter of last name
            let firstInitial = nameComponents[0].prefix(1).uppercased()
            let lastInitial = nameComponents[1].prefix(1).uppercased()
            return "\(firstInitial)\(lastInitial)"
        } else if nameComponents.count == 1 {
            // Get first letter only
            return nameComponents[0].prefix(1).uppercased()
        }
        
        return "U"
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            // User Avatar and Name
            HStack(spacing: Spacing.md) {
                userAvatar
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.user?.name ?? "User")
                        .font(AppFont.heading3())
                        .foregroundColor(Color.textPrimary)
                    
                    Text(viewModel.greeting)
                        .font(AppFont.bodyRegular())
                        .foregroundColor(Color.textSecondary)
                }
            }
            
            Spacer()
            
            // Circular Icons
            HStack(spacing: Spacing.md) {
                // Bookmark Icon
                Button(action: {
                    print("📌 Bookmark tapped")
                }) {
                    Circle()
                        .stroke(Color.textSecondary.opacity(0.3), lineWidth: 1)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "bookmark")
                                .font(.system(size: 18))
                                .foregroundColor(Color.textSecondary)
                        )
                }
                
                // Notification Icon
                Button(action: {
                    print("🔔 Notification tapped")
                }) {
                    Circle()
                        .stroke(Color.textSecondary.opacity(0.3), lineWidth: 1)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "bell")
                                .font(.system(size: 18))
                                .foregroundColor(Color.textSecondary)
                        )
                }
            }
        }
    }
    
    // MARK: - Wallet Cards Section
    private var walletCardsSection: some View {
        VStack(spacing: Spacing.md) {
            // UGX Wallet Card (Deposit only)
            HStack(spacing: Spacing.md) {
                if let depositWallet = viewModel.depositWallet {
                    WalletCard(
                        wallet: depositWallet,
                        isAmountHidden: viewModel.isAmountHidden,
                        walletType: .deposit,
                        onToggleVisibility: {
                            viewModel.toggleAmountVisibility()
                        },
                        onAction: {
                            showDepositView = true
                        }
                    )
                }
                
                // Interest Wallet - Empty/Placeholder
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 24))
                            .foregroundColor(Color.primaryGold.opacity(0.5))
                        
                        Spacer()
                    }
                    
                    Text("Interest Wallet")
                        .font(AppFont.bodyRegular())
                        .foregroundColor(Color.textSecondary)
                    
                    Spacer()
                    
                    Text("Coming Soon")
                        .font(AppFont.heading3())
                        .foregroundColor(Color.textSecondary.opacity(0.5))
                        .padding(.vertical, Spacing.xs)
                    
                    Button(action: {
                        // Placeholder action
                    }) {
                        HStack(spacing: Spacing.xs) {
                            Text("Start Earning")
                                .font(AppFont.bodySmall())
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.textSecondary.opacity(0.3))
                        .foregroundColor(Color.textSecondary)
                        .cornerRadius(Spacing.radiusMedium)
                    }
                    .disabled(true)
                }
                .padding(Spacing.md)
                .frame(height: 180)
                .background(Color.backgroundDark1.opacity(0.5))
                .cornerRadius(Spacing.radiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .stroke(Color.borderDefault.opacity(0.5), lineWidth: 1)
                )
            }
            
            // Expand/Collapse Other Currencies Button
            if !viewModel.otherCurrencyWallets.isEmpty {
                Button(action: {
                    viewModel.toggleOtherCurrencies()
                }) {
                    HStack {
                        Text(viewModel.isOtherCurrenciesExpanded ? "Hide Other Currencies" : "Show Other Currencies (\(viewModel.otherCurrencyWallets.count))")
                            .font(AppFont.bodyRegular())
                            .foregroundColor(Color.primaryGold)
                        
                        Image(systemName: viewModel.isOtherCurrenciesExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(Color.primaryGold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.backgroundDark1)
                    .cornerRadius(Spacing.radiusMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                            .stroke(Color.borderDefault, lineWidth: 1)
                    )
                }
            }
            
            // Other Currency Wallets (Expanded)
            if viewModel.isOtherCurrenciesExpanded {
                ForEach(Array(stride(from: 0, to: viewModel.otherCurrencyWallets.count, by: 2)), id: \.self) { index in
                    HStack(spacing: Spacing.md) {
                        otherCurrencyCard(wallet: viewModel.otherCurrencyWallets[index])
                        
                        if index + 1 < viewModel.otherCurrencyWallets.count {
                            otherCurrencyCard(wallet: viewModel.otherCurrencyWallets[index + 1])
                        } else {
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Other Currency Card
    private func otherCurrencyCard(wallet: Wallet) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Currency Icon
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.primaryGold)
                
                Spacer()
            }
            
            // Currency Name
            Text("\(wallet.currency) Wallet")
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
            
            Spacer()
            
            // Balance
            Text(viewModel.formatBalance(wallet.balance, currency: wallet.currency))
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            // View Details Button
            Button(action: {
                // TODO: Navigate to wallet detail
            }) {
                HStack(spacing: Spacing.xs) {
                    Text("View Details")
                        .font(AppFont.button())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color.backgroundDark1)
                .cornerRadius(Spacing.radiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .stroke(Color.textSecondary.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(Spacing.md)
        .frame(height: 200)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Quick Actions")
                .font(AppFont.bodyLarge())
                .foregroundColor(Color.textPrimary)
            
            HStack(spacing: Spacing.md) {
                quickActionButton(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Invest"
                ) {
                    showInvestmentProducts = true
                }
                
                quickActionButton(
                    icon: "staroflife.shield",
                    title: "Insurance"
                ) {
                    showInsuranceList = true
                }
                
                quickActionButton(
                    icon: "bag",
                    title: "Marketplace"
                ) {
                    showGoldMarketplace = true
                }
                
                quickActionButton(
                    icon: "bitcoinsign",
                    title: "Crypto"
                ) {
                    // Disabled for now
                }
                .opacity(0.5)
                .disabled(true)
            }
        }
    }
    
    // MARK: - Quick Action Button
    private func quickActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(Color.primaryGold)
                    .frame(height: 40)
                
                Text(title)
                    .font(AppFont.footnote())
                    .foregroundColor(Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.backgroundDark1)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(Color.borderDefault, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Investment Opportunities Section
    private var investmentOpportunitiesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Hot Investment Opportunities")
                .font(AppFont.bodyLarge())
                .foregroundColor(Color.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(viewModel.featuredInvestments) { product in
                        NavigationLink {
                            ProductDetailView(product: product)
                        } label: {
                            investmentCard(product: product)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // MARK: - Investment Card
    private func investmentCard(product: InvestmentProduct) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Top Section: Logo and Company Info
            HStack(alignment: .top, spacing: Spacing.sm) {
                // Logo
                Circle()
                    .fill(Color.primaryGold.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.primaryGold)
                    )
                
                // Company and Type
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.partner?.name ?? product.category?.name ?? "")
                        .font(AppFont.bodyRegular())
                        .foregroundColor(Color.textPrimary)
                        .lineLimit(2)

                    Text(product.category?.name ?? "")
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
            }
            
            Spacer()
                .frame(height: Spacing.sm)
            
            // Middle Section: Rate and Maturity
            HStack(alignment: .top) {
                // Rate
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.expectedReturns == "0.00" ? "No Returns" : "\(product.expectedReturns)% p.a")
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.primaryGold)
                    
                    Text("Interest Rate")
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Maturity
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.durationLabel)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(Color.textPrimary)
                    
                    Text("Maturity")
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
            }
            
            Divider()
                .background(Color.textSecondary.opacity(0.3))
            
            // Bottom Section: Minimum Investment
            VStack(alignment: .leading, spacing: 2) {
                Text(product.minInvestmentFormatted)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(Color.primaryGold)
                
                Text("Minimum Investment")
                    .font(AppFont.bodySmall())
                    .foregroundColor(Color.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.md)
        .frame(width: 240, height: 180)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .stroke(Color.borderDefault, lineWidth: 1)
        )
    }
    
    // MARK: - Quick Send or Receive Section
    private var quickSendReceiveSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Quick Send or Receive Money")
                .font(AppFont.bodyLarge())
                .foregroundColor(Color.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    // Show only 4 contacts initially
                    ForEach(mockContacts.prefix(4), id: \.id) { contact in
                        contactAvatar(contact: contact)
                    }
                    
                    // Show more if scrolling
                    ForEach(mockContacts.dropFirst(4), id: \.id) { contact in
                        contactAvatar(contact: contact)
                    }
                }
            }
        }
    }
    
    // MARK: - Contact Avatar
    private func contactAvatar(contact: Contact) -> some View {
        Button(action: {
            // TODO: Navigate to transfer with pre-filled recipient
        }) {
            VStack(spacing: Spacing.sm) {
                Circle()
                    .fill(contact.color.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(contact.color, lineWidth: 2)
                    )
                    .overlay(
                        Text(contact.initials)
                            .font(AppFont.bodyLarge())
                            .foregroundColor(contact.color)
                    )
                
                Text(contact.name)
                    .font(AppFont.bodySmall())
                    .foregroundColor(Color.textPrimary)
            }
            .padding(.top, Spacing.sm)
        }
    }
    
    // MARK: - Mock Data
    private let mockContacts = [
        Contact(id: 1, name: "Jo N", initials: "JN", color: Color.blue),
        Contact(id: 2, name: "Eric", initials: "E", color: Color.orange),
        Contact(id: 3, name: "John", initials: "J", color: Color.green),
        Contact(id: 4, name: "Doe", initials: "D", color: Color.pink),
        Contact(id: 5, name: "Kim", initials: "K", color: Color.red),
        Contact(id: 6, name: "Stella", initials: "S", color: Color.purple)
    ]
}

// MARK: - Contact Model
struct Contact: Identifiable {
    let id: Int
    let name: String
    let initials: String
    let color: Color
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
