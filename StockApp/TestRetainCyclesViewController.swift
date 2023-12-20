//
//  TestRetainCyclesViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit

// todo: this is just for test - we put it on app start from coordinator so we can call all the deinits of the real VCs that are after this one - when app is ready we can leave it / mark with some debug only if etc / or just remove it (but it is useful class for eventual further development)

class TestRetainCyclesViewController: UIViewController {
    private unowned var coordinator: Coordinator
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
    }
    
    @objc func addButtonTapped() {
        coordinator.execute(action: .addButtonTapped)
    }
}
