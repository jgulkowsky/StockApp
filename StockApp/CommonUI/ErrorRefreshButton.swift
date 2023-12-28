//
//  ErrorRefreshButton.swift
//  StockApp
//
//  Created by Jan Gulkowski on 28/12/2023.
//

import UIKit

class ErrorRefreshButton: UIButton {
    init(height: CGFloat) {
        super.init(frame: .zero)
        self.setTitle("Refresh", for: .normal)
        self.backgroundColor = UIColor(named: "SolidButton")
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
