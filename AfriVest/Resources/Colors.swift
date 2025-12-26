//
//  Colors.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI

extension Color {
    // MARK: - Brand Colors
    static let primaryGold = Color(hex: "EFBF04")
    static let backgroundDark1 = Color(hex: "2F2F2F")
    static let backgroundDark2 = Color(hex: "333231")
    static let backgroundDark = Color(hex: "1A1A1A")
    static let inputBackground = Color(hex: "1A1A1A")
    
    // MARK: - Semantic Colors
    static let successGreen = Color(hex: "00C853")
    static let errorRed = Color(hex: "FF3B30")
    static let warningYellow = Color(hex: "FFB800")
    
    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "B0B0B0")
    static let textDisabled = Color(hex: "666666")
    static let textPlaceholder = Color(hex: "808080")
    
    // MARK: - Border Colors
    static let borderDefault = Color(hex: "666666")
    static let borderActive = Color(hex: "EFBF04")
    static let borderSuccess = Color(hex: "00C853")
    static let borderError = Color(hex: "FF3B30")
    
    // MARK: - Button Colors
    static let buttonPrimary = Color(hex: "EFBF04")
    static let buttonPrimaryText = Color.black
    static let buttonDisabled = Color(hex: "4D4D4D")
    static let buttonDisabledText = Color(hex: "808080")
    
    // MARK: - Overlay Colors
    static let overlayDark = Color.black.opacity(0.6)
    static let overlayLight = Color.black.opacity(0.3)
    static let glassmorphismOverlay = Color.black.opacity(0.4)
    
    // MARK: - Helper for Hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
