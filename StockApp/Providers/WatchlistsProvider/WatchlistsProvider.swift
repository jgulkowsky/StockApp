//
//  WatchlistsProvider.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation
import Combine
import CoreData

class WatchlistsProvider: WatchlistsProviding {
    var watchlists: AnyPublisher<[Watchlist], Never> {
        watchlistsSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private var watchlistsSubject = CurrentValueSubject<[Watchlist]?, Never>(nil)
    private let viewContext = PersistenceController.shared.viewContext
    private var store = Set<AnyCancellable>()
    
    init() {
        let watchlists = getWatchlistsFromCoreData()
        watchlistsSubject.send(watchlists)
        
        // todo: just for setting some entities in CoreData until we have AddWatchlistViewModel functionality
        if watchlists.isEmpty {
            onAdd(
                Watchlist(
                    id: UUID(),
                    name: "My First List",
                    symbols: ["AAPL", "GOOG", "MSFT"]
                )
            )
            
            onAdd(
                Watchlist(
                    id: UUID(),
                    name: "My Other List",
                    symbols: ["AAPL", "GOOG"]
                )
            )
        }
    }
    
    func onAdd(_ watchlist: Watchlist) {
        watchlistsSubject.value?.append(watchlist)
        addWatchlistToCoreData(watchlist)
    }
    
    func onRemove(_ watchlist: Watchlist) {
        guard var watchlists = watchlistsSubject.value,
              let index = watchlists.firstIndex(where: { $0.id == watchlist.id } ) else { return }
        watchlists.remove(at: index)
        watchlistsSubject.send(watchlists)
        deleteWatchlistFromCoreData(watchlist)
    }
    
    func onAdd(_ symbol: String, to watchlist: Watchlist) {
        guard var watchlists = watchlistsSubject.value,
              let index = watchlists.firstIndex(where: { $0.id == watchlist.id } ) else { return }
        
        var watchlist = watchlist
        watchlist.symbols.append(symbol)
        watchlists[Int(index)] = watchlist
        watchlistsSubject.send(watchlists)
        
        addSymbolToWatchlistInCoreData(symbol, watchlist)
    }
    
    func onRemove(_ symbol: String, from watchlist: Watchlist) {
        guard var watchlists = watchlistsSubject.value,
              let index = watchlists.firstIndex(where: { $0.id == watchlist.id } ) else { return }
        
        guard let symbolIndex = watchlist.symbols.firstIndex(of: symbol) else { return }
        
        var watchlist = watchlist
        watchlist.symbols.remove(at: symbolIndex)
        watchlists[Int(index)] = watchlist
        watchlistsSubject.send(watchlists)
        
        removeSymbolFromWatchlistInCoreData(symbol, watchlist)
    }
}

private extension WatchlistsProvider {
    func getWatchlistsFromCoreData() -> [Watchlist] {
        let watchlistEntities = getWatchlistEntites()
        let watchlists = watchlistEntities.map { watchlistEntity in
            let symbolEntities = getSymbolEntites(of: watchlistEntity)
            
            return Watchlist(
                id: watchlistEntity.id!,
                name: watchlistEntity.name!,
                symbols: symbolEntities.map { $0.value! }
            )
        }
        return watchlists
    }
    
    func addWatchlistToCoreData(_ watchlist: Watchlist) {
        let watchlistEntity = WatchlistEntity(context: viewContext)
        watchlistEntity.id = watchlist.id
        watchlistEntity.name = watchlist.name
        watchlist.symbols.forEach { symbol in
            let symbolEntity = SymbolEntity(context: viewContext)
            symbolEntity.value = symbol
            watchlistEntity.addToSymbols(symbolEntity)
        }
        
        saveToCoreData()
    }
    
    func addSymbolToWatchlistInCoreData(_ symbol: String, _ watchlist: Watchlist) {
        guard let watchlistEntity = getWatchlistEntity(withId: watchlist.id) else { return }
        
        let symbolEntity = SymbolEntity(context: viewContext)
        symbolEntity.value = symbol
        watchlistEntity.addToSymbols(symbolEntity)
        
        saveToCoreData()
    }
    
    func removeSymbolFromWatchlistInCoreData(_ symbol: String, _ watchlist: Watchlist) {
        guard let watchlistEntity = getWatchlistEntity(withId: watchlist.id),
              let symbolEntities = watchlistEntity.symbols?.allObjects as? [SymbolEntity],
              let symbolEntity = symbolEntities.first(where: { $0.value == symbol }) else {
                  return
              }
        
        viewContext.delete(symbolEntity)
        watchlistEntity.removeFromSymbols(symbolEntity) // todo: not sure if needed - this reference should be nullified
        
        saveToCoreData()
    }
    
    func deleteWatchlistFromCoreData(_ watchlist: Watchlist) {
        guard let watchlistEntity = getWatchlistEntity(withId: watchlist.id) else { return }
        
        viewContext.delete(watchlistEntity)
        // don't have to worry about symbolEntities - they will be removed with delete rule cascade in relationships
        saveToCoreData()
    }
    
    // todo: rename here and everywhere to Entities not Entites
    func getWatchlistEntites(withId id: UUID? = nil) -> [WatchlistEntity] {
        func getRequest() -> NSFetchRequest<WatchlistEntity> {
            let request = NSFetchRequest<WatchlistEntity>(entityName: "WatchlistEntity")
            if let id = id as? CVarArg {
                request.predicate = NSPredicate(format: "id == %@", id)
            }
            return request
        }
        do {
            let request = getRequest()
            let entites = try viewContext.fetch(request)
            return entites
        } catch {
            print("@jgu: Error in \(#fileID).\(#function)")
            return []
        }
    }
    
    func getWatchlistEntity(withId id: UUID) -> WatchlistEntity? {
        return getWatchlistEntites(withId: id).first
    }
    
    func getSymbolEntites(of watchlistEntity: WatchlistEntity) -> [SymbolEntity] {
        func getRequest() -> NSFetchRequest<SymbolEntity> {
            let request = NSFetchRequest<SymbolEntity>(entityName: "SymbolEntity")
            request.predicate = NSPredicate(format: "watchlist == %@", watchlistEntity)
            return request
        }
        do {
            let request = getRequest()
            let entites = try viewContext.fetch(request)
            return entites
        } catch {
            print("@jgu: Error in \(#fileID).\(#function)")
            return []
        }
    }
    
    func saveToCoreData() {
        do {
            try viewContext.save()
        } catch {
            print("@jgu: Error in \(#fileID).\(#function)")
        }
    }
}
