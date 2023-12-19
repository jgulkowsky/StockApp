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
            .eraseToAnyPublisher()
    }
    
    private var watchlistsSubject = CurrentValueSubject<[Watchlist], Never>([])
    
    func onAdd(watchlist: Watchlist) {}
    
    func onRemove(watchlist: Watchlist) {}

    func onUpdate(watchlist: Watchlist) {}
    
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
