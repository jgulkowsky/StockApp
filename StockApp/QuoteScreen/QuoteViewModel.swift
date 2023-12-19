//
//  QuoteViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import Foundation
import Combine

class QuoteViewModel {
    // todo: consider putting into one place as this is same (at least for now) as in WatchlistViewModel
    enum State {
        case loading
        case error
        case dataObtained
    }
    
    var statePublisher: AnyPublisher<State, Never> {
        stateSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
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
    
    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject
            .eraseToAnyPublisher()
    }
    
    private var stateSubject = CurrentValueSubject<State, Never>(.loading)
    
    private var chartDataSubject = CurrentValueSubject<ChartData, Never>(ChartData(values: []))
    private var bidPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    private var askPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    private var lastPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    
    private var errorSubject = CurrentValueSubject<String?, Never>(nil)
    
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    private var store = Set<AnyCancellable>()
    
    private let quotesProvider: QuotesProviding
    private let chartDataProvider: ChartDataProviding
    private let symbol: String
    private let refreshRate: Double
    
    init(quotesProvider: QuotesProviding,
         chartDataProvider: ChartDataProviding,
         symbol: String,
         refreshRate: Double
    ) {
        self.quotesProvider = quotesProvider
        self.chartDataProvider = chartDataProvider
        self.symbol = symbol
        self.refreshRate = refreshRate
        
        fetchData()
    }
}

private extension QuoteViewModel {
    func fetchData() {
        Task {
            do {
                async let getQuote = self.quotesProvider.getQuote(forSymbol: symbol)
                async let getChartData = self.chartDataProvider.getChartData(forSymbol: symbol)
                let (quote, chartData) = try await (getQuote, getChartData)
                bidPriceSubject.send(quote.bidPrice)
                askPriceSubject.send(quote.askPrice)
                lastPriceSubject.send(quote.lastPrice)
                chartDataSubject.send(chartData)
                stateSubject.send(.dataObtained)
                self.setupTimer()
            } catch {
                errorSubject.send("Unfortunatelly cannot fetch data in current moment.\n\nCheck your connection and try again.")
                stateSubject.send(.error)
            }
        }
    }
    
    func setupTimer() {
        self.timer = Timer.publish(every: self.refreshRate, on: .main, in: .common)
           .autoconnect()
        self.timer?
            .sink { _ in
                Task {
                    // todo: we could check if stock market is closed - if so then we should't make calls - this logic should be put into quotesProvider that would just return last quote and not send request until the stock is open once again
                    if let quote = try? await self.quotesProvider.getQuote(forSymbol: self.symbol) {
                        self.bidPriceSubject.send(quote.bidPrice)
                        self.askPriceSubject.send(quote.askPrice)
                        self.lastPriceSubject.send(quote.lastPrice)
                        self.errorSubject.send(nil)
                        self.stateSubject.send(.dataObtained)
                    }
                }
            }
            .store(in: &store)
    }
}
