//
//  Coordinator.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import UIKit

protocol Coordinator: AnyObject {
    func onAppStart()
    func execute(action: Action)
}
