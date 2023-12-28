//
//  ErrorLabel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 28/12/2023.
//

import UIKit

class ErrorLabel: UILabel {
    init() {
        super.init(frame: .zero)
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 0
        self.textAlignment = .center
        self.textColor = UIColor(named: "Error")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
