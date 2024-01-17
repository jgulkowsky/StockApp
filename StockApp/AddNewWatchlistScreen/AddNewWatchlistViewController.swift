//
//  AddNewWatchlistViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit
import SnapKit
import Combine
import StockAppLogic

class AddNewWatchlistViewController: BaseViewController {
    private var viewModel: AddNewWatchlistViewModel
    
    private lazy var watchlistNameTextField: SolidTextField = {
        let textField = SolidTextField()
        textField.delegate = self
        textField.placeholder = "Just give it any name you like..."
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var errorLabel = ErrorLabel()
    
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
        title = "Add new watchlist"
        
        addViews()
        setupConstraints()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        watchlistNameTextField.becomeFirstResponder()
    }
    
    override func setupConstraints() {
        watchlistNameTextField.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                .inset(UITextField.paddingTop)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
                .inset(UIView.horizontalPadding)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
                .inset(UIView.horizontalPadding)
            make.height.equalTo(UITextField.height)
        }
        
        errorLabel.snp.remakeConstraints { make in
            make.top.equalTo(watchlistNameTextField.snp.bottom)
                .offset(ErrorLabel.paddingTop)
            make.leading.trailing.equalTo(watchlistNameTextField)
        }
    }
}

extension AddNewWatchlistViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel.onTextFieldFocused()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.onTextFieldSubmitted(text: textField.text)
        return true
    }
}

private extension AddNewWatchlistViewController {
    func addViews() {
        view.addSubview(watchlistNameTextField)
        view.addSubview(errorLabel)
    }
    
    func setupBindings() {
        viewModel.watchlistTextPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.watchlistNameTextField.text = text
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

