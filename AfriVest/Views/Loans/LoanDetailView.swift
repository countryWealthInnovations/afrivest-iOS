//
//  LoanDetailView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import SwiftUI

struct LoanDetailView: View {
    let uuid: String
    let role: String
    @StateObject private var viewModel = LoanViewModel()
    @State private var repayAmount = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if let loan = viewModel.detail {
                        HStack {
                            Text(loan.reference).font(.title3).bold().foregroundColor(.white)
                            Spacer()
                            Text(loan.status.capitalized).bold().foregroundColor(Color.primaryGold)
                        }

                        breakdown(loan)

                        Text("Repayments").bold().foregroundColor(.white)
                        if let reps = loan.repayments, !reps.isEmpty {
                            ForEach(reps) { r in
                                Text("\(loan.currency) \(r.amount ?? "0")  •  \(r.source ?? "")  •  \(r.paid_at?.prefix(10) ?? "")")
                                    .font(.caption).foregroundColor(Color(white: 0.85))
                            }
                        } else {
                            Text("No repayments yet").font(.caption).foregroundColor(.gray)
                        }

                        if canRepay(loan) {
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Repay amount", text: $repayAmount)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                Button("Make Repayment") {
                                    if let amt = Double(repayAmount), amt > 0 {
                                        viewModel.repay(uuid: uuid, amount: amt)
                                        repayAmount = ""
                                    }
                                }
                                .frame(maxWidth: .infinity).padding()
                                .background(Color(red: 0.06, green: 0.72, blue: 0.51))
                                .foregroundColor(.white).cornerRadius(10)
                            }
                            .padding(.top, 8)
                        }

                        if canFund(loan) {
                            Button("Fund This Loan") {
                                viewModel.fund(uuid: uuid)
                            }
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.primaryGold)
                            .foregroundColor(.black).cornerRadius(10)
                            .padding(.top, 8)
                        }
                    } else if viewModel.isLoading {
                        ProgressView().tint(Color.primaryGold)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Loan")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadDetail(uuid: uuid) }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
    }

    private func breakdown(_ loan: Loan) -> some View {
        VStack(spacing: 8) {
            row("Principal", "\(loan.currency) \(loan.principal ?? "0")")
            row("Term", loan.term?.replacingOccurrences(of: "_", with: " ") ?? "-")
            row("Interest rate", "\(loan.interest_rate ?? "0")%")
            row("Interest", "\(loan.currency) \(loan.interest_amount ?? "0")")
            row("Handling fee", "\(loan.currency) \(loan.handling_fee ?? "0")")
            row("Total repayment", "\(loan.currency) \(loan.total_repayment ?? "0")")
            if let o = loan.outstanding { row("Outstanding", String(format: "\(loan.currency) %.2f", o)) }
            if let d = loan.due_date { row("Due", String(d.prefix(10))) }
            if let p = loan.purpose { row("Purpose", p) }
        }
        .padding()
        .background(Color(white: 0.18))
        .cornerRadius(12)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.gray)
            Spacer()
            Text(value).foregroundColor(.white).multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private func canRepay(_ loan: Loan) -> Bool {
        let outstanding = loan.outstanding ?? (loan.totalValue - (loan.amount_repaid ?? 0))
        return role == "borrower" && ["active", "funded", "defaulted"].contains(loan.status) && outstanding > 0
    }

    private func canFund(_ loan: Loan) -> Bool {
        role == "available" && loan.status == "requested"
    }
}
