//
//  ProfileView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI
import MessageUI
import Alamofire

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showHelpSheet = false
    @State private var showLogoutConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showChangePassword = false
    @State private var showCurrencySettings = false
    @State private var showPhoneVerify = false
    @State private var showKYC = false
    @State private var showAllocation = false
    @State private var showAdvisorDashboard = false
    @State private var showNextOfKin = false
    @State private var borrowedTotal: Double = 0
    @State private var borrowedCurrency: String = ""
    @AppStorage("default_currency") private var storedCurrency: String = "Not set"
    @AppStorage("secondary_currency") private var storedSecondaryCurrency: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Profile Header
                    profileHeader
                    
                    // Summary (wallet / portfolio / loans)
                    summaryCard
                    
                    // Account Status
                    statusCard
                    
                    // Advisor section (advisors only)
                    if viewModel.user?.role == "advisor" {
                        advisorCard
                    }
                    
                    // Settings Sections
                    VStack(spacing: Spacing.md) {
                        // Account Section
                        accountSection
                        
                        // Security Section
                        securitySection
                        
                        // Support Section
                        supportSection
                        
                        // Danger Zone
                        dangerZone
                    }
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadProfile()
            loadBorrowed()
        }
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordView()
        }
        .sheet(isPresented: $showCurrencySettings) {
            CurrencySelectionView(isPresented: $showCurrencySettings)
        }
        .sheet(isPresented: $showAllocation) {
            AllocationSettingsView()
        }
        .sheet(isPresented: $showNextOfKin) {
            NextOfKinView()
        }
        .sheet(isPresented: $showAdvisorDashboard) {
            AdvisorDashboardView()
        }
        .fullScreenCover(isPresented: $showPhoneVerify, onDismiss: { viewModel.loadProfile() }) {
            PhoneOTPView(phone: viewModel.user?.phoneNumber ?? "")
        }
        .fullScreenCover(isPresented: $showKYC, onDismiss: { viewModel.loadProfile() }) {
            KycView()
        }
        .sheet(isPresented: $showHelpSheet) {
            HelpCenterSheet(
                onEmailTap: { openEmail() },
                onPhoneTap: { openPhone() }
            )
        }
        .alert("Logout", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                logout()
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: Spacing.md) {
            Text("Profile & Settings")
                .font(AppFont.heading2())
                .foregroundColor(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: Spacing.md) {
                // Avatar
                if let avatarUrl = viewModel.user?.avatarUrl,
                   !avatarUrl.isEmpty,
                   avatarUrl != "https://afrivest.co/images/default-avatar.png" {
                    AsyncImage(url: URL(string: avatarUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        initialsAvatar
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
                    initialsAvatar
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.user?.name ?? "Loading...")
                        .font(AppFont.heading3())
                        .foregroundColor(Color.textPrimary)
                    
                    Text(viewModel.user?.email ?? "")
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                    
                    if let phone = viewModel.user?.phoneNumber {
                        Text(phone)
                            .font(AppFont.bodySmall())
                            .foregroundColor(Color.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(Spacing.md)
            .background(Color.backgroundDark1)
            .cornerRadius(Spacing.radiusMedium)
        }
        .padding(.top, Spacing.md)
    }
    
    private var initialsAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.primaryGold.opacity(0.2))
                .frame(width: 60, height: 60)
            
            Text(getInitials())
                .font(AppFont.heading2())
                .foregroundColor(Color.primaryGold)
        }
    }
    
    private var phoneVerified: Bool {
        UserDefaultsManager.shared.bool(forKey: "phone_verified")
    }
    
    private func loadBorrowed() {
        Task {
            do {
                let my: MyLoansMini = try await APIClient.shared.request(
                    "/loans/my", method: .get, parameters: nil, requiresAuth: true)
                let userCurrency = UserDefaultsManager.shared.defaultCurrency ?? "UGX"
                let active = my.borrowed.filter { ["active", "funded", "overdue"].contains($0.status) }
                borrowedTotal = active.reduce(0) { sum, loan in
                    let rate = CurrencyConverter.getRate(from: loan.currency, to: userCurrency)
                    return sum + loan.outstanding * (rate > 0 ? rate : 1)
                }
                borrowedCurrency = userCurrency
            } catch {
                borrowedTotal = 0
            }
        }
    }
    
    private var summaryCard: some View {
        let currency = UserDefaultsManager.shared.defaultCurrency ?? "UGX"
        let wallet = viewModel.user?.wallets.first(where: { $0.currency == currency }) ?? viewModel.user?.wallets.first
        let portfolio = viewModel.user?.investmentSummary?.currentValue ?? 0
        return HStack {
            summaryCell(title: "Wallet", value: "\(wallet?.currency ?? currency) \(wallet?.balance ?? "0")", color: Color.primaryGold)
            summaryCell(title: "Portfolio", value: FeeCalculator.formatCurrency(portfolio), color: .green)
            summaryCell(title: "Loans", value: borrowedTotal > 0 ? "\(borrowedCurrency) \(FeeCalculator.formatCurrency(borrowedTotal))" : "None", color: Color.textPrimary)
        }
        .padding(Spacing.md)
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
    }
    
    private func summaryCell(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(AppFont.bodySmall()).foregroundColor(Color.textSecondary)
            Text(value).font(AppFont.bodyRegular()).foregroundColor(color).bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var advisorCard: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Advisor")
            SettingsRow(icon: "calendar.badge.clock", title: "Availability & Bookings", subtitle: "Manage your advisory schedule") {
                showAdvisorDashboard = true
            }
        }
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
    }
    
    // MARK: - Account Status
    private var statusCard: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Account Status")
            
            statusRow(label: "Email",
                      ok: viewModel.user?.emailVerified ?? false,
                      okText: "Verified", pendingText: "Not verified",
                      tappable: false) {}
            
            Divider().background(Color.borderDefault).padding(.leading, 44)
            
            statusRow(label: "Phone",
                      ok: phoneVerified,
                      okText: "Verified", pendingText: "Verify now",
                      tappable: !phoneVerified) {
                showPhoneVerify = true
            }
            
            Divider().background(Color.borderDefault).padding(.leading, 44)
            
            statusRow(label: "Identity (KYC)",
                      ok: viewModel.user?.kycVerified ?? false,
                      okText: "Verified", pendingText: "Verify now",
                      tappable: !(viewModel.user?.kycVerified ?? false)) {
                showKYC = true
            }
            
            Divider().background(Color.borderDefault).padding(.leading, 44)
            
            statusRow(label: "Account",
                      ok: (viewModel.user?.status ?? "") == "active",
                      okText: "Active",
                      pendingText: (viewModel.user?.status ?? "Pending").capitalized,
                      tappable: false) {}
        }
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
    }
    
    private func statusRow(label: String, ok: Bool, okText: String, pendingText: String,
                           tappable: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { if tappable { action() } }) {
            HStack(spacing: Spacing.md) {
                Image(systemName: ok ? "checkmark.seal.fill" : "exclamationmark.shield.fill")
                    .foregroundColor(ok ? .green : Color.primaryGold)
                    .font(.system(size: 18))
                
                Text(label)
                    .font(AppFont.bodyRegular())
                    .foregroundColor(Color.textPrimary)
                
                Spacer()
                
                Text(ok ? okText : pendingText)
                    .font(AppFont.bodySmall())
                    .foregroundColor(ok ? .green : Color.primaryGold)
                
                if tappable {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.textSecondary)
                        .font(.system(size: 12))
                }
            }
            .padding(Spacing.md)
        }
        .disabled(!tappable)
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Account")
            
            NavigationLink(destination: EditProfileView()) {
                settingsRowContent(
                    icon: "person.fill",
                    title: "Personal Information",
                    subtitle: "Name, Phone"
                )
            }
            
            Divider()
                .background(Color.borderDefault)
                .padding(.leading, 50)
            
            NavigationLink(destination: NotificationSettingsView()) {
                settingsRowContent(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Push, Email, SMS preferences"
                )
            }
            
            Divider()
                .background(Color.borderDefault)
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "dollarsign.circle.fill",
                title: "Currency",
                subtitle: storedSecondaryCurrency.isEmpty ? storedCurrency : "\(storedCurrency) · \(storedSecondaryCurrency)"
            ) {
                showCurrencySettings = true
            }
            
            Divider()
                .background(Color.borderDefault)
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "chart.pie.fill",
                title: "Deposit Allocation",
                subtitle: "Split each deposit across wallet, savings, investment"
            ) {
                showAllocation = true
            }
            
            Divider()
                .background(Color.borderDefault)
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "person.2.fill",
                title: "Next of Kin",
                subtitle: "Who to contact in an emergency"
            ) {
                showNextOfKin = true
            }
        }
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
    }
    
    private func settingsRowContent(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.primaryGold.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(Color.primaryGold)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.bodyRegular())
                    .foregroundColor(Color.textPrimary)
                
                Text(subtitle)
                    .font(AppFont.bodySmall())
                    .foregroundColor(Color.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.textSecondary)
                .font(.system(size: 14))
        }
        .padding(Spacing.md)
    }
    
    // MARK: - Security Section
    private var securitySection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Security")
            
            SettingsRow(
                icon: "lock.fill",
                title: "Change Password",
                subtitle: "Update your account password"
            ) {
                showChangePassword = true
            }
            
            Divider()
                .background(Color.borderDefault)
                .padding(.leading, 50)
            
            // Biometric Toggle
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGold.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: getBiometricIcon())
                        .foregroundColor(Color.primaryGold)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(getBiometricLabel())
                        .font(AppFont.bodyRegular())
                        .foregroundColor(Color.textPrimary)
                    
                    Text("Use biometrics for quick login")
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $viewModel.biometricEnabled)
                    .labelsHidden()
                    .tint(Color.primaryGold)
            }
            .padding(Spacing.md)
        }
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Support")
            
            SettingsRow(
                icon: "questionmark.circle.fill",
                title: "Help Center",
                subtitle: "FAQs and support articles"
            ) {
                showHelpSheet = true
            }
            
            Divider()
                .background(Color.borderDefault)
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "doc.text.fill",
                title: "Terms & Conditions",
                subtitle: "Legal agreements"
            ) {
                openURL("https://afrivest.co/terms")
            }
            
            Divider()
                .background(Color.borderDefault)
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "lock.shield.fill",
                title: "Privacy Policy",
                subtitle: "How we handle your data"
            ) {
                openURL("https://afrivest.co/policy")
            }
        }
        .background(Color.backgroundDark1)
        .cornerRadius(Spacing.radiusMedium)
    }
    
    // MARK: - Danger Zone
    private var dangerZone: some View {
        VStack(spacing: Spacing.md) {
            // Logout Button
            Button(action: {
                showLogoutConfirmation = true
            }) {
                HStack {
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 20))
                    
                    Text("Logout")
                        .font(AppFont.bodyLarge())
                }
                .foregroundColor(.errorRed)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.backgroundDark1)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .stroke(Color.errorRed, lineWidth: 1)
                )
                .cornerRadius(Spacing.radiusMedium)
            }
            
            // Delete Account Button
            Button(action: {
                showDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                    
                    Text("Delete Account")
                        .font(AppFont.bodyLarge())
                }
                .foregroundColor(.errorRed)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.backgroundDark1)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .stroke(Color.errorRed, lineWidth: 1)
                )
                .cornerRadius(Spacing.radiusMedium)
            }
            
            // App Version
            Text("Version 1.0.0")
                .font(AppFont.bodySmall())
                .foregroundColor(Color.textSecondary)
        }
    }
    
    // MARK: - Helpers
    private func getInitials() -> String {
        guard let name = viewModel.user?.name else { return "U" }
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }
    
    private func getBiometricIcon() -> String {
        return "faceid"
    }
    
    private func getBiometricLabel() -> String {
        return "Face ID / Touch ID"
    }
    
    // MARK: - Helper Methods
    private func openEmail() {
        let email = "hello@afrivest.co"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openPhone() {
        let phone = "+256700000000" // Replace with actual phone number
        if let url = URL(string: "tel:\(phone)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    private func logout() {
        Task {
            do {
                // Call logout API
                let _: EmptyDataResponse = try await APIClient.shared.request(
                    APIConstants.Endpoints.logout,
                    method: .post,
                    requiresAuth: true
                )
                
                await MainActor.run {
                    // Clear all stored data after successful API call
                    KeychainManager.shared.clearAll()
                    
                    // Reset to login screen
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = UIHostingController(rootView: LoginView())
                        window.makeKeyAndVisible()
                    }
                }
                
            } catch {
                await MainActor.run {
                    // Even if API call fails, still logout locally
                    KeychainManager.shared.clearAll()
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = UIHostingController(rootView: LoginView())
                        window.makeKeyAndVisible()
                    }
                }
            }
        }
    }
}

