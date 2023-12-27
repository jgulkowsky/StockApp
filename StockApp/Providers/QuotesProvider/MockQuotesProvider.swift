//
//  MockQuotesProvider.swift
//  StockApp
//
//  Created by Jan Gulkowski on 27/12/2023.
//

import Foundation

class MockQuotesProvider: QuotesProviding {
    func getQuote(forSymbol symbol: String) async throws -> Quote {
        let bidPrice = Double.random(in: 80.0...100.0)
        let askPrice = Double.random(in: bidPrice...110.0)
        let lastPrice = Double.random(in: bidPrice...askPrice)
        let quote: Quote = Quote(date: .now, bidPrice: bidPrice, askPrice: askPrice, lastPrice: lastPrice)
        return quote
    }
}
