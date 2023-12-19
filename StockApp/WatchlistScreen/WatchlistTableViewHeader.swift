//
//  WatchlistTableViewHeader.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import UIKit

// todo: generally it's very similar (the same in fact in UI part) to WatchlistTableViewCell - we should have them into one place

class WatchlistTableViewHeader: UITableViewHeaderFooterView {
    static let id = "WatchlistTableViewHeader"
    private static let fontSize = 10.0
    
    var items: [String]? {
        didSet {
            if let items = items {
                nameLabel.text = items[0]
                bidPriceLabel.text = items[1]
                askPriceLabel.text = items[2]
                lastPriceLabel.text = items[3]
            }
        }
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: Self.fontSize)
        return label
    }()
    
    private lazy var bidPriceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: Self.fontSize)
        return label
    }()
    
    private lazy var askPriceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: Self.fontSize)
        return label
    }()
    
    private lazy var lastPriceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: Self.fontSize)
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WatchlistTableViewHeader {
    func addViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(bidPriceLabel)
        contentView.addSubview(askPriceLabel)
        contentView.addSubview(lastPriceLabel)
    }
    
    func setupConstraints() {
        let horizontalPaddingLeft = 20.0
        let horizontalPaddingRight = 40.0
        let labelWidth = (UIScreen.main.bounds.width - horizontalPaddingLeft - horizontalPaddingRight) / 4
        
        nameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(horizontalPaddingLeft)
            make.width.equalTo(labelWidth)
        }
        
        bidPriceLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(nameLabel.snp.trailing)
            make.width.equalTo(labelWidth)
        }
        
        askPriceLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(bidPriceLabel.snp.trailing)
            make.width.equalTo(labelWidth)
        }
        
        lastPriceLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(askPriceLabel.snp.trailing)
            make.trailing.equalToSuperview().inset(horizontalPaddingRight)
        }
    }
}