//
//  SolidTextField.swift
//  StockApp
//
//  Created by Jan Gulkowski on 17/01/2024.
//

import UIKit
import SnapKit

class SolidTextField: UIView {
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
    
    private lazy var textField: PaddedTextField = {
        let textField = PaddedTextField(frame: .zero)
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.layer.cornerRadius = 7
        textField.backgroundColor = .systemGray6
        return textField
    }()
    
    func setText(_ text: String) {
        textField.text = text
    }
         
    init(placeholder: String = "",
         keyboardType: UIKeyboardType? = nil,
         returnKeyType: UIReturnKeyType? = nil,
         delegate: UITextFieldDelegate
    ) {
        super.init(frame: .zero)
        addViews()
        setupConstraints()
        
        textField.delegate = delegate
        textField.placeholder = placeholder
        
        if let keyboardType = keyboardType {
            textField.keyboardType = keyboardType
        }
        if let returnKeyType = returnKeyType {
            textField.returnKeyType = returnKeyType
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SolidTextField {
    func addViews() {
        addSubview(textField)
    }
    
    func setupConstraints() {
        textField.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(5.0)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(35.0)
        }
    }
}
