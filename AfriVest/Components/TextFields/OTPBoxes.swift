//
//  OTPBoxes.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI

struct OTPBoxes: View {
    @Binding var otpCode: String
    let boxCount: Int = 6
    @FocusState private var focusedBox: Int?
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<boxCount, id: \.self) { index in
                OTPBox(
                    digit: getDigit(at: index),
                    isFocused: focusedBox == index
                )
                .onTapGesture {
                    focusedBox = index
                }
            }
        }
        .background(
            TextField("", text: $otpCode)
                .keyboardType(.numberPad)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .focused($focusedBox, equals: 0)
                .onChange(of: otpCode) { newValue in
                    // Limit to 6 digits
                    if newValue.count > boxCount {
                        otpCode = String(newValue.prefix(boxCount))
                    }
                    // Only allow numbers
                    otpCode = newValue.filter { $0.isNumber }
                }
        )
        .onAppear {
            focusedBox = 0
        }
    }
    
    private func getDigit(at index: Int) -> String {
        guard index < otpCode.count else { return "" }
        return String(Array(otpCode)[index])
    }
}

struct OTPBox: View {
    let digit: String
    let isFocused: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .fill(Color.inputBackground)
                .frame(width: Spacing.otpBoxSize, height: Spacing.otpBoxSize)
            
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .stroke(digit.isEmpty ? (isFocused ? Color.borderActive : Color.borderDefault) : Color.borderActive, lineWidth: Spacing.borderMedium)
                .frame(width: Spacing.otpBoxSize, height: Spacing.otpBoxSize)
            
            Text(digit)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.textPrimary)
        }
    }
}

// Usage:
// @State private var otpCode = ""
// OTPBoxes(otpCode: $otpCode)