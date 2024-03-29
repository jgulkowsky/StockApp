//
//  WatchlistsViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit
import SnapKit
import Combine
import StockAppLogic

class WatchlistsViewController: BaseViewController {
    private var viewModel: WatchlistsViewModel
    
    private lazy var loadingView = UIActivityIndicatorView(style: .large)

    private lazy var errorLabel = ErrorLabel()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            WatchlistsTableViewCell.self,
            forCellReuseIdentifier: WatchlistsTableViewCell.id
        )
        return tableView
    }()
    
    private var store = Set<AnyCancellable>()
    
    init(viewModel: WatchlistsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Watchlists"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        
        addViews()
        setupConstraints()
        setupBindings()
    }
    
    override func setupConstraints() {
        loadingView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        
        errorLabel.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                .inset(ErrorLabel.paddingTop)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
                .inset(UIView.horizontalPadding)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
                .inset(UIView.horizontalPadding)
        }
        
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
    }
}

extension WatchlistsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.watchlistsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: WatchlistsTableViewCell.id,
            for: indexPath
        ) as! WatchlistsTableViewCell
        
        cell.watchlist = viewModel.getWatchlistFor(index: indexPath.row)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.onItemTapped(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.heightForRow
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.onItemSwipedOut(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

private extension WatchlistsViewController {
    func addViews() {
        view.addSubview(loadingView)
        view.addSubview(errorLabel)
        view.addSubview(tableView)
    }
    
    func setupBindings() {
        viewModel.statePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.loadingView.isHidden = state != .loading
                self?.errorLabel.isHidden = state != .error
                self?.tableView.isHidden = state != .dataObtained
                
                if state == .loading {
                    self?.loadingView.startAnimating()
                } else {
                    self?.loadingView.stopAnimating()
                }
            }
            .store(in: &store)
        
        viewModel.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.errorLabel.text = error
            }
            .store(in: &store)
        
        viewModel.watchlistsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &store)
    }
    
    @objc func addButtonTapped() {
        viewModel.onAddButtonTapped()
    }
}


