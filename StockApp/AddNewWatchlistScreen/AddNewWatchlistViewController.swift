//
//  AddNewWatchlistViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit
import SnapKit
import Combine

class AddNewWatchlistViewController: NoNavigationBackButtonTextViewController {
    private var viewModel: AddNewWatchlistViewModel
    
    private lazy var watchlistNameTextField: LabeledTextField = LabeledTextField(
        label: "Watchlist name:",
        placeholder: "e.g. tech stocks",
        delegate: self
    )
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .red
        return label
    }()
    
    private var store = Set<AnyCancellable>()
    
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
        setupBindings()
    }
}

extension AddNewWatchlistViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel.onTextFieldFocused(initialText: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        viewModel.onSearchTextSubmitted(searchText: textField.text)
        return true;
    }
}

private extension AddNewWatchlistViewController {
    func addViews() {
        view.addSubview(watchlistNameTextField)
        view.addSubview(errorLabel)
    }
    
    func setupConstraints() {
        watchlistNameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
            make.height.equalTo(30.0)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(watchlistNameTextField.snp.bottom)
            make.leading.trailing.equalTo(watchlistNameTextField)
            make.height.equalTo(30.0)
        }
    }
    
    func setupBindings() {
        viewModel.watchlistTextPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.watchlistNameTextField.setText(text)
            }
            .store(in: &store)
        
        viewModel.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.watchlistNameTextField.shake()
                    self?.errorLabel.isHidden = false
                    self?.errorLabel.text = error
                } else {
                    self?.errorLabel.isHidden = true
                    self?.errorLabel.text = ""
                }
            }
            .store(in: &store)
    }
}

