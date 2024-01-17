//
//  UITextFieldExtensions.swift
//  StockApp
//
//  Created by Jan Gulkowski on 17/01/2024.
//

import UIKit

extension UITextField {
    static let height = 35.0
    static let paddingTop = 5.0
    
    func setIcon(_ iconName: String) {
        let containerSize = 30.0
        let iconSize = 20.0
        let iconOffsetX = containerSize - iconSize
        let iconOffsetY = (containerSize - iconSize) / 2
        
        let containerView = UIView(
            frame: CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
        )
        let iconView = UIImageView(
            frame: CGRect(x: iconOffsetX,y: iconOffsetY, width: iconSize, height: iconSize)
        )
        containerView.addSubview(iconView)
        
//        iconView.backgroundColor = .red
//        containerView.backgroundColor = .green
        
        let image = UIImage(systemName: iconName)?.withRenderingMode(.alwaysTemplate)
        iconView.image = image
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .gray
        
        leftView = containerView
        leftViewMode = .always
    }
}
