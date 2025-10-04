//
//  HistoryView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    Text("Transaction History")
                        .h1Style()
                        .padding(.top, Spacing.xl)
                    
                    Text("Your transaction history will appear here")
                        .bodyRegularStyle()
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
            }
        }
    }
}
