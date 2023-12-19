//
//  WatchlistViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import UIKit
import SnapKit
import Combine

class WatchlistViewController: UIViewController {
    private var viewModel: WatchlistViewModel
    
    private lazy var loadingView = UIActivityIndicatorView(style: .large)
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            WatchlistTableViewCell.self,
            forCellReuseIdentifier: WatchlistTableViewCell.id
        )
        return tableView
    }()
    
    private var store = Set<AnyCancellable>()
    
    init(viewModel: WatchlistViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addViews()
        setupConstraints()
        setupBindings()
    }
}

extension WatchlistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.stockItemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: WatchlistTableViewCell.id,
            for: indexPath
        )
        
        (cell as? WatchlistTableViewCell)?
            .stockItem = viewModel.getStockItemFor(index: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle row selection
        print("Selected row \(indexPath.row + 1)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}

private extension WatchlistViewController {
    func addViews() {
        view.addSubview(loadingView)
        view.addSubview(errorLabel)
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(30)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
    }
    
    func setupBindings() {
        viewModel.statePublisher
            .receive(on: RunLoop.main)
            .sink { state in
                self.loadingView.isHidden = state != .loading
                self.errorLabel.isHidden = state != .error
                self.tableView.isHidden = state != .dataObtained
                
                if state == .loading {
                    self.loadingView.startAnimating()
                } else {
                    self.loadingView.stopAnimating()
                }
            }
            .store(in: &store)
        
        viewModel.errorPublisher
            .receive(on: RunLoop.main)
            .sink { self.errorLabel.text = $0 }
            .store(in: &store)
        
        viewModel.stockItemsPublisher
            .receive(on: RunLoop.main)
            .sink { _ in self.tableView.reloadData() }
            .store(in: &store)
    }
}
