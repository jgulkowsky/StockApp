//
//  LabeledTextfield.swift
//  StockApp
//
//  Created by Jan Gulkowski on 22/12/2023.
//

import UIKit
import SnapKit

class LabeledTextField: UIView {
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
    
    private lazy var label = {
        let label = UILabel(frame: .zero)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var textField: PaddedTextField = {
        let textField = PaddedTextField(frame: .zero)
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.gray.cgColor
        return textField
    }()
    
    func setText(_ text: String) {
        textField.text = text
    }
    
    init(label labelText: String,
         placeholder: String? = nil,
         keyboardType: UIKeyboardType? = nil,
         returnKeyType: UIReturnKeyType? = nil,
         delegate: UITextFieldDelegate
    ) {
        super.init(frame: .zero)
        addViews()
        setupConstraints()
        label.text = labelText
        textField.delegate = delegate
        
        if let placeholder = placeholder {
            textField.placeholder = placeholder
        }
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

private extension LabeledTextField {
    func addViews() {
        addSubview(label)
        addSubview(textField)
    }
    
    func setupConstraints() {
        label.snp.remakeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }
        
        textField.snp.remakeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(label.snp.trailing).offset(12.0)
        }
    }
}
