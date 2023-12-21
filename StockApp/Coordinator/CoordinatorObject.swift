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
        let vc = WatchlistsViewController(
            viewModel: WatchlistsViewModel(
                coordinator: self,
                watchlistsProvider: watchlistsProvider
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
            switch action {
            case .itemSelected(let data):
                if let watchlist = data as? Watchlist {
                    let vc = WatchlistViewController(
                        viewModel: WatchlistViewModel(
                            coordinator: self,
                            watchlistsProvider: watchlistsProvider,
                            quotesProvider: quotesProvider,
                            watchlist: watchlist,
                            refreshRate: 5
                        )
                    )
                    navigationController.pushViewController(vc, animated: true)
                }
            case .addButtonTapped:
                let vc = AddNewWatchlistViewController(
                    viewModel: AddNewWatchlistViewModel(
                        coordinator: self
                    )
                )
                navigationController.pushViewController(vc, animated: true)
            }
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
                    let vc = WatchlistsViewController(
                        viewModel: WatchlistsViewModel(
                            coordinator: self,
                            watchlistsProvider: watchlistsProvider
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