// MARK: - Loans summary decoder
struct MyLoansMini: Decodable, Sendable {
    struct Item: Decodable, Sendable {
        let outstanding: Double
        let status: String
        let currency: String
        enum CodingKeys: String, CodingKey { case outstanding, status, currency }
        nonisolated init(from d: Decoder) throws {
            let c = try d.container(keyedBy: CodingKeys.self)
            if let dd = try? c.decode(Double.self, forKey: .outstanding) { outstanding = dd }
            else if let s = try? c.decode(String.self, forKey: .outstanding), let dd = Double(s) { outstanding = dd }
            else { outstanding = 0 }
            status = (try? c.decode(String.self, forKey: .status)) ?? ""
            currency = (try? c.decode(String.self, forKey: .currency)) ?? ""
        }
    }
    let borrowed: [Item]
    enum CodingKeys: String, CodingKey { case borrowed }
    nonisolated init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        borrowed = (try? c.decode([Item].self, forKey: .borrowed)) ?? []
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(AppFont.bodySmall())
            .foregroundColor(Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.sm)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGold.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .foregroundColor(Color.primaryGold)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.bodyRegular())
                        .foregroundColor(Color.textPrimary)
                    
                    Text(subtitle)
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.textSecondary)
                    .font(.system(size: 14))
            }
            .padding(Spacing.md)
        }
    }
}

