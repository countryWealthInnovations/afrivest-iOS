//
//  OnboardingView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Onboarding Pages
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    imageName: "onboarding_real_estate",
                    title: "Invest in Your Family's Future",
                    description: "Transform every remittance into a wealth-building opportunity in real estate and portfolio growth.",
                    currentPage: $currentPage,
                    totalPages: 3,
                    onSkip: { viewModel.skipOnboarding() },
                    onNext: { withAnimation { currentPage = 1 } }
                )
                .tag(0)
                
                OnboardingPageView(
                    imageName: "onboarding_insurance",
                    title: "Cross-Border Health Insurance",
                    description: "Secure your family's health with tailored insurance coverage for both home and abroad.",
                    currentPage: $currentPage,
                    totalPages: 3,
                    onSkip: { viewModel.skipOnboarding() },
                    onNext: { withAnimation { currentPage = 2 } }
                )
                .tag(1)
                
                OnboardingPageView(
                    imageName: "onboarding_gold",
                    title: "Gold Marketplace",
                    description: "Turn remittances into tangible assets that hedge against inflation and preserve long-term value.",
                    currentPage: $currentPage,
                    totalPages: 3,
                    onSkip: { viewModel.skipOnboarding() },
                    onNext: { viewModel.completeOnboarding() },
                    isLastPage: true
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
    }
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    @Binding var currentPage: Int
    let totalPages: Int
    let onSkip: () -> Void
    let onNext: () -> Void
    var isLastPage: Bool = false
    
    var body: some View {
        ZStack {
            // Hero Image
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            // Glassmorphism Gradient Overlay
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .glassmorphismOverlay, location: 0.5),
                    .init(color: .overlayDark, location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 10)
            .ignoresSafeArea()
            
            VStack {
                // Skip Button
                HStack {
                    Spacer()
                    if !isLastPage {
                        Button(action: onSkip) {
                            Text("Skip")
                                .font(AppFont.bodyRegular())
                                .foregroundColor(.primaryGold)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                        }
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, Spacing.screenHorizontal)
                
                Spacer()
                
                // Content
                VStack(spacing: Spacing.md) {
                    // Page Indicators
                    HStack(spacing: Spacing.sm) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.primaryGold : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, Spacing.md)
                    
                    // Title
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primaryGold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.screenHorizontal)
                    
                    // Description
                    Text(description)
                        .font(AppFont.bodyLarge())
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.screenHorizontal)
                    
                    // CTA Button
                    PrimaryButton(
                        title: isLastPage ? "Get Started" : "Next",
                        action: onNext,
                        isEnabled: true
                    )
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.top, Spacing.lg)
                }
                .padding(.bottom, Spacing.xxl)
            }
        }
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}