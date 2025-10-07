//
//  RegisterView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.fieldSpacing) {
                    // Header
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Create Your Account!")
                            .h1Style()
                        
                        Text("Join the platform that turns remittances into wealth.")
                            .bodyRegularStyle()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Spacing.xl)
                    .padding(.bottom, Spacing.lg)
                    
                    // Full Name
                    AppTextField(
                        label: "Full Names",
                        placeholder: "Enter your full name",
                        text: $viewModel.fullName,
                        state: viewModel.nameState,
                        errorMessage: viewModel.nameError,
                        showCheckmark: viewModel.nameState == .success
                    )
                    
                    // Email
                    AppTextField(
                        label: "Email",
                        placeholder: "Enter your email",
                        text: $viewModel.email,
                        state: viewModel.emailState,
                        errorMessage: viewModel.emailError,
                        showCheckmark: viewModel.emailState == .success,
                        keyboardType: .emailAddress
                    )
                    
                    // Phone Number with Country Code
                    PhoneFieldWithCountryCode(
                        label: "Phone Number",
                        selectedCountry: $viewModel.selectedCountry,
                        phoneNumber: $viewModel.phoneNumber,
                        state: viewModel.phoneState,
                        errorMessage: viewModel.phoneError,
                        showCheckmark: viewModel.phoneState == .success
                    )
                    
                    // Password
                    AppTextField(
                        label: "Password",
                        placeholder: "Enter your password",
                        text: $viewModel.password,
                        isSecure: true,
                        state: viewModel.passwordState,
                        errorMessage: viewModel.passwordError
                    )
                    // Password Requirements
                    Text("At least 8 characters, 1 uppercase, number or special character")
                        .font(AppFont.bodySmall())
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Password Strength Indicator
                    if !viewModel.password.isEmpty {
                        PasswordStrengthView(strength: viewModel.passwordStrength)
                    }
                    
                    // Confirm Password
                    AppTextField(
                        label: "Confirm Password",
                        placeholder: "Confirm your password",
                        text: $viewModel.confirmPassword,
                        isSecure: true,
                        state: viewModel.confirmPasswordState,
                        errorMessage: viewModel.confirmPasswordError,
                        showCheckmark: viewModel.confirmPasswordState == .success
                    )
                    
                    // Terms & Conditions
                    HStack(spacing: Spacing.sm) {
                        Button(action: { viewModel.termsAccepted.toggle() }) {
                            Image(systemName: viewModel.termsAccepted ? "checkmark.square.fill" : "square")
                                .foregroundColor(viewModel.termsAccepted ? .primaryGold : .borderDefault)
                                .font(.system(size: 20))
                        }
                        
                        (Text("I agree to the ")
                            .foregroundColor(.textSecondary) +
                        Text("Terms & Conditions")
                            .foregroundColor(.primaryGold)
                            .underline() +
                        Text(" and ")
                            .foregroundColor(.textSecondary) +
                        Text("Privacy Policy")
                            .foregroundColor(.primaryGold)
                            .underline())
                            .font(AppFont.bodySmall())
                            .onTapGesture {
                                if let url = URL(string: "https://afrivest.countrywealth.ug/terms") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Register Button
                    PrimaryButton(
                        title: "Create Account",
                        action: { viewModel.register() },
                        isLoading: viewModel.isLoading,
                        isEnabled: viewModel.isFormValid
                    )
                    .padding(.top, Spacing.md)
                    
                    // Login Link
                    HStack {
                        Text("I already have an account?")
                            .font(AppFont.bodyRegular())
                            .foregroundColor(.textSecondary)
                        
                        NavigationLink(destination: LoginView()) {
                            Text("Login now")
                                .font(AppFont.bodyRegular())
                                .foregroundColor(.primaryGold)
                        }
                    }
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.xl)
                }
                .padding(.horizontal, Spacing.screenHorizontal)
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                LoadingOverlay()
            }
            
            // FIXED: Hidden NavigationLink that triggers when shouldNavigateToOTP is true
            NavigationLink(
                destination: OTPView(email: viewModel.email, from: "register"),
                isActive: $viewModel.shouldNavigateToOTP
            ) {
                EmptyView()
            }
            .hidden()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Phone Field with Country Code
struct PhoneFieldWithCountryCode: View {
    let label: String
    @Binding var selectedCountry: Country
    @Binding var phoneNumber: String
    var state: TextFieldState = .normal
    var errorMessage: String? = nil
    var showCheckmark: Bool = false
    
    @State private var showCountryPicker = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Label
            Text(label)
                .font(AppFont.label())
                .foregroundColor(.textPrimary)
            
            // Input Field
            HStack(spacing: 0) {
                // Country Code Button
                Button(action: { showCountryPicker = true }) {
                    HStack(spacing: 4) {
                        Text(selectedCountry.flag)
                            .font(.system(size: 20))
                        Text(selectedCountry.dialCode)
                            .font(AppFont.bodyLarge())
                            .foregroundColor(.textPrimary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.leading, Spacing.md)
                    .padding(.trailing, Spacing.sm)
                }
                
                Divider()
                    .frame(height: 24)
                    .background(Color.borderDefault)
                
                TextField("700000001", text: $phoneNumber)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(.textPrimary)
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isFocused)
                    .padding(.leading, Spacing.sm)
                    .onChange(of: phoneNumber) { newValue in
                        phoneNumber = newValue.filter { $0.isNumber }
                        if phoneNumber.count > 15 {
                            phoneNumber = String(phoneNumber.prefix(15))
                        }
                    }
                
                if showCheckmark && state == .success {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.successGreen)
                        .frame(width: Spacing.iconSize, height: Spacing.iconSize)
                        .padding(.trailing, Spacing.md)
                }
            }
            .frame(height: Spacing.inputHeight)
            .background(Color.inputBackground)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(borderColor, lineWidth: Spacing.borderMedium)
            )
            
            // Helper/Error Text
            if let errorMessage = errorMessage, state == .error {
                Text(errorMessage)
                    .font(AppFont.bodySmall())
                    .foregroundColor(.errorRed)
            } else {
                Text("Enter your phone number without country code")
                    .font(AppFont.bodySmall())
                    .foregroundColor(.textSecondary)
            }
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .normal:
            return isFocused ? .borderActive : .borderDefault
        case .active:
            return .borderActive
        case .success:
            return .successGreen
        case .error:
            return .errorRed
        }
    }
}

// MARK: - Password Strength View
struct PasswordStrengthView: View {
    let strength: PasswordStrength
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Strength Bar
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Rectangle()
                        .fill(barColor(for: index))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            
            // Strength Text
            Text(strengthText)
                .font(AppFont.bodySmall())
                .foregroundColor(strengthColor)
        }
    }
    
    private func barColor(for index: Int) -> Color {
        switch strength {
        case .weak:
            return index == 0 ? .errorRed : Color.borderDefault
        case .medium:
            return index < 2 ? .warningYellow : Color.borderDefault
        case .strong:
            return .successGreen
        }
    }
    
    private var strengthText: String {
        switch strength {
        case .weak: return "Weak password"
        case .medium: return "Medium password"
        case .strong: return "Strong password"
        }
    }
    
    private var strengthColor: Color {
        switch strength {
        case .weak: return .errorRed
        case .medium: return .warningYellow
        case .strong: return .successGreen
        }
    }
}

// MARK: - Preview
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
