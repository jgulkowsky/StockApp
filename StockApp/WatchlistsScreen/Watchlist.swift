//
//  Watchlist.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation

// todo: we need to somehow store Watchlists in order in CoreData or any other storage - we can use other struct such as Watchlists containing them or their ids
struct Watchlist: Equatable {
    var id: UUID // or Date or String
    var name: String // e.g. My first list or Big Tech Companies
    var symbols: [String] // e.g. AAPL, MSFT, GOOG
}
