//
//  BaseTableViewHeader.swift
//  StockApp
//
//  Created by Jan Gulkowski on 27/12/2023.
//

import UIKit

class BaseTableViewHeader: UITableViewHeaderFooterView, ConstraintsSettable {
    // todo: this isn't perfect solution as it updates too often - even when timer fires so every 5 seconds
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
    
    func setupConstraints() {
        fatalError("setupConstraints() should be overriden by \(Self.self)!")
    }
}
