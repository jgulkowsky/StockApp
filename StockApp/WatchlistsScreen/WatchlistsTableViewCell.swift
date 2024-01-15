//
//  WatchlistsTableViewCell.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit
import SnapKit
import StockAppLogic

class WatchlistsTableViewCell: BaseTableViewCell {
    static let id = "WatchlistsTableViewCell"
    private static let fontSize = 16.0
    
    var watchlist: Watchlist? {
        didSet {
            if let watchlist = watchlist {
                watchlistNameLabel.text = watchlist.name
            }
        }
    }
    
    private lazy var watchlistNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: Self.fontSize)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupConstraints() {
        watchlistNameLabel.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
                .inset(UIView.horizontalPadding)
        }
    }
}

private extension WatchlistsTableViewCell {
    func addViews() {
        addSubview(watchlistNameLabel)
    }
}

