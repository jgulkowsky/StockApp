//
//  ApiRequest.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

protocol ApiRequest {
    var apiToken: String? { get }
    var request: URLRequest! { get }
}

extension ApiRequest {
    var apiToken: String? {
        if let apiToken = ProcessInfo.processInfo.environment["API_TOKEN"] { // todo: in future we should move api token into our own backend so it cannot be stolen from the device - now it's not safe
            return apiToken
        } else {
            fatalError("Add API_TOKEN into scheme/run/arguments/environment variables")
            // todo: add info to README.md what are the steps to follow to make this project working
        }
    }
}
