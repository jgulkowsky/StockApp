//
//  WatchlistsProvider.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation
import Combine

class WatchlistsProvider: WatchlistsProviding {
    var watchlists: AnyPublisher<[Watchlist], Never> {
        watchlistsSubject
            .debounce(for: 0.8, scheduler: RunLoop.main) // todo: just to mimic the async action - remove later on
            .eraseToAnyPublisher()
    }
    
    private var watchlistsSubject = CurrentValueSubject<[Watchlist], Never>([])
    
    func onAdd(watchlist: Watchlist) {}
    
    func onRemove(watchlist: Watchlist) {
        var watchlists = watchlistsSubject.value
        guard let index = watchlists.firstIndex(where: { $0.id == watchlist.id } ) else { return }
        watchlists.remove(at: index)
        watchlistsSubject.send(watchlists)
    }

    func onUpdate(watchlist: Watchlist) {
        var watchlists = watchlistsSubject.value
        guard let index = watchlists.firstIndex(where: { $0.id == watchlist.id } ) else { return }
        watchlists[Int(index)] = watchlist
        watchlistsSubject.send(watchlists)
    }
    
    init() {
        // todo: normally we would get it from CoreData
        let watchlists = [
            Watchlist(
                id: UUID(),
                name: "My First List",
                symbols: ["AAPL", "MSFT", "GOOG"]
            ),
            Watchlist(
                id: UUID(),
                name: "My Other List",
                symbols: ["MSFT"]
            )
        ]
        watchlistsSubject.send(watchlists)
    }
}
