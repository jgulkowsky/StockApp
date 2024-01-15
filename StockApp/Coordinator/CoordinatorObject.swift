//
//  CoordinatorObject.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit
import Combine

class CoordinatorObject: Coordinator {
    private let navigationController: UINavigationController
    private let appFirstStartProvider: AppFirstStartProviding
    private let watchlistsProvider: WatchlistsProviding
    private let quotesProvider: QuotesProviding
    private let symbolsProvider: SymbolsProviding
    private let chartDataProvider: ChartDataProviding
    
    private var subscription: AnyCancellable?
    
    init(navigationController: UINavigationController,
         appFirstStartProvider: AppFirstStartProviding,
         watchlistsProvider: WatchlistsProviding,
         quotesProvider: QuotesProviding,
         symbolsProvider: SymbolsProviding,
         chartDataProvider: ChartDataProviding
    ) {
        self.navigationController = navigationController
        self.appFirstStartProvider = appFirstStartProvider
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
        self.appFirstStartProvider.setAppFirstStarted()
#else
        let vc = WatchlistsViewController(
            viewModel: WatchlistsViewModel(
                coordinator: self,
                watchlistsProvider: watchlistsProvider
            )
        )
        navigationController.pushViewController(vc, animated: false)
        
        if appFirstStartProvider.isFirstAppStart {
            subscription = watchlistsProvider.watchlists
                .sink { [weak self] watchlist in
                    guard let `self` = self else { return }
                    self.execute(action: .itemSelected(data: watchlist[0]))
                    self.subscription?.cancel()
                    self.appFirstStartProvider.setAppFirstStarted()
                }
        }
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
                    navigationController.pushViewController(
                        vc,
                        animated: !appFirstStartProvider.isFirstAppStart
                    )
                }
            case .addButtonTapped:
                let vc = AddNewWatchlistViewController(
                    viewModel: AddNewWatchlistViewModel(
                        coordinator: self,
                        watchlistsProvider: watchlistsProvider
                    )
                )
                navigationController.pushViewController(vc, animated: true)
            default:
                break
            }
        } else if currentVC is AddNewWatchlistViewController {
            switch action {
            case .inputSubmitted:
                navigationController.popViewController(animated: true)
            default:
                break
            }
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
                            watchlist: watchlist,
                            searchTextDebounceMillis: 500
                        )
                    )
                    navigationController.pushViewController(vc, animated: true)
                }
            default:
                break
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
