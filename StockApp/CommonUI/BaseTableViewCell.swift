//
//  BaseTableViewCell.swift
//  StockApp
//
//  Created by Jan Gulkowski on 27/12/2023.
//

import UIKit

class BaseTableViewCell: UITableViewCell, ConstraintsSettable {
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
    
    func setupConstraints() {
        fatalError("setupConstraints() should be overriden by \(Self.self)!")
    }
}
