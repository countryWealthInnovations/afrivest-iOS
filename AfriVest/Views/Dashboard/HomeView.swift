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
    @State private var showCurrencySetup = false
    @State private var showDepositView = false
    @State private var showKYCBanner = true
    @State private var showKYC = false
    @State private var showInvestmentProducts = false
    @State private var showInsuranceList = false
    @State private var showGoldMarketplace = false
    @State private var isBalanceHidden = false
    @State private var isInvestmentHidden = false
    @State private var showSendMoney = false
    @State private var showLoans = false
    @State private var showMyQr = false
    @State private var preselectedContact: AppContact?
    @State private var showAdvisors = false
    
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // KYC Banner — hidden if admin toggled it off
                if !isKYCVerified() {
                    KYCBannerView(isVisible: $showKYCBanner) {
                        showKYC = true
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
                        
                        // Send to Contacts
                        contactsSection
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, 90)
                }
            }
        }
        .onAppear {
            viewModel.loadDashboard()
            viewModel.loadContactsIfAuthorized()
            // Show currency setup if not configured
            let hasCurrency = UserDefaultsManager.shared.object(forKey: "default_currency") != nil
            if !hasCurrency {
                showCurrencySetup = true
            }
        }
        .sheet(isPresented: $showCurrencySetup) {
            CurrencySelectionView(isPresented: $showCurrencySetup)
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
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .fullScreenCover(isPresented: $showKYC, onDismiss: { viewModel.loadDashboard() }) {
            KycView()
        }
        .fullScreenCover(isPresented: $showDepositView) {
            DepositView()
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
        .fullScreenCover(isPresented: $showSendMoney, onDismiss: { preselectedContact = nil }) {
            SendMoneyView(preselectedContact: preselectedContact)
        }
        .fullScreenCover(isPresented: $showLoans) {
            LoansView()
        }
        .sheet(isPresented: $showMyQr) {
            MyQrView()
        }
        .fullScreenCover(isPresented: $showAdvisors) {
            AdvisorsView()
        }
        .overlay(alignment: .bottomTrailing) {
            // Advisors see their dashboard, not the browse-advisors button
            if !isAdvisor() {
                Button(action: { showAdvisors = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                        Text("Advisors").font(AppFont.button())
                    }
                    .foregroundColor(Color.backgroundDark1)
                    .padding(.horizontal, Spacing.md).padding(.vertical, 12)
                    .background(Color.primaryGold)
                    .clipShape(Capsule())
                    .shadow(radius: 4)
                }
                .padding(.trailing, Spacing.screenHorizontal)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - KYC Helper
    private func isKYCVerified() -> Bool {
        return UserDefaultsManager.shared.kycVerified
    }
    
    // MARK: - Role Helper
    private func isAdvisor() -> Bool {
        return viewModel.user?.role == "advisor"
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
                    showMyQr = true
                }) {
                    Circle()
                        .stroke(Color.textSecondary.opacity(0.3), lineWidth: 1)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "qrcode")
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
            // Unified Wallet Card
            unifiedWalletCard
        }
    }
    
    // MARK: - Unified Wallet Card
    private var unifiedWalletCard: some View {
        VStack(spacing: 0) {
            // Top Section: Balance (Dark Background)
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Title with Eye Toggle
                HStack(spacing: 10) {
                    Text("My Balance")
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                    
                    Button(action: {
                        isBalanceHidden.toggle()
                    }) {
                        Image(systemName: isBalanceHidden ? "eye.slash" : "eye")
                            .font(.system(size: 15))
                            .foregroundColor(Color.textSecondary)
                    }
                    
                    Spacer()
                }
                
                // Balance Amount
                if let depositWallet = viewModel.depositWallet {
                    Text(isBalanceHidden ? "****" : viewModel.formatBalance(depositWallet.balance, currency: depositWallet.currency))
                        .font(AppFont.heading2())
                        .foregroundColor(Color.textPrimary)
                }
                
                // Action Buttons
                HStack(spacing: 8) {
                    Button(action: {
                        showDepositView = true
                    }) {
                        Text("Add Money")
                            .font(AppFont.button())
                            .foregroundColor(Color.backgroundDark1)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.primaryGold)
                            .cornerRadius(8)
                    }
                    
                    NavigationLink {
                        WithdrawView()
                    } label: {
                        Text("Withdraw")
                            .font(AppFont.button())
                            .foregroundColor(Color.primaryGold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primaryGold, lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(Spacing.md)
            .background(Color.backgroundDark1)
            
            // Bottom Section: Investment (Gold Background)
            if viewModel.hasInvestments, let summary = viewModel.investmentSummary {
                HStack {
                    // Left: Investment Amount
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack(spacing: 10) {
                            Text("My Investments")
                                .font(AppFont.bodySmall())
                                .foregroundColor(Color.backgroundDark1)
                            
                            Button(action: {
                                isInvestmentHidden.toggle()
                            }) {
                                Image(systemName: isInvestmentHidden ? "eye.slash" : "eye")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.backgroundDark1)
                            }
                            
                            Spacer()
                        }
                        
                        Text(isInvestmentHidden ? "****" : viewModel.formatInvestmentValue(summary.currentValue))
                            .font(AppFont.heading3())
                            .foregroundColor(Color.backgroundDark1)
                    }
                    
                    Spacer()
                    
                    // Right: Returns
                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        Text("My Average Returns")
                            .font(AppFont.bodySmall())
                            .foregroundColor(Color.backgroundDark1)
                        
                        HStack(spacing: 8) {
                            Text(isInvestmentHidden ? "**%" : "\(String(format: "%.2f", summary.interestPercentage))%")
                                .font(AppFont.heading3())
                                .foregroundColor(Color.backgroundDark1)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 24))
                                .foregroundColor(Color.backgroundDark1)
                        }
                    }
                }
                .padding(Spacing.md)
                .background(Color.primaryGold)
            }
        }
        .cornerRadius(Spacing.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .stroke(Color.primaryGold, lineWidth: 2)
        )
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
                    icon: "banknote",
                    title: "Loans"
                ) {
                    showLoans = true
                }
                
                quickActionButton(
                    icon: "staroflife.shield",
                    title: "Insurance"
                ) {
                    showInsuranceList = true
                }
                
                quickActionButton(
                    icon: "paperplane.fill",
                    title: "Send Money"
                ) {
                    showSendMoney = true
                }
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
                Text(convertedMinInvestment(product))
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
    
    // MARK: - Send to Contacts Section
    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Send to Contacts")
                .font(AppFont.bodyLarge())
                .foregroundColor(Color.textPrimary)
            
            if viewModel.contactsPermissionDenied {
                Button(action: { viewModel.requestContactsPermission() }) {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text("Find friends on AfriVest")
                            .font(AppFont.button())
                    }
                    .foregroundColor(Color.primaryGold)
                    .padding(.vertical, 10)
                    .padding(.horizontal, Spacing.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primaryGold, lineWidth: 1)
                    )
                }
            } else if !viewModel.matchedContacts.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(viewModel.matchedContacts, id: \.id) { contact in
                            contactAvatar(contact: contact)
                        }
                    }
                }
            }
        }
    }
    
    private func contactColor(_ name: String) -> Color {
        let palette: [Color] = [.blue, .orange, .green, .pink, .red, .purple]
        return palette[abs(name.hashValue) % palette.count]
    }
    
    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 { return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased() }
        return String(name.prefix(1)).uppercased()
    }
    
    // MARK: - Contact Avatar
    private func contactAvatar(contact: AppContact) -> some View {
        let color = contactColor(contact.name)
        return Button(action: {
            preselectedContact = contact
            showSendMoney = true
        }) {
            VStack(spacing: Spacing.sm) {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(Circle().stroke(color, lineWidth: 2))
                    .overlay(
                        Text(initials(contact.name))
                            .font(AppFont.bodyLarge())
                            .foregroundColor(color)
                    )
                Text(contact.name)
                    .font(AppFont.bodySmall())
                    .foregroundColor(Color.textPrimary)
                    .lineLimit(1)
            }
            .padding(.top, Spacing.sm)
        }
    }
}

private func convertedMinInvestment(_ product: InvestmentProduct) -> String {
    let userCurrency = UserDefaultsManager.shared.defaultCurrency ?? "UGX"
    let raw = Double(product.minInvestment) ?? 0
    let productCurrency = product.currency
    
    let amount: Double
    let displayCurrency: String
    
    if userCurrency != productCurrency, raw > 0 {
        let rate = CurrencyConverter.getRate(from: productCurrency, to: userCurrency)
        amount = raw * rate
        displayCurrency = userCurrency
    } else {
        amount = raw
        displayCurrency = productCurrency
    }
    
    // Use more decimals for small amounts
    let formatted: String
    if amount < 10 {
        formatted = String(format: "%.2f", amount)
    } else {
        formatted = FeeCalculator.formatCurrency(amount)
    }
    
    return "\(displayCurrency) \(formatted)"
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
