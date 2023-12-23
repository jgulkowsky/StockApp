//
//  AddNewSymbolTableViewCell.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit
import SnapKit

class AddNewSymbolTableViewCell: UITableViewCell {
    static let id = "AddNewSymbolTableViewCell"
    private static let fontSize = 16.0
    
    var symbol: String? {
        didSet {
            if let symbol = symbol {
                symbolLabel.text = symbol
            }
        }
    }
    
    private lazy var symbolLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: Self.fontSize)
        return label
    }()
    
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

private extension AddNewSymbolTableViewCell {
    func addViews() {
        addSubview(symbolLabel)
    }
    
    func setupConstraints() {
        symbolLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
                .inset(UIView.horizontalPadding)
        }
    }
}