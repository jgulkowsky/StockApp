//
//  PaddedTextField.swift
//  StockApp
//
//  Created by Jan Gulkowski on 17/01/2024.
//

import UIKit

class PaddedTextField: UITextField {
    private let insets: UIEdgeInsets
    
    init(insets: UIEdgeInsets?) {
        self.insets = insets ?? UIEdgeInsets.init(top: 0, left: 10.0, bottom: 0, right: 10.0)
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.insets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.insets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.insets)
    }
}
