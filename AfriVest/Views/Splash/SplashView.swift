import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()
    
    var body: some View {
        ZStack {
            // Gradient Background
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            // Pattern Layer
            Image("financial_pattern")
                .resizable(resizingMode: .tile)
                .opacity(0.1)
                .ignoresSafeArea()
            
            // Glassmorphism Blur
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .glassmorphismOverlay, location: 0.7),
                    .init(color: .overlayDark, location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 15)
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: Spacing.lg) {
                Spacer()
                
                // Money Bag Illustration
                Image("money_bag")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .scaleEffect(viewModel.isAnimating ? 1.0 : 0.8)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.6),
                        value: viewModel.isAnimating
                    )
                
                // App Name
                Text("AfriVest")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primaryGold)
                    .opacity(viewModel.isAnimating ? 1.0 : 0.0)
                    .animation(
                        .easeIn(duration: 0.5).delay(0.3),
                        value: viewModel.isAnimating
                    )
                
                Spacer()
                
                // Footer
                Text("© AfriVest")
                    .font(AppFont.bodySmall())
                    .foregroundColor(.primaryGold)
                    .padding(.bottom, Spacing.xl)
                    .opacity(viewModel.isAnimating ? 1.0 : 0.0)
                    .animation(
                        .easeIn(duration: 0.5).delay(0.5),
                        value: viewModel.isAnimating
                    )
            }
        }
        .onAppear {
            viewModel.startAnimation()
            viewModel.checkAuthStatus()
        }
    }
}

// MARK: - Preview
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}