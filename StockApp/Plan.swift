//
//  Plan.swift
//  StockApp
//
//  Created by Jan Gulkowski on 15/12/2023.
//

import Foundation
import Combine

// todo: the following items (or similar) should be added to the project:

// Models:

// todo: we need to somehow store Watchlists in order in CoreData or any other storage - we can use other struct such as Watchlists containing them or their ids
struct Watchlist {
    var id: UUID // or Date or String
    var name: String // e.g. My first list or Big Tech Companies
    var symbols: [String] // e.g. AAPL, MSFT, GOOG
}

// + for sure some request structs

// Providers:

protocol StockItemsProviding {
    func getStockItems(startingWith text: String) async throws -> [String]
}

protocol PersistentStorageProviding {
    func getData<T>() async throws -> T
}
