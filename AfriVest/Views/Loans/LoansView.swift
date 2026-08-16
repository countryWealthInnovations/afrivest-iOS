//
//  LoansView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 29/07/2026.
//


import SwiftUI

struct LoansView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = LoanViewModel()
    @State private var tab = 0
    @State private var showRequest = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("", selection: $tab) {
                        Text("Borrowed").tag(0)
                        Text("Lent").tag(1)
                        Text("Browse").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if viewModel.isLoading {
                        ProgressView().tint(Color.primaryGold).padding()
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(currentList) { loan in
                                NavigationLink(destination: LoanDetailView(uuid: loan.uuid, role: role(loan))) {
                                    LoanRow(loan: loan)
                                }
                                .buttonStyle(.plain)
                            }
                            if currentList.isEmpty && !viewModel.isLoading {
                                Text(emptyText)
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Loans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }.foregroundColor(Color.primaryGold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showRequest = true } label: {
                        Label("Request", systemImage: "plus")
                    }.foregroundColor(Color.primaryGold)
                }
            }
            .onAppear {
                viewModel.loadMyLoans()
            }
            .onChange(of: tab) { newTab in
                if newTab == 2 { viewModel.loadAvailable() } else { viewModel.loadMyLoans() }
            }
            .sheet(isPresented: $showRequest, onDismiss: { viewModel.loadMyLoans() }) {
                RequestLoanView()
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var currentList: [Loan] {
        switch tab {
        case 1: return viewModel.lent
        case 2: return viewModel.available
        default: return viewModel.borrowed
        }
    }
    
    private var emptyText: String {
        switch tab {
        case 1: return "You have not lent yet"
        case 2: return "No open requests to fund"
        default: return "You have not borrowed yet"
        }
    }
    
    private func role(_ loan: Loan) -> String {
        switch tab {
        case 2: return "available"
        case 1: return "lender"
        default: return "borrower"
        }
    }
}

struct LoanRow: View {
    let loan: Loan
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(loan.reference)
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                Spacer()
                Text(loan.status.capitalized)
                    .font(.caption).bold()
                    .foregroundColor(statusColor)
            }
            Text("\(loan.currency) \(loan.principal ?? "0")")
                .font(.title3).bold()
                .foregroundColor(Color.primaryGold)
            let party = loan.borrower?.name ?? loan.lender?.name
            Text([loan.term?.replacingOccurrences(of: "_", with: " "),
                  party.map { "with \($0)" },
                  loan.due_date.map { "due \($0.prefix(10))" }]
                .compactMap { $0 }.joined(separator: "  •  "))
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.18))
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch loan.status {
        case "active", "funded": return Color(red: 0.06, green: 0.72, blue: 0.51)
        case "repaid": return Color.primaryGold
        case "defaulted": return .red
        default: return .gray
        }
    }
}
