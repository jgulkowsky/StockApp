//
//  DoubleExtensions.swift
//  StockApp
//
//  Created by Jan Gulkowski on 27/12/2023.
//

import Foundation

extension Double {
    func to2DecPlaces() -> String {
        return String(format: "%.2f", self) // todo: in fact we should also round the value as now we are lying a little bit to the user - let's add tests for this and update this method to the proper one
    }
}
