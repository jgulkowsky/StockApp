//
//  ChartDataExtensions.swift
//  StockAppTests
//
//  Created by Jan Gulkowski on 03/01/2024.
//

import Foundation
@testable import StockApp

extension ChartData: Equatable {
    public static func == (lhs: StockApp.ChartData, rhs: StockApp.ChartData) -> Bool {
        return lhs.values == rhs.values
    }
}
