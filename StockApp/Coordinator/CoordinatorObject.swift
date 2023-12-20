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
    private let symbolsProvider: SymbolsProviding
    private let chartDataProvider: ChartDataProviding
    
    init(navigationController: UINavigationController,
         watchlistsProvider: WatchlistsProviding,
         quotesProvider: QuotesProviding,
         symbolsProvider: SymbolsProviding,
         chartDataProvider: ChartDataProviding
    ) {
        self.navigationController = navigationController
        self.watchlistsProvider = watchlistsProvider
        self.quotesProvider = quotesProvider
        self.symbolsProvider = symbolsProvider
        self.chartDataProvider = chartDataProvider
    }

    func onAppStart() {
#if DEBUG
        let vc = TestRetainCyclesViewController(
            coordinator: self
        )
        navigationController.pushViewController(vc, animated: false)
#else
        let vc = WatchlistViewController(
            viewModel: WatchlistViewModel(
                coordinator: self,
                watchlistsProvider: watchlistsProvider,
                quotesProvider: quotesProvider,
                watchlist: Watchlist(
                    id: UUID(uuidString: "E358D0AA-1DDC-4551-81CD-1AF209CA2D9E")!, // todo: just for now so WatchlistsProvider has watchlist with the same id
                    name: "My First List",
                    symbols: ["AAPL", "MSFT", "GOOG"]
                ),
                refreshRate: 5
            )
        )
        navigationController.pushViewController(vc, animated: true)
#endif
    }
    
    func execute(action: Action) {
        guard let currentVC = self.navigationController.viewControllers.last else {
            return
        }
        
        if currentVC is WatchlistsViewController {
            
        } else if currentVC is AddNewWatchlistViewController {
            
        } else if currentVC is WatchlistViewController {
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
                    navigationController.pushViewController(vc, animated: true)
                }
            case .addButtonTapped(let data):
                if let watchlist = data as? Watchlist {
                    let vc = AddNewSymbolViewController(
                        viewModel: AddNewSymbolViewModel(
                            coordinator: self,
                            watchlistsProvider: watchlistsProvider,
                            symbolsProvider: symbolsProvider,
                            watchlist: watchlist
                        )
                    )
                    navigationController.pushViewController(vc, animated: true)
                }
            }
        } else if currentVC is AddNewSymbolViewController {
            switch action {
            case .itemSelected:
                navigationController.popViewController(animated: true)
            default:
                break
            }
        } else {
#if DEBUG
            if currentVC is TestRetainCyclesViewController {
                switch action {
                case .addButtonTapped:
                    let vc = WatchlistViewController(
                        viewModel: WatchlistViewModel(
                            coordinator: self,
                            watchlistsProvider: watchlistsProvider,
                            quotesProvider: quotesProvider,
                            watchlist: Watchlist(
                                id: UUID(uuidString: "E358D0AA-1DDC-4551-81CD-1AF209CA2D9E")!, // todo: just for now so WatchlistsProvider has watchlist with the same id
                                name: "My First List",
                                symbols: ["AAPL", "MSFT", "GOOG"]
                            ),
                            refreshRate: 5
                        )
                    )
                    navigationController.pushViewController(vc, animated: true)
                default:
                    break
                }
            }
#endif
        }
    }
}
