//
//  PaddedTextField.swift
//  StockApp
//
//  Created by Jan Gulkowski on 17/01/2024.
//

import UIKit

class PaddedTextField: UITextField {
    private static let insets = UIEdgeInsets.init(top: 0, left: 10.0, bottom: 0, right: 10.0)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Self.insets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Self.insets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Self.insets)
    }
}
