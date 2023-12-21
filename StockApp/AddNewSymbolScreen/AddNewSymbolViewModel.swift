//
//  AddNewSymbolViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation
import Combine

// todo: now we are experiencing a problem where we can add new symbol (which for some reason don't get quote) and we end up with error instead of seeing other symbols with their quotes and this one without quote like (symbol - - -) - this happens quite often - let's fix it

class AddNewSymbolViewModel {
    var symbolsPublisher: AnyPublisher<[String], Never> {
        symbolsSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var symbolsCount: Int { symbolsSubject.value.count }
    
    private var symbolsSubject = CurrentValueSubject<[String], Never>([])
    private var searchTextSubject = CurrentValueSubject<String?, Never>(nil)
    
    private var store = Set<AnyCancellable>()
    
    private unowned let coordinator: Coordinator
    private let watchlistsProvider: WatchlistsProviding
    private let symbolsProvider: SymbolsProviding
    private var watchlist: Watchlist
    
    init(coordinator: Coordinator,
         watchlistsProvider: WatchlistsProviding,
         symbolsProvider: SymbolsProviding,
         watchlist: Watchlist
    ) {
#if DEBUG
        print("@jgu: \(Self.self).init()")
#endif
        self.coordinator = coordinator
        self.watchlistsProvider = watchlistsProvider
        self.symbolsProvider = symbolsProvider
        self.watchlist = watchlist
        setupBindings()
    }
    
#if DEBUG
    deinit {
        print("@jgu: \(Self.self).deinit()")
    }
#endif
    
    func getSymbolFor(index: Int) -> String? {
        guard index < symbolsSubject.value.count else { return nil }
        return symbolsSubject.value[index]
    }
    
    func onSearchTextChanged(to newText: String) {
        searchTextSubject.send(newText)
    }
    
    func onItemTapped(at index: Int) {
        let symbol = symbolsSubject.value[index]
        
        if !watchlist.symbols.contains(symbol) {
            watchlistsProvider.onAdd(symbol, to: watchlist)
            watchlist.symbols.append(symbol)
        } // todo:  consider having this logic in watchlistsProvider
        
        coordinator.execute(action: .itemSelected(data: nil))
    }
}

private extension AddNewSymbolViewModel {
    func setupBindings() {
        self.searchTextSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .compactMap { $0 }
            .sink { [weak self] searchText in
                self?.fetchData(for: searchText)
            }
            .store(in: &store)
    }
    
    func fetchData(for text: String) {
        Task {
            do {
                let symbols = try await self.symbolsProvider.getSymbols(startingWith: text)
                symbolsSubject.send(symbols)
            } catch {
                // todo: consider having state and error too - what if we get error?
//                errorSubject.send("Unfortunatelly cannot fetch data in current moment.\n\nCheck your connection and try again.")
//                stateSubject.send(.error)
            }
        }
    }
}
