//
//  WatchlistViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation
import Combine

class WatchlistViewModel {
    // todo: consider putting into one place as this is same (at least for now) as in QuoteViewModel
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
    
    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject
            .eraseToAnyPublisher()
    }
    
    private var stateSubject = CurrentValueSubject<State, Never>(.loading)
    private var errorSubject = CurrentValueSubject<String?, Never>(nil)
    
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    private var store = Set<AnyCancellable>()
    
    private let quotesProvider: QuotesProviding
    private let refreshRate: Double
    
    init(quotesProvider: QuotesProviding,
         refreshRate: Double
    ) {
        self.quotesProvider = quotesProvider
        self.refreshRate = refreshRate
        
        fetchData()
    }
}

private extension WatchlistViewModel {
    func fetchData() {
        Task {
            do {
                // todo: use async groups for getting all the quotes
                let symbol = "AAPL"
                let quote = try await self.quotesProvider.getQuote(forSymbol: symbol)
                // todo: setup subjects
                stateSubject.send(.dataObtained)
                self.setupTimer()
            } catch {
                errorSubject.send("Unfortunatelly cannot fetch data in current moment.\n\nCheck your connection and try again.")
                stateSubject.send(.error)
            }
        }
    }
    
    // todo: very similar to QuoteViewModel - maybeput into one place?
    func setupTimer() {
        self.timer = Timer.publish(every: self.refreshRate, on: .main, in: .common)
           .autoconnect()
        self.timer?
            .sink { _ in
                Task {
                    // todo: we could check if stock market is closed - if so then we should't make calls - this logic should be put into quotesProvider that would just return last quote and not send request until the stock is open once again
                    
                    // todo: get for all the symbols
                    let symbol = "AAPL"
                    if let quote = try? await self.quotesProvider.getQuote(forSymbol: symbol) {
                        // todo: setup subjects
                        self.errorSubject.send(nil)
                        self.stateSubject.send(.dataObtained)
                    }
                }
            }
            .store(in: &store)
    }
}
