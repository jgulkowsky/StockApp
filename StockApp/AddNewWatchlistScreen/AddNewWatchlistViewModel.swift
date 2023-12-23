//
//  AddNewWatchlistViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation
import Combine

class AddNewWatchlistViewModel {
    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject
            .eraseToAnyPublisher()
    }
    
    var watchlistTextPublisher: AnyPublisher<String, Never> {
        watchlistTextSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private var errorSubject = CurrentValueSubject<String?, Never>(nil)
    private var watchlistTextSubject = CurrentValueSubject<String?, Never>(nil)
    private var store = Set<AnyCancellable>()
    
    private unowned let coordinator: Coordinator
    private let watchlistsProvider: WatchlistsProviding
    
    private var watchlists: [Watchlist]?
    
    init(coordinator: Coordinator,
         watchlistsProvider: WatchlistsProviding
    ) {
#if DEBUG
        print("@jgu: \(Self.self).init()")
#endif
        self.coordinator = coordinator
        self.watchlistsProvider = watchlistsProvider
        setupBindings()
    }
    
    func onTextFieldFocused(initialText: String?) {
        errorSubject.send(nil)
    }
    
    func onSearchTextSubmitted(searchText: String?) {
        guard let searchText = searchText,
              let watchlists = watchlists else { return }
        
        let watchlistNames = watchlists.map { $0.name }
        let trimmedName = searchText.trimmingCharacters(in: .whitespaces)
        
        watchlistTextSubject.send(trimmedName)
        
        guard !trimmedName.isEmpty else {
            errorSubject.send("Watchlist name can't be empty!")
            return
        }
        guard !watchlistNames.contains(where: { $0 == trimmedName }) else {
            errorSubject.send("Watchlist with this name already exists!")
            return
        }
        
        watchlistsProvider.onAdd(
            Watchlist.init(id: UUID(), name: trimmedName, symbols: [])
        )
        coordinator.execute(action: .inputSubmitted)
    }
    
#if DEBUG
    deinit {
        print("@jgu: \(Self.self).deinit()")
    }
#endif
}

private extension AddNewWatchlistViewModel {
    func setupBindings() {
        self.watchlistsProvider.watchlists
            .sink { [weak self] watchlists in
                self?.watchlists = watchlists
            }
            .store(in: &store)
    }
}
