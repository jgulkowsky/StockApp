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
              let index = watchlists.firstIndex(where: { $0.id == watchlist.id } ),
              let symbolIndex = watchlist.symbols.firstIndex(of: symbol) else { return }
        
        var watchlist = watchlist
        watchlist.symbols.remove(at: symbolIndex)
        watchlists[Int(index)] = watchlist
        watchlistsSubject.send(watchlists)
        
        removeSymbolFromWatchlistInCoreData(symbol, watchlist)
    }
}

private extension WatchlistsProvider {
    func getWatchlistsFromCoreData() -> [Watchlist] {
        let watchlistEntities = getWatchlistEntities()
        let watchlists = watchlistEntities.map { watchlistEntity in
            let symbolEntities = getSymbolEntities(of: watchlistEntity)
            
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
              let symbolEntity = getSymbolEntity(of: watchlistEntity, withValue: symbol) else { return }
        
        viewContext.delete(symbolEntity)
        watchlistEntity.removeFromSymbols(symbolEntity)
        
        saveToCoreData()
    }
    
    func deleteWatchlistFromCoreData(_ watchlist: Watchlist) {
        guard let watchlistEntity = getWatchlistEntity(withId: watchlist.id) else { return }
        
        viewContext.delete(watchlistEntity)
        // don't have to worry about symbolEntities - they will be removed with delete rule cascade in relationships
        
        saveToCoreData()
    }
    
    func getWatchlistEntities(withId id: UUID? = nil) -> [WatchlistEntity] {
        func getRequest() -> NSFetchRequest<WatchlistEntity> {
            let request = NSFetchRequest<WatchlistEntity>(entityName: "WatchlistEntity")
            if let id = id {
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            }
            return request
        }
        do {
            let request = getRequest()
            let entities = try viewContext.fetch(request)
            return entities
        } catch {
            print("@jgu: Error in \(#fileID).\(#function)")
            return []
        }
    }
    
    func getWatchlistEntity(withId id: UUID) -> WatchlistEntity? {
        return getWatchlistEntities(withId: id).first
    }
    
    func getSymbolEntities(of watchlistEntity: WatchlistEntity, withValue value: String? = nil) -> [SymbolEntity] {
        func getRequest() -> NSFetchRequest<SymbolEntity> {
            let request = NSFetchRequest<SymbolEntity>(entityName: "SymbolEntity")
            let watchlistPredicate = NSPredicate(format: "watchlist == %@", watchlistEntity)
            
            var valuePredicate: NSPredicate?
            if let value = value {
                valuePredicate = NSPredicate(format: "value == %@", value)
            }
            
            let compoundPredicate = NSCompoundPredicate(
                type: .and,
                subpredicates: [watchlistPredicate, valuePredicate].compactMap { $0 }
            )
            request.predicate = compoundPredicate
            
            return request
        }
        do {
            let request = getRequest()
            let entities = try viewContext.fetch(request)
            return entities
        } catch {
            print("@jgu: Error in \(#fileID).\(#function)")
            return []
        }
    }
    
    func getSymbolEntity(of watchlistEntity: WatchlistEntity, withValue value: String) -> SymbolEntity? {
        return getSymbolEntities(of: watchlistEntity, withValue: value).first
    }
    
    func saveToCoreData() {
        do {
            try viewContext.save()
        } catch {
            print("@jgu: Error in \(#fileID).\(#function)")
        }
    }
}
