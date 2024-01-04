//
//  SceneDelegate.swift
//  StockApp
//
//  Created by Jan Gulkowski on 15/12/2023.
//

import UIKit

// todo: add README.md file with instructions how to setup the project (api key / debug and release config)
// todo: create TECHNICALDECISIONS.md file that justify usage of any architecture and design patterns - MVVM / TestRetainCyclesViewController / Coordinator / protocols - providers / api fetching / persistence / common files / think about more things
// todo: add padding to the tableView in AddNewSymbolVC (both for horizontal and vertical orientation) as sometimes values on the bottom will not be available because are under the keyboard / or at least add button for collapsing the keyboard

// todo: optional things:
// todo: prices sometimes get 0 for some reason - is it normal or we should treat it as a bug? (checkout responses in json)
// todo: in future we should move api token into our own backend so it cannot be stolen from the device - now it's not safe
// todo: WatchlistViewModel and QuoteViewModel have similar method turnOnTimer() - maybe it could be put into one place?
// todo: BaseTableViewHeader and BaseTableViewCell use layoutSubviews method for updating the constraints - this isn't perfect solution as it updates too often - when timer fires so every 5 seconds
// todo: checkout methods in DateExtensions - all of them were generated usingChatGPT - be aware - maybe you won't end up using them at all - then just remove them - but if not then add tests for them
// todo: we could check if stock market is closed when fetchin quote data - if so then we should't make calls - this logic should be put into quotesProvider that would just return last quote and not send request until the stock is open once again
// todo: consider passing stockItem instead of just symbol from WatchlistViewModel into QuoteViewModel - so VM don't have to load data for itself or even can but at least have sth to show without loading indicator
// todo: generally we don't support stareting / stopping timers when going into background foreground
// todo: errorLabels / loadingIndicators could be moved into BaseVC (logic for showing / hiding them too) - with use of StatefulViewModel

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    var coordinator: Coordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
    
        let navigationController = UINavigationController()
        
        let appFirstStartProvider = AppFirstStartProvider()
        let watchlistsCoreDataProvider = WatchlistsCoreDataProvider()
        let watchlistsProvider = WatchlistsProvider(
            coreDataProvider: watchlistsCoreDataProvider,
            appFirstStartProvider: appFirstStartProvider
        )
        
        let apiFetcher = ApiFetcher()
        let quotesProvider = QuotesProvider(
            apiFetcher: apiFetcher
        )
        let symbolsProvider = SymbolsProvider(
            apiFetcher: apiFetcher
        )
        let chartDataProvider = ChartDataProvider(
            apiFetcher: apiFetcher
        )
        
        self.coordinator = CoordinatorObject(
            navigationController: navigationController,
            appFirstStartProvider: appFirstStartProvider,
            watchlistsProvider: watchlistsProvider,
            quotesProvider: quotesProvider,
            symbolsProvider: symbolsProvider,
            chartDataProvider: chartDataProvider
        )
        self.coordinator?.onAppStart()
        
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
