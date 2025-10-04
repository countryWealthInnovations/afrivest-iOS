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
    @State private var autoSlideTimer: Timer?
    
    private let autoSlideDelay: TimeInterval = 5.0
    
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
                    onSkip: {
                        stopAutoSlide()
                        viewModel.skipOnboarding()
                    },
                    onNext: {
                        stopAutoSlide()
                        withAnimation { currentPage = 1 }
                        startAutoSlide()
                    }
                )
                .tag(0)
                
                OnboardingPageView(
                    imageName: "onboarding_insurance",
                    title: "Cross-Border Health Insurance",
                    description: "Secure your family's health with tailored insurance coverage for both home and abroad.",
                    currentPage: $currentPage,
                    totalPages: 3,
                    onSkip: {
                        stopAutoSlide()
                        viewModel.skipOnboarding()
                    },
                    onNext: {
                        stopAutoSlide()
                        withAnimation { currentPage = 2 }
                        startAutoSlide()
                    }
                )
                .tag(1)
                
                OnboardingPageView(
                    imageName: "onboarding_gold",
                    title: "Gold & Crypto Marketplace",
                    description: "Turn remittances into tangible assets that hedge against inflation and preserve long-term value.",
                    currentPage: $currentPage,
                    totalPages: 3,
                    onSkip: {
                        stopAutoSlide()
                        viewModel.skipOnboarding()
                    },
                    onNext: {
                        stopAutoSlide()
                        viewModel.completeOnboarding()
                    },
                    isLastPage: true
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .ignoresSafeArea(.all, edges: .all)
        .fullScreenCover(isPresented: $viewModel.shouldNavigateToRegister) {
            LoginView()
        }
        .onAppear {
            startAutoSlide()
        }
        .onDisappear {
            stopAutoSlide()
        }
        .onChange(of: currentPage) { _ in
            stopAutoSlide()
            if currentPage < 2 {
                startAutoSlide()
            }
        }
    }
    
    private func startAutoSlide() {
        stopAutoSlide()
        autoSlideTimer = Timer.scheduledTimer(withTimeInterval: autoSlideDelay, repeats: true) { _ in
            DispatchQueue.main.async {
                if currentPage < 2 {
                    currentPage += 1
                } else {
                    stopAutoSlide()
                    viewModel.completeOnboarding()
                }
            }
        }
    }
    
    private func stopAutoSlide() {
        autoSlideTimer?.invalidate()
        autoSlideTimer = nil
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
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Hero Image - Full Screen
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .all)
                
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
                .ignoresSafeArea(.all, edges: .all)
                
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
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(Spacing.radiusMedium)
                            }
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, Spacing.screenHorizontal)
                    
                    Spacer()
                    
                    // Content - Aligned to leading with horizontal padding
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        // Page Indicators - on the right
                        HStack {
                            Spacer()
                            HStack(spacing: Spacing.sm) {
                                ForEach(0..<totalPages, id: \.self) { index in
                                    Circle()
                                        .fill(currentPage == index ? Color.primaryGold : Color.white.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                        .padding(.bottom, Spacing.md)
                        
                        // Title - Left aligned
                        Text(title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primaryGold)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, Spacing.xs)
                        
                        // Description - Left aligned
                        Text(description)
                            .font(AppFont.bodyLarge())
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, Spacing.xs)
                        
                        // CTA Button - Full width
                        PrimaryButton(
                            title: isLastPage ? "Get Started" : "Next",
                            action: onNext,
                            isEnabled: true
                        )
                        .padding(.top, Spacing.lg)
                        .padding(.horizontal, Spacing.md)
                    }
                    .padding(.horizontal, 3)
                    .padding(.bottom, Spacing.lg)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .ignoresSafeArea(.all, edges: .all)
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
