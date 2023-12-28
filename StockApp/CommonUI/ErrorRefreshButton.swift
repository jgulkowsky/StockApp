//
//  ErrorRefreshButton.swift
//  StockApp
//
//  Created by Jan Gulkowski on 28/12/2023.
//

import UIKit

class ErrorRefreshButton: UIButton {
    static let paddingTop = 30.0
    static let height = 40.0
    static let width = 150.0
    
    init() {
        super.init(frame: .zero)
        self.setTitle("Refresh", for: .normal)
        self.backgroundColor = UIColor(named: "SolidButton")
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = Self.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
