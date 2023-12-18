//
//  ChartDataProviding.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

protocol ChartDataProviding {
    func getChartData() async throws -> ChartData
}