// MARK: - Help Center Sheet
struct HelpCenterSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onEmailTap: () -> Void
    let onPhoneTap: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.lg) {
                    // Header
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color.primaryGold)
                        
                        Text("How can we help?")
                            .font(AppFont.heading2())
                            .foregroundColor(Color.textPrimary)
                        
                        Text("Get in touch with our support team")
                            .font(AppFont.bodyRegular())
                            .foregroundColor(Color.textSecondary)
                    }
                    .padding(.top, Spacing.xl)
                    
                    // Contact Options
                    VStack(spacing: Spacing.md) {
                        // Email
                        Button(action: {
                            dismiss()
                            onEmailTap()
                        }) {
                            HStack(spacing: Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(Color.primaryGold.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(Color.primaryGold)
                                        .font(.system(size: 20))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Email Us")
                                        .font(AppFont.bodyLarge())
                                        .foregroundColor(Color.textPrimary)
                                    
                                    Text("hello@afrivest.co")
                                        .font(AppFont.bodySmall())
                                        .foregroundColor(Color.primaryGold)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.textSecondary)
                                    .font(.system(size: 14))
                            }
                            .padding(Spacing.md)
                            .background(Color.backgroundDark1)
                            .cornerRadius(Spacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                                    .stroke(Color.borderDefault, lineWidth: 1)
                            )
                        }
                        
                        // Phone
                        Button(action: {
                            dismiss()
                            onPhoneTap()
                        }) {
                            HStack(spacing: Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(Color.primaryGold.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(Color.primaryGold)
                                        .font(.system(size: 20))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Call Us")
                                        .font(AppFont.bodyLarge())
                                        .foregroundColor(Color.textPrimary)
                                    
                                    Text("+256 700 000 000")
                                        .font(AppFont.bodySmall())
                                        .foregroundColor(Color.primaryGold)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.textSecondary)
                                    .font(.system(size: 14))
                            }
                            .padding(Spacing.md)
                            .background(Color.backgroundDark1)
                            .cornerRadius(Spacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                                    .stroke(Color.borderDefault, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.textPrimary)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
