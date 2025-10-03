//
//  CountryPickerView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 03/10/2025.
//

import SwiftUI

struct CountryPickerView: View {
    @Binding var selectedCountry: Country
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return Country.all
        }
        return Country.all.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.dialCode.contains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundDark1.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textSecondary)
                        
                        TextField("Search country", text: $searchText)
                            .font(AppFont.bodyRegular())
                            .foregroundColor(.textPrimary)
                            .autocapitalization(.none)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .frame(height: 44)
                    .background(Color.inputBackground)
                    .cornerRadius(Spacing.radiusMedium)
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.vertical, Spacing.md)
                    
                    // Country List
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredCountries) { country in
                                CountryRow(
                                    country: country,
                                    isSelected: country.dialCode == selectedCountry.dialCode
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedCountry = country
                                    dismiss()
                                }
                                
                                if country.id != filteredCountries.last?.id {
                                    Divider()
                                        .background(Color.borderDefault)
                                        .padding(.leading, 68)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGold)
                }
            }
        }
    }
}

struct CountryRow: View {
    let country: Country
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Flag
            Text(country.flag)
                .font(.system(size: 32))
                .frame(width: 44)
            
            // Name
            Text(country.name)
                .font(AppFont.bodyLarge())
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            // Dial Code
            Text(country.dialCode)
                .font(AppFont.bodyRegular())
                .foregroundColor(.textSecondary)
            
            // Checkmark
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.primaryGold)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.vertical, Spacing.sm)
        .background(isSelected ? Color.primaryGold.opacity(0.1) : Color.clear)
    }
}

// MARK: - Preview
struct CountryPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CountryPickerView(selectedCountry: .constant(Country.default))
    }
}
