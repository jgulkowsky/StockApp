//
//  AddNewWatchlistViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit

class AddNewWatchlistViewController: NoNavigationBackButtonTextViewController {
    private var viewModel: AddNewWatchlistViewModel
    
    init(viewModel: AddNewWatchlistViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
