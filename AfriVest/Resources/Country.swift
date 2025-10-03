//
//  Country.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 03/10/2025.
//


import Foundation

struct Country: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let name: String
    let dialCode: String
    let flag: String
    
    static let all: [Country] = [
        // Africa
        Country(code: "UG", name: "Uganda", dialCode: "+256", flag: "🇺🇬"),
        Country(code: "KE", name: "Kenya", dialCode: "+254", flag: "🇰🇪"),
        Country(code: "TZ", name: "Tanzania", dialCode: "+255", flag: "🇹🇿"),
        Country(code: "RW", name: "Rwanda", dialCode: "+250", flag: "🇷🇼"),
        Country(code: "NG", name: "Nigeria", dialCode: "+234", flag: "🇳🇬"),
        Country(code: "GH", name: "Ghana", dialCode: "+233", flag: "🇬🇭"),
        Country(code: "ZA", name: "South Africa", dialCode: "+27", flag: "🇿🇦"),
        
        // North America
        Country(code: "US", name: "United States", dialCode: "+1", flag: "🇺🇸"),
        Country(code: "CA", name: "Canada", dialCode: "+1", flag: "🇨🇦"),
        
        // Europe
        Country(code: "GB", name: "United Kingdom", dialCode: "+44", flag: "🇬🇧"),
        Country(code: "FR", name: "France", dialCode: "+33", flag: "🇫🇷"),
        Country(code: "DE", name: "Germany", dialCode: "+49", flag: "🇩🇪"),
        Country(code: "IT", name: "Italy", dialCode: "+39", flag: "🇮🇹"),
        Country(code: "ES", name: "Spain", dialCode: "+34", flag: "🇪🇸"),
        Country(code: "NL", name: "Netherlands", dialCode: "+31", flag: "🇳🇱"),
        Country(code: "BE", name: "Belgium", dialCode: "+32", flag: "🇧🇪"),
        Country(code: "SE", name: "Sweden", dialCode: "+46", flag: "🇸🇪"),
        Country(code: "NO", name: "Norway", dialCode: "+47", flag: "🇳🇴"),
        Country(code: "DK", name: "Denmark", dialCode: "+45", flag: "🇩🇰"),
        
        // Middle East
        Country(code: "AE", name: "UAE", dialCode: "+971", flag: "🇦🇪"),
        Country(code: "SA", name: "Saudi Arabia", dialCode: "+966", flag: "🇸🇦"),
        
        // Asia
        Country(code: "CN", name: "China", dialCode: "+86", flag: "🇨🇳"),
        Country(code: "IN", name: "India", dialCode: "+91", flag: "🇮🇳"),
        Country(code: "JP", name: "Japan", dialCode: "+81", flag: "🇯🇵"),
        Country(code: "SG", name: "Singapore", dialCode: "+65", flag: "🇸🇬"),
        
        // Oceania
        Country(code: "AU", name: "Australia", dialCode: "+61", flag: "🇦🇺"),
        Country(code: "NZ", name: "New Zealand", dialCode: "+64", flag: "🇳🇿")
    ]
    
    static let `default` = Country(code: "UG", name: "Uganda", dialCode: "+256", flag: "🇺🇬")
    
    static func find(by dialCode: String) -> Country? {
        return all.first { $0.dialCode == dialCode }
    }
}