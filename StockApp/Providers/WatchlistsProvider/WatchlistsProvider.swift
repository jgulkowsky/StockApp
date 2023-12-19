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
                id: UUID(uuidString: "E358D0AA-1DDC-4551-81CD-1AF209CA2D9E")!, // todo: just for now so WatchlistsViewModel has watchlist with the same id
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
