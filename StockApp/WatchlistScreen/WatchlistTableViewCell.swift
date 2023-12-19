//
//  WatchlistTableViewCell.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import UIKit
import SnapKit

class WatchlistTableViewCell: UITableViewCell {
    static let id = "WatchlistTableViewCell"
    
    var stockItem: StockItem? {
        didSet {
            if let stockItem = stockItem {
                symbolLabel.text = stockItem.symbol
                bidPriceLabel.text = "\(stockItem.quote.bidPrice)"
                askPriceLabel.text = "\(stockItem.quote.askPrice)"
                lastPriceLabel.text = "\(stockItem.quote.lastPrice)"
            }
        }
    }
    
    private lazy var symbolLabel: UILabel = UILabel(frame: .zero)
    private lazy var bidPriceLabel: UILabel = UILabel(frame: .zero)
    private lazy var askPriceLabel: UILabel = UILabel(frame: .zero)
    private lazy var lastPriceLabel: UILabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.addViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WatchlistTableViewCell {
    func addViews() {
        addSubview(symbolLabel)
        addSubview(bidPriceLabel)
        addSubview(askPriceLabel)
        addSubview(lastPriceLabel)
    }
    
    func setupConstraints() {
        let horizontalPadding = 20.0
        let labelWidth = (UIScreen.main.bounds.width - 2 * horizontalPadding) / 4
        
        symbolLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(horizontalPadding)
            make.width.equalTo(labelWidth)
        }
        
        bidPriceLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(symbolLabel.snp.trailing)
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
            make.trailing.equalToSuperview().inset(horizontalPadding)
        }
    }
}
