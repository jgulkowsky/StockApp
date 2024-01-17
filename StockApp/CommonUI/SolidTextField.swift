//
//  SolidTextField.swift
//  StockApp
//
//  Created by Jan Gulkowski on 17/01/2024.
//

import UIKit

class SolidTextField: PaddedTextField {
    override init(insets: UIEdgeInsets? = nil) {
        super.init(insets: insets)
        self.borderStyle = .none
        self.layer.cornerRadius = 7
        self.backgroundColor = .systemGray6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
