//
//  AddNewSymbolViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit
import SnapKit
import Combine
import StockAppLogic

class AddNewSymbolViewController: BaseViewController {
    private var viewModel: AddNewSymbolViewModel
    
    private lazy var searchBarTextField: SolidTextField = {
        let textField = SolidTextField(
            insets: UIEdgeInsets.init(top: 0, left: 35.0, bottom: 0, right: 10.0)
        )
        textField.delegate = self
        textField.placeholder = "Search for symbol to add..."
        textField.autocorrectionType = .no
        textField.setIcon("magnifyingglass")
        textField.addTarget(self, action: #selector(onSearchTextChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            AddNewSymbolTableViewCell.self,
            forCellReuseIdentifier: AddNewSymbolTableViewCell.id
        )
        return tableView
    }()
    
    private var store = Set<AnyCancellable>()
    
    init(viewModel: AddNewSymbolViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add new symbol"
        
        addViews()
        setupConstraints()
        setupBindings()
    }
    
    override func setupConstraints() {
        searchBarTextField.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                .inset(5.0) // todo: maybe constant? as every view need to have this top constraint under the large title
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
                .inset(UIView.horizontalPadding)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
                .inset(UIView.horizontalPadding)
            make.height.equalTo(35.0)
        }
        
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(searchBarTextField.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
    }
}

extension AddNewSymbolViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddNewSymbolViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.symbolsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AddNewSymbolTableViewCell.id,
            for: indexPath
        ) as! AddNewSymbolTableViewCell
        
        cell.symbol = viewModel.getSymbolFor(index: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.onItemTapped(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.heightForRow
    }
}

private extension AddNewSymbolViewController {
    func addViews() {
        view.addSubview(searchBarTextField)
        view.addSubview(tableView)
    }
    
    func setupBindings() {
        viewModel.symbolsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &store)
    }
    
    @objc func onSearchTextChanged() {
        if let text = searchBarTextField.text {
            viewModel.onSearchTextChanged(to: text)
        }
    }
}
