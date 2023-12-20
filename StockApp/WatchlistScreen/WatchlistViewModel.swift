//
//  WatchlistViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation
import Combine

class WatchlistViewModel: StatefulViewModel {
    var titlePublisher: AnyPublisher<String, Never> {
        titleSubject
            .removeDuplicates()
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
    
    private var titleSubject = CurrentValueSubject<String, Never>("")
    private var stockItemsSubject = CurrentValueSubject<[StockItem], Never>([])
    
    private var store = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    
    private unowned let coordinator: Coordinator
    private let watchlistsProvider: WatchlistsProviding
    private let quotesProvider: QuotesProviding
    private var watchlist: Watchlist
    private let refreshRate: Double
    
    init(coordinator: Coordinator,
         watchlistsProvider: WatchlistsProviding,
         quotesProvider: QuotesProviding,
         watchlist: Watchlist,
         refreshRate: Double
    ) {
#if DEBUG
        print("@jgu: \(Self.self).init()")
#endif
        self.coordinator = coordinator
        self.watchlistsProvider = watchlistsProvider
        self.quotesProvider = quotesProvider
        self.watchlist = watchlist
        self.refreshRate = refreshRate
        
        super.init(
            stateSubject: stateSubject,
            errorSubject: errorSubject
        )
        
        setupBindings()
    }
    
#if DEBUG
    deinit {
        print("@jgu: \(Self.self).deinit()")
    }
#endif
    
    func onViewWillAppear() {
        turnOnTimer()
    }

    func onViewWillDisappear() {
        turnOffTimer()
    }
    
    func getStockItemFor(index: Int) -> StockItem? {
        guard index < stockItemsSubject.value.count else { return nil }
        return stockItemsSubject.value[index]
    }
    
    func onItemTapped(at index: Int) {
        let stockItem = stockItemsSubject.value[index]
        coordinator.execute(action: .itemSelected(data: stockItem))
    }
    
    func onAddButtonTapped() {
        coordinator.execute(action: .addButtonTapped(data: watchlist))
    }
    
    func onItemSwipedOut(at index: Int) {
        var stockItems = stockItemsSubject.value
        let removedItem = stockItems.remove(at: index)
        stockItemsSubject.send(stockItems)
        
        watchlist.symbols.removeAll { $0 == removedItem.symbol }
        
        watchlistsProvider.onUpdate(watchlist: watchlist)
    }
}

private extension WatchlistViewModel {
    func setupBindings() {
        self.watchlistsProvider.watchlists
            .sink { [weak self] watchlists in
                guard let `self` = self else { return }
                if let watchlistFromProvider = watchlists.first(
                    where: { $0.id == self.watchlist.id }
                ) {
                    self.watchlist = watchlistFromProvider
                    self.titleSubject.send(self.watchlist.name)
                    self.fetchStockItems()
                }
            }
            .store(in: &store)
    }
    
    func fetchStockItems() {
        Task {
            do {
                let stockItems = try await getStockItemsSimultaneously()
                    .sorted()// todo: if there's any misspelling in any of the symbols (which should rather not happen but these are 2 APIs - one you get symbol from the second you send it to) then this will throw and error will be shown - think how you should respond - maybe symbol with empty values or just ommit the symbol as it wasn't there
                // todo: even if there's some problem for fetching any of the stockItems then error will be thrown - it's a little overkill (it happened once that for some reason api didn't return items - don't know if all of them if only one - but better to minimize the error occurence - so it shows up only if we get empty array of stock items)
                stockItemsSubject.send(stockItems)
                stateSubject.send(.dataObtained)
            } catch {
                errorSubject.send("Unfortunatelly cannot fetch data in current moment.\n\nCheck your connection and try again.")
                stateSubject.send(.error)
            }
        }
    }
    
    // todo: we need to stop quote requests from WatchlistViewModel when we are on AddNewSymbolViewController or QuoteViewController
    // todo: very similar to QuoteViewModel - maybeput into one place?
    func turnOnTimer() {
        timerCancellable = Timer.publish(every: self.refreshRate, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { [weak self] in
                    // todo: we could check if stock market is closed - if so then we should't make calls - this logic should be put into quotesProvider that would just return last quote and not send request until the stock is open once again
                    guard let stockItems = try? await self?.getStockItemsSimultaneously()
                        .sorted() else { return }
                    self?.stockItemsSubject.send(stockItems)
                }
            }
    }
    
    func turnOffTimer() {
        timerCancellable = nil
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
