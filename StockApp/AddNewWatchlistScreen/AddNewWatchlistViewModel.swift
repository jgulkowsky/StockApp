//
//  AddNewWatchlistViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation
import Combine

class AddNewWatchlistViewModel {
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
    
    func onSearchTextSubmitted(searchText: String?) {
        guard let searchText = searchText,
              let watchlists = watchlists else { return }
        
        let watchlistNames = watchlists.map { $0.name }
        let name = searchText.trimmingCharacters(in: .whitespaces)
        
        guard !name.isEmpty,
              !watchlistNames.contains(where: { $0 == name }) else { return }
        
        watchlistsProvider.onAdd(
            Watchlist.init(id: UUID(), name: name, symbols: [])
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
