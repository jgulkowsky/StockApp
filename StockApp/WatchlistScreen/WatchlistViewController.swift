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

private extension WatchlistViewController {
    func addViews() {
        view.addSubview(loadingView)
        view.addSubview(errorLabel)
    }
    
    func setupConstraints() {
        loadingView.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview()
            make.height.width.equalTo(30)
        }
        
        errorLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
        }
    }
    
    func setupBindings() {
        viewModel.statePublisher
            .receive(on: RunLoop.main)
            .sink { state in
                self.loadingView.isHidden = state != .loading
                self.errorLabel.isHidden = state != .error
                
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
    }
}
