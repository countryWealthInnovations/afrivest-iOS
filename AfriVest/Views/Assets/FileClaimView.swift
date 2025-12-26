//
//  FileClaimView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 26/12/2025.
//

import SwiftUI
import Combine

struct FileClaimView: View {
    let policy: InsurancePolicy
    let onSuccess: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FileClaimViewModel
    
    init(policy: InsurancePolicy, onSuccess: @escaping () -> Void) {
        self.policy = policy
        self.onSuccess = onSuccess
        _viewModel = StateObject(wrappedValue: FileClaimViewModel(policy: policy))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Claim Type
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Claim Type")
                                .font(AppFont.bodySmall())
                                .foregroundColor(Color.textSecondary)
                            
                            Menu {
                                ForEach(viewModel.claimTypes, id: \.self) { type in
                                    Button(type) {
                                        viewModel.claimType = type
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.claimType.isEmpty ? "Select claim type" : viewModel.claimType)
                                        .foregroundColor(viewModel.claimType.isEmpty ? Color.textSecondary : Color.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(Color.textSecondary)
                                }
                                .padding(Spacing.md)
                                .background(Color.inputBackground)
                                .cornerRadius(Spacing.radiusMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                                        .stroke(Color.borderDefault, lineWidth: 1)
                                )
                            }
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Claim Amount")
                                .font(AppFont.bodySmall())
                                .foregroundColor(Color.textSecondary)
                            
                            TextField("Enter amount", text: $viewModel.amount)
                                .keyboardType(.decimalPad)
                                .font(AppFont.bodyRegular())
                                .foregroundColor(Color.textPrimary)
                                .padding(Spacing.md)
                                .background(Color.inputBackground)
                                .cornerRadius(Spacing.radiusMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                                        .stroke(Color.borderDefault, lineWidth: 1)
                                )
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Description")
                                .font(AppFont.bodySmall())
                                .foregroundColor(Color.textSecondary)
                            
                            TextEditor(text: $viewModel.description)
                                .font(AppFont.bodyRegular())
                                .foregroundColor(Color.textPrimary)
                                .frame(height: 120)
                                .padding(Spacing.sm)
                                .background(Color.inputBackground)
                                .cornerRadius(Spacing.radiusMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                                        .stroke(Color.borderDefault, lineWidth: 1)
                                )
                        }
                        
                        // Incident Date
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Incident Date")
                                .font(AppFont.bodySmall())
                                .foregroundColor(Color.textSecondary)
                            
                            DatePicker("", selection: $viewModel.incidentDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        
                        // Submit Button
                        Button(action: {
                            viewModel.fileClaim {
                                onSuccess()
                                dismiss()
                            }
                        }) {
                            Text("Submit Claim")
                                .font(AppFont.bodyLarge())
                                .foregroundColor(Color.buttonPrimaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(viewModel.isValid ? Color.buttonPrimary : Color.buttonDisabled)
                                .cornerRadius(Spacing.radiusMedium)
                        }
                        .disabled(!viewModel.isValid || viewModel.isLoading)
                    }
                    .padding(Spacing.screenHorizontal)
                }
            }
            .navigationTitle("File Claim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    onSuccess()
                    dismiss()
                }
            } message: {
                Text("Your claim has been filed successfully!")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

@MainActor
class FileClaimViewModel: ObservableObject {
    @Published var claimType = ""
    @Published var amount = ""
    @Published var description = ""
    @Published var incidentDate = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccess = false
    
    let policy: InsurancePolicy
    let claimTypes = ["Medical", "Accident", "Property Damage", "Other"]
    private let insuranceService = InsuranceService.shared
    
    init(policy: InsurancePolicy) {
        self.policy = policy
    }
    
    var isValid: Bool {
        !claimType.isEmpty && !amount.isEmpty && !description.isEmpty && Double(amount) != nil
    }
    
    func fileClaim(onSuccess: @escaping () -> Void) {
        guard isValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await insuranceService.fileClaim(
                    policyId: policy.id,
                    claimType: claimType,
                    amount: amount,
                    description: description,
                    incidentDate: formatDate(incidentDate)
                )
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
