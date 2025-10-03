//
//  AppFont.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import SwiftUI

struct AppFont {
    // MARK: - Font Styles
    static func heading1() -> Font {
        return .system(size: 28, weight: .bold)
    }
    
    static func heading2() -> Font {
        return .system(size: 24, weight: .semibold)
    }
    
    static func heading3() -> Font {
        return .system(size: 20, weight: .semibold)
    }
    
    static func bodyLarge() -> Font {
        return .system(size: 16, weight: .regular)
    }
    
    static func bodyRegular() -> Font {
        return .system(size: 14, weight: .regular)
    }
    
    static func bodySmall() -> Font {
        return .system(size: 12, weight: .regular)
    }
    
    static func button() -> Font {
        return .system(size: 16, weight: .bold)
    }
    
    static func label() -> Font {
        return .system(size: 14, weight: .medium)
    }
    
    static func caption() -> Font {
        return .system(size: 12, weight: .regular)
    }
}

// MARK: - Text Style Modifiers
extension Text {
    func h1Style() -> some View {
        self.font(AppFont.heading1())
            .foregroundColor(.textPrimary)
    }
    
    func h2Style() -> some View {
        self.font(AppFont.heading2())
            .foregroundColor(.textPrimary)
    }
    
    func h3Style() -> some View {
        self.font(AppFont.heading3())
            .foregroundColor(.textPrimary)
    }
    
    func bodyLargeStyle() -> some View {
        self.font(AppFont.bodyLarge())
            .foregroundColor(.textPrimary)
    }
    
    func bodyRegularStyle() -> some View {
        self.font(AppFont.bodyRegular())
            .foregroundColor(.textSecondary)
    }
    
    func bodySmallStyle() -> some View {
        self.font(AppFont.bodySmall())
            .foregroundColor(.textSecondary)
    }
    
    func labelStyle() -> some View {
        self.font(AppFont.label())
            .foregroundColor(.textPrimary)
    }
}