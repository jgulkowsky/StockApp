//
//  WatchlistsViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation

class WatchlistsViewModel {
    private unowned let coordinator: Coordinator
    
    init(coordinator: Coordinator) {
#if DEBUG
        print("@jgu: \(Self.self).init()")
#endif
        self.coordinator = coordinator
    }
    
#if DEBUG
    deinit {
        print("@jgu: \(Self.self).deinit()")
    }
#endif
}
