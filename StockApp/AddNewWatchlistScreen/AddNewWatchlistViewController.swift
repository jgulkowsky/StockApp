//
//  AddNewWatchlistViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit
import SnapKit

class AddNewWatchlistViewController: NoNavigationBackButtonTextViewController {
    private var viewModel: AddNewWatchlistViewModel
    
    private lazy var watchlistNameTextField: LabeledTextField = LabeledTextField(
        label: "Watchlist name:",
        placeholder: "e.g. tech stocks",
        delegate: self
    )
    
    init(viewModel: AddNewWatchlistViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Add new watchlist"
        
        addViews()
        setupConstraints()
    }
}

extension AddNewWatchlistViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        viewModel.onSearchTextSubmitted(searchText: textField.text)
        return true;
    }
}

private extension AddNewWatchlistViewController {
    func addViews() {
        view.addSubview(watchlistNameTextField)
    }
    
    func setupConstraints() {
        watchlistNameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
            make.height.equalTo(30.0)
        }
    }
}

