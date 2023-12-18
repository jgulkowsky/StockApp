//
//  QuotesProvider.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

class QuotesProvider: QuotesProviding {
    func getQuote(forSymbol symbol: String) async throws -> Quote {
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 second
        let quote = Quote(
            date: .now,
            bidPrice: Double.random(in: 80.0...200.0),
            askPrice: Double.random(in: 80.0...200.0),
            lastPrice: Double.random(in: 80.0...200.0)
        )
        return quote
    }
}
