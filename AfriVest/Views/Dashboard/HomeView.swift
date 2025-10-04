//
//  HomeView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
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
}
