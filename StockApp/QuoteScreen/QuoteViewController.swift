//
//  QuoteViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import UIKit
import SnapKit
import Combine

class QuoteViewController: UIViewController {
    private var viewModel: QuoteViewModel
    
    private lazy var bidPriceLabel = UILabel(frame: .zero)
    private lazy var askPriceLabel = UILabel(frame: .zero)
    private lazy var lastPriceLabel = UILabel(frame: .zero)
    
    private var store = Set<AnyCancellable>()
    
    init(viewModel: QuoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(bidPriceLabel)
        view.addSubview(askPriceLabel)
        view.addSubview(lastPriceLabel)
        
        setupConstraints()
        setupBindings()
    }
}

private extension QuoteViewController {
    func setupConstraints() {
        bidPriceLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
            make.height.equalTo(30.0)
        }
        
        askPriceLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(bidPriceLabel.snp.bottom)
            make.leading.equalTo(bidPriceLabel.snp.leading)
            make.trailing.equalTo(bidPriceLabel.snp.trailing)
            make.height.equalTo(bidPriceLabel.snp.height)
        }
        
        lastPriceLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(askPriceLabel.snp.bottom)
            make.leading.equalTo(bidPriceLabel.snp.leading)
            make.trailing.equalTo(bidPriceLabel.snp.trailing)
            make.height.equalTo(bidPriceLabel.snp.height)
        }
    }
    
    func setupBindings() {
        viewModel.bidPricePublisher
            .receive(on: RunLoop.main)
            .sink { self.bidPriceLabel.text = $0 }
            .store(in: &store)
        viewModel.askPricePublisher
            .receive(on: RunLoop.main)
            .sink { self.askPriceLabel.text = $0 }
            .store(in: &store)
        viewModel.lastPricePublisher
            .receive(on: RunLoop.main)
            .sink { self.lastPriceLabel.text = $0 }
            .store(in: &store)
    }
}
