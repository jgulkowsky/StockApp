//
//  AddNewSymbolViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation
import Combine

class AddNewSymbolViewModel {
    var symbolsPublisher: AnyPublisher<[String], Never> {
        symbolsSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var symbolsCount: Int { symbolsSubject.value.count }
    
    private var symbolsSubject = CurrentValueSubject<[String], Never>([])
    
    private unowned let coordinator: Coordinator
    private let symbolsProvider: SymbolsProviding
    
    init(coordinator: Coordinator,
         symbolsProvider: SymbolsProviding
    ) {
#if DEBUG
        print("@jgu: \(Self.self).init()")
#endif
        self.coordinator = coordinator
        self.symbolsProvider = symbolsProvider
    }
    
#if DEBUG
    deinit {
        print("@jgu: \(Self.self).deinit()")
    }
#endif
    
    func getSymbolFor(index: Int) -> String? {
        guard index < symbolsSubject.value.count else { return nil }
        return symbolsSubject.value[index]
    }
    
    func onSearchTextChanged(to newText: String) {
        fetchData(for: newText)
    }
    
    func onItemTapped(at index: Int) {
        let symbol = symbolsSubject.value[index]
        coordinator.execute(action: .itemSelected(data: symbol))
    }
}

private extension AddNewSymbolViewModel {
    func fetchData(for text: String) {
        Task {
            do {
                let symbols = try await self.symbolsProvider.getSymbols(startingWith: text)
                symbolsSubject.send(symbols)
            } catch {
                // todo: consider having state and error too - what if we get error?
//                errorSubject.send("Unfortunatelly cannot fetch data in current moment.\n\nCheck your connection and try again.")
//                stateSubject.send(.error)
            }
        }
    }
}
