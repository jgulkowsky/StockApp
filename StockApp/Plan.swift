//
//  Plan.swift
//  StockApp
//
//  Created by Jan Gulkowski on 15/12/2023.
//

import Foundation
import Combine

// todo: the following items (or similar) should be added to the project:

// Providers:

protocol PersistentStorageProviding {
    func getData<T>() async throws -> T
}
