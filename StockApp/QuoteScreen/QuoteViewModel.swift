//
//  QuoteViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import Foundation
import Combine

class QuoteViewModel {
    var chartDataPublisher: AnyPublisher<ChartData, Never> {
        chartDataSubject
            .eraseToAnyPublisher()
    }
    
    var bidPricePublisher: AnyPublisher<String, Never> {
        bidPriceSubject
            .map { value in
                if let value = value {
                    return "Bid Price: \(value)"
                } else {
                    return "Bid Price: "
                }
            }
            .eraseToAnyPublisher()
    }
    
    var askPricePublisher: AnyPublisher<String, Never> {
        askPriceSubject
            .map { value in
                if let value = value {
                    return "Ask Price: \(value)"
                } else {
                    return "Ask Price: "
                }
            }
            .eraseToAnyPublisher()
    }
    
    var lastPricePublisher: AnyPublisher<String, Never> {
        lastPriceSubject
            .map { value in
                if let value = value {
                    return "Last Price: \(value)"
                } else {
                    return "Last Price: "
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var chartDataSubject = CurrentValueSubject<ChartData, Never>(ChartData(values: []))
    private var bidPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    private var askPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    private var lastPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    
    init() {
        Task {
            try await fetchData()
        }
    }
}

private extension QuoteViewModel {
    func fetchData() async throws {
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 second
        
        let chartData = ChartData(
            values: [
                ChartItem(close: 90.0, high: 100.0, low: 70.0, open: 80.0, date: Date(timeIntervalSince1970: 1702911600)),
                ChartItem(close: 100.0, high: 110.0, low: 50.0, open: 80.0, date: Date(timeIntervalSince1970: 1702915200)),
                ChartItem(close: 90.0, high: 150.0, low: 20.0, open: 80.0, date: Date(timeIntervalSince1970: 1702918800)),
                ChartItem(close: 90.0, high: 90.0, low: 10.0, open: 10.0, date: Date(timeIntervalSince1970: 1702922400)),
                ChartItem(close: 90.0, high: 140.0, low: 70.0, open: 80.0, date: Date(timeIntervalSince1970: 1702926000))
            ]
        )
        chartDataSubject.send(chartData)
        
        let quote = Quote(date: .now, bidPrice: 171.12, askPrice: 171.33, lastPrice: 171.12)
        bidPriceSubject.send(quote.bidPrice)
        askPriceSubject.send(quote.askPrice)
        lastPriceSubject.send(quote.lastPrice)
    }
}
