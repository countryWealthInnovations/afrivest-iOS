//
//  HomeView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var showKYCBanner = true
    @State private var showKYCAlert = false
    
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
                        Text("Home Dashboard")
                            .h1Style()
                            .padding(.top, Spacing.xl)
                        
                        Text("Content coming soon...")
                            .bodyRegularStyle()
                        
                        Spacer()
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                }
            }
        }
        .alert("KYC Verification", isPresented: $showKYCAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("KYC verification screen coming soon!")
        }
    }
    
    private func isKYCVerified() -> Bool {
        return UserDefaultsManager.shared.kycVerified
    }
}
