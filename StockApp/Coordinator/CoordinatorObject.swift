//
//  CoordinatorObject.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit

class CoordinatorObject: Coordinator {
    private let navigationController: UINavigationController
    private let watchlistsProvider: WatchlistsProviding
    private let quotesProvider: QuotesProviding
    private let chartDataProvider: ChartDataProviding
    
    init(navigationController: UINavigationController,
         watchlistsProvider: WatchlistsProviding,
         quotesProvider: QuotesProviding,
         chartDataProvider: ChartDataProviding
    ) {
        self.navigationController = navigationController
        self.watchlistsProvider = watchlistsProvider
        self.quotesProvider = quotesProvider
        self.chartDataProvider = chartDataProvider
    }

    func onAppStart() {
        let watchlist = Watchlist(
            id: UUID(uuidString: "E358D0AA-1DDC-4551-81CD-1AF209CA2D9E")!, // todo: just for now so WatchlistsProvider has watchlist with the same id
            name: "My First List",
            symbols: ["AAPL", "MSFT", "GOOG"]
        )
        
        let vc = WatchlistViewController(
            viewModel: WatchlistViewModel(
                coordinator: self,
                watchlistsProvider: watchlistsProvider,
                quotesProvider: quotesProvider,
                watchlist: watchlist,
                refreshRate: 5
            )
        )
        navigationController.pushViewController(vc, animated: false)
    }
    
    func execute(action: Action) {
        guard let rootVC = self.navigationController.viewControllers.first else {
            return
        }
        
        if rootVC is WatchlistsViewController {
            
        } else if rootVC is AddNewWatchlistViewController {
            
        } else if rootVC is WatchlistViewController {
            switch action {
            case .itemSelected(let data):
                if let stockItem = data as? StockItem {
                    let vc = QuoteViewController(
                        viewModel: QuoteViewModel(
                            coordinator: self,
                            quotesProvider: quotesProvider,
                            chartDataProvider: chartDataProvider,
                            symbol: stockItem.symbol,
                            refreshRate: 5
                        )
                    )
                    navigationController.pushViewController(vc, animated: false)
                }
            case .addButtonTapped:
                print("go to add new symbol screen")
            }
        } else if rootVC is AddNewSymbolViewController {
            
        } else if rootVC is QuoteViewController {
            // todo: here nothing - but we need to add other VCs to put here more if cases
        }
    }
}
