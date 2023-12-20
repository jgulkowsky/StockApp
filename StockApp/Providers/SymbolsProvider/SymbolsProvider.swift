//
//  SymbolsProvider.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation

class SymbolsProvider: SymbolsProviding {
    func getSymbols(startingWith text: String) async throws -> [String] {
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 seconds
        return ["AAPL", "MSFT", "GOOG"]
    }
}
