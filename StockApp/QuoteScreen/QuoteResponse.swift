//
//  QuoteResponse.swift
//  StockApp
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import Foundation

struct Quote: Codable {
    var date: Date // todo: create from "latestUpdate": 1702924254522 I believe
    var bidPrice: Double // todo: use "iexBidPrice": 196.09,
    var askPrice: Double // todo: use "iexAskPrice": 196.12,
    var lastPrice: Double // todo: use "latestPrice": 196.09,
}

// curl -k 'https://cloud.iexapis.com/stable/stock/aapl/quote?token=PUT_YOUR_TOKEN'

//{
//  "avgTotalVolume": 52433648,
//  "calculationPrice": "tops",
//  "change": -1.48,
//  "changePercent": -0.00749,
//  "close": null,
//  "closeSource": "official",
//  "closeTime": null,
//  "companyName": "Apple Inc",
//  "currency": "USD",
//  "delayedPrice": null,
//  "delayedPriceTime": null,
//  "extendedChange": null,
//  "extendedChangePercent": null,
//  "extendedPrice": null,
//  "extendedPriceTime": null,
//  "high": null,
//  "highSource": null,
//  "highTime": null,
//  "iexAskPrice": 196.12,
//  "iexAskSize": 534,
//  "iexBidPrice": 196.09,
//  "iexBidSize": 200,
//  "iexClose": 196.09,
//  "iexCloseTime": 1702924254522,
//  "iexLastUpdated": 1702924254522,
//  "iexMarketPercent": 0.026548831013156405,
//  "iexOpen": 196.11,
//  "iexOpenTime": 1702909800008,
//  "iexRealtimePrice": 196.09,
//  "iexRealtimeSize": 100,
//  "iexVolume": 821473,
//  "lastTradeTime": 1702924254522,
//  "latestPrice": 196.09,
//  "latestSource": "IEX real time price",
//  "latestTime": "1:30:54 PM",
//  "latestUpdate": 1702924254522,
//  "latestVolume": null,
//  "low": null,
//  "lowSource": null,
//  "lowTime": null,
//  "marketCap": 3049739139680,
//  "oddLotDelayedPrice": null,
//  "oddLotDelayedPriceTime": null,
//  "open": null,
//  "openTime": null,
//  "openSource": "official",
//  "peRatio": 31.99,
//  "previousClose": 197.57,
//  "previousVolume": 128538401,
//  "primaryExchange": "NASDAQ",
//  "symbol": "AAPL",
//  "volume": null,
//  "week52High": 199.62,
//  "week52Low": 123.15,
//  "ytdChange": 0.525679128956309,
//  "isUSMarketOpen": true
//}
