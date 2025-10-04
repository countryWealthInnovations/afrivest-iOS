//
//  DashboardView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI

struct DashboardView: View {
    @State private var selectedTab = 0
    @State private var isFABExpanded = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                AssetsView()
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("Assets")
                    }
                    .tag(1)
                
                HistoryView()
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("History")
                    }
                    .tag(2)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(3)
            }
            .accentColor(.primaryGold)
            .onAppear {
                setupTabBarAppearance()
            }
            
            // Floating Action Button
            if selectedTab == 0 {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        FloatingActionButton(isExpanded: $isFABExpanded)
                            .padding(.trailing, Spacing.md)
                            .padding(.bottom, 90)
                    }
                }
                .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Glassmorphism background
        appearance.backgroundColor = UIColor(Color.backgroundDark1.opacity(0.95))
        
        // Selected state - bright gold
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primaryGold)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.primaryGold),
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ]
        
        // Normal state - dark gray for better contrast
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textDisabled)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.textDisabled),
            .font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ]
        
        // Apply appearance globally
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
