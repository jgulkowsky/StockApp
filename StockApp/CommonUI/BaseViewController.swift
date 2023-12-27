//
//  BaseViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit

class BaseViewController: UIViewController {
    // satisfies 'no back button text' requirement
    override func viewDidLoad() {
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    // satisfies 'sending needs for update when device is rotated' requirement
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        setupConstraints()
    }
    
    func setupConstraints() {
        fatalError("setupConstraints() should be overriden by the child UIViewController!")
    }
}
