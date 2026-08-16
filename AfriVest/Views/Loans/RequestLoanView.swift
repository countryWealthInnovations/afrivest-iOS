//
//  RequestLoanView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import SwiftUI

struct RequestLoanView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = LoanViewModel()
    @State private var amount = ""
    @State private var selectedTerm: LoanTerm?
    @State private var purpose = ""
    
    private var currency: String { UserDefaultsManager.shared.defaultCurrency ?? "UGX" }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        amountField
                        termField
                        purposeField
                        estimateLabel
                        submitButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Request a Loan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(Color.primaryGold)
                }
            }
            .onAppear { viewModel.loadTerms() }
            .onChange(of: viewModel.terms) { list in
                if selectedTerm == nil { selectedTerm = list.first }
            }
            .onChange(of: viewModel.createdLoan) { loan in
                if loan != nil { dismiss() }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: { Text(viewModel.errorMessage ?? "") }
        }
    }
    
    private var amountField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Amount (\(currency))").foregroundColor(.gray)
            TextField("0", text: $amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    private var termField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Term").foregroundColor(.gray)
            Picker("Term", selection: $selectedTerm) {
                ForEach(viewModel.terms) { t in
                    Text(termLabel(t)).tag(Optional(t))
                }
            }
            .pickerStyle(.menu)
            .tint(Color.primaryGold)
        }
    }
    
    private var purposeField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Purpose (optional)").foregroundColor(.gray)
            TextField("", text: $purpose)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    private var estimateLabel: some View {
        Text(estimateText)
            .font(.footnote)
            .foregroundColor(.gray)
    }
    
    private var submitButton: some View {
        Button(action: submit) {
            Group {
                if viewModel.isLoading {
                    ProgressView().tint(.black)
                } else {
                    Text("Submit Request").bold()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.primaryGold)
        .foregroundColor(.black)
        .cornerRadius(10)
        .disabled(viewModel.isLoading)
    }
    
    private func termLabel(_ t: LoanTerm) -> String {
        let name = t.term.replacingOccurrences(of: "_", with: " ")
        return "\(name) (\(t.interest_rate)%)"
    }
    
    private var estimateText: String {
        guard let amt = Double(amount), amt > 0, let term = selectedTerm,
              let rate = Double(term.interest_rate) else {
            return "Enter an amount to see estimated interest"
        }
        let interest = amt * rate / 100
        let total = amt + interest
        return String(format: "Estimated interest: %.2f  •  Repay approx: %.2f\nA handling fee applies; exact breakdown shows after you submit.", interest, total)
    }
    
    private func submit() {
        guard let amt = Double(amount), amt > 0, let term = selectedTerm else { return }
        viewModel.requestLoan(amount: amt, term: term.term, currency: currency,
                              purpose: purpose.isEmpty ? nil : purpose)
    }
}
