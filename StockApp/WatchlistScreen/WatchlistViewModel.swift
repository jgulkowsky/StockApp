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
    
    var stockItemsPublisher: AnyPublisher<[StockItem], Never> {
        stockItemsSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var stockItemsCount: Int { stockItemsSubject.value.count }
    
    private var stateSubject = CurrentValueSubject<State, Never>(.loading)
    private var errorSubject = CurrentValueSubject<String?, Never>(nil)
    private var stockItemsSubject = CurrentValueSubject<[StockItem], Never>([])
    
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    private var store = Set<AnyCancellable>()
    
    private let watchlistsProvider: WatchlistsProviding
    private let quotesProvider: QuotesProviding
    private let watchlist: Watchlist
    private let refreshRate: Double
    
    init(watchlistsProvider: WatchlistsProviding,
         quotesProvider: QuotesProviding,
         watchlist: Watchlist,
         refreshRate: Double
    ) {
        self.watchlistsProvider = watchlistsProvider
        self.quotesProvider = quotesProvider
        self.watchlist = watchlist
        self.refreshRate = refreshRate
        
        fetchData()
    }
    
    func getStockItemFor(index: Int) -> StockItem? {
        guard index < stockItemsSubject.value.count else { return nil }
        return stockItemsSubject.value[index]
    }
}

private extension WatchlistViewModel {
    func fetchData() {
        Task {
            do {
                let stockItems = try await getStockItemsSimultaneously()
                    .sorted()// todo: if there's any misspelling in any of the symbols (which should rather not happen but these are 2 APIs - one you get symbol from the second you send it to) then this will throw and error will be shown - think how you should respond - maybe symbol with empty values or just ommit the symbol as it wasn't there
                stockItemsSubject.send(stockItems)
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
                    if let stockItems = try? await self.getStockItemsSimultaneously()
                        .sorted() {
                        self.stockItemsSubject.send(stockItems)
                        self.errorSubject.send(nil)
                        self.stateSubject.send(.dataObtained)
                    }
                }
            }
            .store(in: &store)
    }
    
    func getStockItemsSimultaneously() async throws -> [StockItem] {
        let stockItems = try await withThrowingTaskGroup(
            of: StockItem.self,
            returning: [StockItem].self
        ) { taskGroup in
            watchlist.symbols.forEach { symbol in
                taskGroup.addTask {
                    return StockItem(
                        symbol: symbol,
                        quote: try await self.quotesProvider.getQuote(forSymbol: symbol)
                    )
                }
            }

            return try await taskGroup.reduce(into: [StockItem]()) { list, stockItem in
                list.append(stockItem)
            }
        }
        return stockItems
    }
}
