//
//  DateExtensions.swift
//  StockApp
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import Foundation

// todo: all these methods are generated usingChatGPT - be aware

extension Date {
    static func daysBetween(startDate: Date, andEndDate endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }
    
    static func daysInCurrentMonth() -> [Date] {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: currentDate),
              let endOfMonth = calendar.date(byAdding: DateComponents(day: range.upperBound - 1), to: startOfMonth) else {
            return []
        }
        
        var days: [Date] = []
        var date = startOfMonth
        
        while date <= endOfMonth {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    static func last30Days() -> [Date] {
        let calendar = Calendar.current
        let currentDate = Date()
        let endDate = currentDate
        let startDate = calendar.date(byAdding: .day, value: -29, to: currentDate) ?? Date()
        return Date.daysBetween(startDate: startDate, andEndDate: endDate)
    }
}
