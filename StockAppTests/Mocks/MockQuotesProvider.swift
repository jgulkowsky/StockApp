//
//  MockQuotesProvider.swift
//  StockAppTests
//
//  Created by Jan Gulkowski on 03/01/2024.
//

import Foundation
@testable import StockApp

class MockQuotesProvider: QuotesProviding {
    enum MockQuotesProviderError: Error {
        case any
    }
    
    // setters
    var delayInMillis: UInt64?
    var shouldThrow = false
    var quoteToReturn: Quote?
    
    // getters
    var getQuoteForSymbolCalled = false
    var getQuoteForSymbolCallsCounter = 0
    var getQuoteForSymbolSymbol: String?
    
    func getQuote(forSymbol symbol: String) async throws -> Quote {
        getQuoteForSymbolCalled = true
        getQuoteForSymbolCallsCounter += 1
        getQuoteForSymbolSymbol = symbol
        
        if let delayInMillis = delayInMillis {
            try? await Task.sleep(nanoseconds: delayInMillis)
        }
        
        if shouldThrow {
            throw MockQuotesProviderError.any
        }
    
        return quoteToReturn!
    }
}
