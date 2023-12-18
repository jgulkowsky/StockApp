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
    
    private let timer = Timer.publish(every: 5, on: .main, in: .common)
        .autoconnect()
    private var store = Set<AnyCancellable>()
    
    private let quotesProvider: QuotesProviding
    private let chartDataProvider: ChartDataProviding
    private let symbol: String
    
    init(quotesProvider: QuotesProviding,
         chartDataProvider: ChartDataProviding,
         symbol: String
    ) {
        self.quotesProvider = quotesProvider
        self.chartDataProvider = chartDataProvider
        self.symbol = symbol
        
        fetchData()
        setupTimerBinding()
    }
}

private extension QuoteViewModel {
    func fetchData() {
        Task {
            do {
                async let getQuote = self.quotesProvider.getQuote(forSymbol: symbol)
                async let getChartData = self.chartDataProvider.getChartData()
                let (quote, chartData) = try await (getQuote, getChartData)
                bidPriceSubject.send(quote.bidPrice)
                askPriceSubject.send(quote.askPrice)
                lastPriceSubject.send(quote.lastPrice)
                chartDataSubject.send(chartData)
            } catch {
                print("Error")
                // todo: we need to show error or just show nil and try again? (up to N times)
            }
        }
    }
    
    func setupTimerBinding() {
        timer
            .sink { _ in
                Task {
                    do {
                        let quote = try await self.quotesProvider.getQuote(forSymbol: self.symbol)
                        self.bidPriceSubject.send(quote.bidPrice)
                        self.askPriceSubject.send(quote.askPrice)
                        self.lastPriceSubject.send(quote.lastPrice)
                    } catch {
                        print("Error")
                        // todo: we need to show error or just show nil and try again? (up to N times)
                    }
                }
            }
            .store(in: &store)
    }
}
