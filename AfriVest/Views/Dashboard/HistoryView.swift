//
//  HistoryView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Text("Transaction History")
                        .font(AppFont.heading3())
                        .foregroundColor(Color.textPrimary)
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.vertical, Spacing.md)
                
                // Filter Chips
                filterChips
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.bottom, Spacing.md)
                
                // Transaction List
                if viewModel.filteredTransactions.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    transactionList
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadTransactions()
        }
        .overlay(
            Group {
                if viewModel.isLoading && viewModel.transactions.isEmpty {
                    LoadingOverlay()
                }
            }
        )
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedFilter == nil,
                    color: Color.primaryGold
                ) {
                    viewModel.filterTransactions(nil)
                }
                
                FilterChip(
                    title: "Success",
                    isSelected: viewModel.selectedFilter == "success",
                    color: Color.successGreen
                ) {
                    viewModel.filterTransactions("success")
                }
                
                FilterChip(
                    title: "Pending",
                    isSelected: viewModel.selectedFilter == "pending",
                    color: Color.warningYellow
                ) {
                    viewModel.filterTransactions("pending")
                }
                
                FilterChip(
                    title: "Failed",
                    isSelected: viewModel.selectedFilter == "failed",
                    color: Color.errorRed
                ) {
                    viewModel.filterTransactions("failed")
                }
            }
        }
    }
    
    // MARK: - Transaction List
    private var transactionList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(viewModel.filteredTransactions) { transaction in
                    NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                        TransactionListItem(transaction: transaction)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Load more when reaching the end
                    if transaction.id == viewModel.filteredTransactions.last?.id {
                        if !viewModel.isLastPage {
                            ProgressView()
                                .padding(.vertical, Spacing.md)
                                .onAppear {
                                    viewModel.loadMoreTransactions()
                                }
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, Spacing.lg)
        }
        .refreshable {
            await viewModel.refreshTransactions()
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(Color.textSecondary.opacity(0.5))
            
            Text("No Transactions")
                .font(AppFont.heading3())
                .foregroundColor(Color.textPrimary)
            
            Text("You don't have any transactions yet")
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.lg)
    }
}

// MARK: - Filter Chip Component
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.bodySmall())
                .foregroundColor(isSelected ? color : Color.textSecondary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color.opacity(0.2) : Color("3A3A3A"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: isSelected ? 1 : 0)
                )
        }
    }
}

// MARK: - Preview
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HistoryView()
        }
    }
}
