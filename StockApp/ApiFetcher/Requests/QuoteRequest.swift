//
//  QuoteRequest.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

struct QuoteRequest: ApiRequest {
    var request: URLRequest!
    
    init(_ symbol: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "cloud.iexapis.com"
        urlComponents.path = "/stable/stock/\(symbol.lowercased())/quote"
        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: self.apiToken)
        ]
        
        let url = urlComponents.url!
        self.request = URLRequest(url: url)
    }
}
