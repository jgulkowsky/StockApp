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
    var items: [StockItem] // e.g. AAPL, MSFT, GOOG
}

struct StockItem {
    var id: UUID
    var symbol: String // e.g. AAPL, MSFT, GOOG
    var name: String // e.g. Alphabet Inc. - Class A Common Stock
    var quote: Quote?
}

// + for sure some request structs

// Providers:

protocol WatchlistsProviding {
    var watchlists: AnyPublisher<[Watchlist], Never> { get }
    func onAdd(watchlist: Watchlist)
    func onRemove(watchlist: Watchlist)
    func onUpdate(watchlist: Watchlist)
}

protocol StockItemsProviding {
    func getStockItems(startingWith text: String) async throws -> [StockItem]
}

protocol PersistentStorageProviding {
    func getData<T>() async throws -> T
}

// Coordinator

enum Screen {
    case watchlists
    case watchlist
    case quote
}

enum Action {
    case addButtonTapped
    case itemSelected(data: [Any])
}

protocol Coordinator {
    func onAppStart()
    func execute(action: Action, onScreen screen: Screen)
}

// ViewModels:

class WatchlistsViewModel {}

class AddNewWatchlistViewModel {}

class AddNewStockItemViewModel {}
