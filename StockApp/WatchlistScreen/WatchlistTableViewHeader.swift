//
//  WatchlistTableViewHeader.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import UIKit
import SnapKit

class WatchlistTableViewHeader: BaseTableViewHeader {
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
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupConstraints() {
        let leftPadding = UIView.horizontalPadding
        let rightPadding = UIView.horizontalPadding + 20.0
        let labelWidth = (UIScreen.main.bounds.width - leftPadding - rightPadding) / 4

        nameLabel.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(leftPadding)
            make.width.equalTo(labelWidth)
        }

        bidPriceLabel.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(nameLabel.snp.trailing)
            make.width.equalTo(labelWidth)
        }

        askPriceLabel.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(bidPriceLabel.snp.trailing)
            make.width.equalTo(labelWidth)
        }

        lastPriceLabel.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(askPriceLabel.snp.trailing)
            make.trailing.equalToSuperview().inset(rightPadding)
        }
    }
}

private extension WatchlistTableViewHeader {
    func addViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(bidPriceLabel)
        contentView.addSubview(askPriceLabel)
        contentView.addSubview(lastPriceLabel)
    }
}
