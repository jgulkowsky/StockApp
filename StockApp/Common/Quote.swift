//
//  Quote.swift
//  StockApp
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import Foundation

// todo: prices sometimes get 0 for some reason - is it normal or we should treat it as a bug? (checkout responses in json)

struct Quote: Codable, Equatable {
    let date: Date
    let bidPrice: Double
    let askPrice: Double
    let lastPrice: Double
    
    private enum CodingKeys: String, CodingKey {
        case date = "latestUpdate"
        case bidPrice = "iexBidPrice"
        case askPrice = "iexAskPrice"
        case lastPrice = "latestPrice"
    }
}
