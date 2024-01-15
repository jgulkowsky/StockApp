//
//  TestRetainCyclesViewController.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

#if DEBUG
import UIKit

class TestRetainCyclesViewController: BaseViewController {
    private unowned var coordinator: Coordinator
    
    init(coordinator: Coordinator) {
        print("@jgu: \(Self.self).init()")
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("@jgu: \(Self.self).deinit()")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
    }
    
    @objc func addButtonTapped() {
        coordinator.execute(action: .addButtonTapped(data: nil))
    }
    
    override func setupConstraints() {}
}
#endif
