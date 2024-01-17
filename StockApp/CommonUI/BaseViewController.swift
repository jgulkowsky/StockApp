//
//  BaseViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit

class BaseViewController: UIViewController, ConstraintsSettable {
    // satisfies 'no back button text' requirement and large title requirement
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "Background")
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // satisfies 'sending needs for update when device is rotated' requirement
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        setupConstraints()
    }
    
    func setupConstraints() {
        fatalError("setupConstraints() should be overriden by \(Self.self)!")
    }
}
