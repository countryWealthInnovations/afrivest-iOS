//
//  LoanModels.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//

import Foundation

private extension KeyedDecodingContainer {
    nonisolated func flexString(_ key: Key) -> String? {
        if let s = try? decodeIfPresent(String.self, forKey: key) { return s }
        if let d = try? decodeIfPresent(Double.self, forKey: key) { return String(d) }
        if let i = try? decodeIfPresent(Int.self, forKey: key) { return String(i) }
        return nil
    }
    nonisolated func flexDouble(_ key: Key) -> Double? {
        if let d = try? decodeIfPresent(Double.self, forKey: key) { return d }
        if let s = try? decodeIfPresent(String.self, forKey: key), let d = Double(s) { return d }
        return nil
    }
}

struct LoanTerm: Codable, Identifiable, Sendable, Hashable {
    var id: String { term }
    let term: String
    let term_days: Int
    let interest_rate: String
    
    enum CodingKeys: String, CodingKey { case term, term_days, interest_rate }
    
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        term = try c.decode(String.self, forKey: .term)
        term_days = (try? c.decodeIfPresent(Int.self, forKey: .term_days)) ?? 0
        interest_rate = c.flexString(.interest_rate) ?? "0"
    }
}

struct LoanParty: Codable, Sendable {
    let uuid: String?
    let name: String?
    
    enum CodingKeys: String, CodingKey { case uuid, name }
    
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try c.decodeIfPresent(String.self, forKey: .uuid)
        name = try c.decodeIfPresent(String.self, forKey: .name)
    }
}

struct LoanRepaymentItem: Codable, Identifiable, Sendable {
    var id: String { (paid_at ?? "") + (amount ?? "") }
    let amount: String?
    let currency: String?
    let source: String?
    let paid_at: String?
    
    enum CodingKeys: String, CodingKey { case amount, currency, source, paid_at }
    
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        amount = c.flexString(.amount)
        currency = try c.decodeIfPresent(String.self, forKey: .currency)
        source = try c.decodeIfPresent(String.self, forKey: .source)
        paid_at = try c.decodeIfPresent(String.self, forKey: .paid_at)
    }
}

struct Loan: Codable, Identifiable, Sendable, Equatable {
    static func == (lhs: Loan, rhs: Loan) -> Bool { lhs.uuid == rhs.uuid }
    var id: String { uuid }
    let uuid: String
    let reference: String
    let principal: String?
    let currency: String
    let term: String?
    let interest_rate: String?
    let interest_amount: String?
    let handling_fee: String?
    let total_repayment: String?
    let purpose: String?
    let status: String
    let due_date: String?
    let created_at: String?
    let net_interest: Double?
    let borrower: LoanParty?
    let lender: LoanParty?
    let outstanding: Double?
    let amount_repaid: Double?
    let repayments: [LoanRepaymentItem]?
    
    var principalValue: Double { Double(principal ?? "0") ?? 0 }
    var totalValue: Double { Double(total_repayment ?? "0") ?? 0 }
    
    enum CodingKeys: String, CodingKey {
        case uuid, reference, principal, currency, term, interest_rate, interest_amount,
             handling_fee, total_repayment, purpose, status, due_date, created_at,
             net_interest, borrower, lender, outstanding, amount_repaid, repayments
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try c.decode(String.self, forKey: .uuid)
        reference = try c.decode(String.self, forKey: .reference)
        principal = c.flexString(.principal)
        currency = (try? c.decodeIfPresent(String.self, forKey: .currency)) ?? "UGX"
        term = try c.decodeIfPresent(String.self, forKey: .term)
        interest_rate = c.flexString(.interest_rate)
        interest_amount = c.flexString(.interest_amount)
        handling_fee = c.flexString(.handling_fee)
        total_repayment = c.flexString(.total_repayment)
        purpose = try c.decodeIfPresent(String.self, forKey: .purpose)
        status = (try? c.decodeIfPresent(String.self, forKey: .status)) ?? "requested"
        due_date = try c.decodeIfPresent(String.self, forKey: .due_date)
        created_at = try c.decodeIfPresent(String.self, forKey: .created_at)
        net_interest = c.flexDouble(.net_interest)
        borrower = try c.decodeIfPresent(LoanParty.self, forKey: .borrower)
        lender = try c.decodeIfPresent(LoanParty.self, forKey: .lender)
        outstanding = c.flexDouble(.outstanding)
        amount_repaid = c.flexDouble(.amount_repaid)
        repayments = try c.decodeIfPresent([LoanRepaymentItem].self, forKey: .repayments)
    }
}

struct MyLoans: Codable, Sendable {
    let borrowed: [Loan]
    let lent: [Loan]
    
    enum CodingKeys: String, CodingKey { case borrowed, lent }
    
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        borrowed = (try? c.decodeIfPresent([Loan].self, forKey: .borrowed)) ?? []
        lent = (try? c.decodeIfPresent([Loan].self, forKey: .lent)) ?? []
    }
}

struct LoanWrapper: Codable, Sendable {
    let loan: Loan
    
    enum CodingKeys: String, CodingKey { case loan }
    
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        loan = try c.decode(Loan.self, forKey: .loan)
    }
}
