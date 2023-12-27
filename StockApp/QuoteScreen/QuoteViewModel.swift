//
//  QuoteViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import Foundation
import Combine

class QuoteViewModel: StatefulViewModel {
    var titlePublisher: AnyPublisher<String, Never> {
        titleSubject
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
                    return "Bid Price: \(value.to2DecPlaces())"
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
                    return "Ask Price: \(value.to2DecPlaces())"
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
                    return "Last Price: \(value.to2DecPlaces())"
                } else {
                    return "Last Price: "
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var stateSubject = CurrentValueSubject<State, Never>(.loading)
    private var errorSubject = CurrentValueSubject<String?, Never>(nil)
    
    private var titleSubject = CurrentValueSubject<String, Never>("")
    private var chartDataSubject = CurrentValueSubject<ChartData, Never>(ChartData(values: []))
    private var bidPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    private var askPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    private var lastPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    
    private var timerCancellable: AnyCancellable?
    
    private unowned let coordinator: Coordinator
    private let quotesProvider: QuotesProviding
    private let chartDataProvider: ChartDataProviding
    private let symbol: String // todo: consider using stockItem: StockItem so VM don't have to load data for itself or even can but at least have sth to show without loading indicator
    private let refreshRate: Double
    
    init(coordinator: Coordinator,
         quotesProvider: QuotesProviding,
         chartDataProvider: ChartDataProviding,
         symbol: String,
         refreshRate: Double
    ) {
#if DEBUG
        print("@jgu: \(Self.self).init()")
#endif
        self.coordinator = coordinator
        self.quotesProvider = quotesProvider
        self.chartDataProvider = chartDataProvider
        self.symbol = symbol
        self.refreshRate = refreshRate
        
        super.init(
            stateSubject: stateSubject,
            errorSubject: errorSubject
        )
        
        self.titleSubject.send(self.symbol)
    }
    
#if DEBUG
    deinit {
        print("@jgu: \(Self.self).deinit()")
    }
#endif
    
    func onViewWillAppear() {
        fetchData()
        turnOnTimer()
    }

    func onViewWillDisappear() {
        turnOffTimer()
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
            } catch {
                errorSubject.send("Unfortunatelly cannot fetch data in current moment.\n\nCheck your connection and try again.")
                stateSubject.send(.error)
            }
        }
    }
    
    func turnOnTimer() {
        timerCancellable = Timer.publish(every: self.refreshRate, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { [weak self] in
                    // todo: we could check if stock market is closed - if so then we should't make calls - this logic should be put into quotesProvider that would just return last quote and not send request until the stock is open once again
                    guard let symbol = self?.symbol else { return }
                    guard let quote = try? await self?.quotesProvider.getQuote(forSymbol: symbol) else { return }
                    
                    self?.bidPriceSubject.send(quote.bidPrice)
                    self?.askPriceSubject.send(quote.askPrice)
                    self?.lastPriceSubject.send(quote.lastPrice)
                }
            }
    }
    
    func turnOffTimer() {
        timerCancellable = nil
    }
}
