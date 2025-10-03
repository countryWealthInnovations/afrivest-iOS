//
//  Validators.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 02/10/2025.
//


import Foundation

struct Validators {
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Validates international phone number with country code
    /// Accepts any valid country code (1-4 digits) followed by 6-15 digits
    /// Examples:
    /// - 256700000001 (Uganda)
    /// - 14155552671 (USA)
    /// - 447911123456 (UK)
    /// - 9711234567890 (UAE)
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        // Remove any spaces, dashes, parentheses, or plus signs
        let cleanPhone = phone.replacingOccurrences(of: "[\\s\\-\\(\\)\\+]", with: "", options: .regularExpression)
        
        // International phone pattern:
        // - Starts with 1-9 (first digit of country code)
        // - Followed by 6-18 more digits (total length 7-19 digits)
        let phoneRegex = "^[1-9][0-9]{6,18}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        return phonePredicate.evaluate(with: cleanPhone)
    }
    
    /// Formats phone number for display
    static func formatPhoneNumber(_ phone: String) -> String {
        let cleanPhone = phone.replacingOccurrences(of: "[\\s\\-\\(\\)\\+]", with: "", options: .regularExpression)
        
        return cleanPhone.hasPrefix("+") ? cleanPhone : "+\(cleanPhone)"
    }
    
    /// Validates and formats phone number
    /// Returns formatted number or nil if invalid
    static func validateAndFormatPhone(_ phone: String) -> String? {
        return isValidPhoneNumber(phone) ? formatPhoneNumber(phone) : nil
    }
    
    /// Extracts country code from phone number
    static func extractCountryCode(_ phone: String) -> String? {
        let cleanPhone = phone.replacingOccurrences(of: "[\\s\\-\\(\\)\\+]", with: "", options: .regularExpression)
        
        // Try to match common country code patterns
        if cleanPhone.hasPrefix("1") && cleanPhone.count >= 11 {
            return "1" // USA/Canada
        } else if cleanPhone.hasPrefix("44") && cleanPhone.count >= 12 {
            return "44" // UK
        } else if cleanPhone.hasPrefix("971") && cleanPhone.count >= 12 {
            return "971" // UAE
        } else if cleanPhone.hasPrefix("256") && cleanPhone.count >= 12 {
            return "256" // Uganda
        } else if cleanPhone.hasPrefix("254") && cleanPhone.count >= 12 {
            return "254" // Kenya
        } else if cleanPhone.hasPrefix("86") && cleanPhone.count >= 13 {
            return "86" // China
        } else if cleanPhone.count >= 10 {
            return String(cleanPhone.prefix(3)) // Default: first 3 digits
        }
        
        return nil
    }
    
    static func isValidPassword(_ password: String) -> [String] {
        var errors: [String] = []
        
        if password.count < 8 {
            errors.append("At least 8 characters")
        }
        if !password.contains(where: { $0.isUppercase }) {
            errors.append("One uppercase letter")
        }
        if !password.contains(where: { $0.isNumber }) {
            errors.append("One number")
        }
        if !password.contains(where: { !$0.isLetter && !$0.isNumber }) {
            errors.append("One special character")
        }
        
        return errors
    }
    
    static func getPasswordStrength(_ password: String) -> PasswordStrength {
        var strength = 0
        
        if password.count >= 8 { strength += 1 }
        if password.contains(where: { $0.isUppercase }) { strength += 1 }
        if password.contains(where: { $0.isLowercase }) { strength += 1 }
        if password.contains(where: { $0.isNumber }) { strength += 1 }
        if password.contains(where: { !$0.isLetter && !$0.isNumber }) { strength += 1 }
        
        switch strength {
        case 0...2: return .weak
        case 3...4: return .medium
        default: return .strong
        }
    }
    
    static func isValidName(_ name: String) -> Bool {
        let words = name.trimmingCharacters(in: .whitespaces).components(separatedBy: " ").filter { !$0.isEmpty }
        return words.count >= 2 && words.allSatisfy { $0.allSatisfy { $0.isLetter } }
    }
}

enum PasswordStrength {
    case weak, medium, strong
}