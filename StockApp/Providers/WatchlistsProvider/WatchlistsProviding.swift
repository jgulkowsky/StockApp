//
//  WatchlistsProviding.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation
import Combine

protocol WatchlistsProviding {
    var watchlists: AnyPublisher<[Watchlist], Never> { get }
    func onAdd(watchlist: Watchlist)
    func onRemove(watchlist: Watchlist)
    func onUpdate(watchlist: Watchlist)
}
