//
//  QuotesProvider.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

class QuotesProvider: QuotesProviding {
    private let apiFetcher: ApiFetching
    
    init(apiFetcher: ApiFetching) {
        self.apiFetcher = apiFetcher
    }
    
    func getQuote(forSymbol symbol: String) async throws -> Quote {
        let quote: Quote = try await apiFetcher.fetchData(
            forRequest: QuoteRequest(symbol),
            andDecoder: QuoteDecoder()
        )
        print("@jgu: quote: \(quote)")
        // todo: for now it gives such data: Quote(date: 2023-12-18 20:59:59 +0000, bidPrice: 0.0, askPrice: 0.0, lastPrice: 195.9)
        // todo: I'm not sure why bidPrice and askPrice are so low and why date and latestPrice are same all the time - maybe it's because stock market is closed - check it out tomorrow during the day
        return quote
    }
}
