//
//  DayInfo.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import Foundation

struct DayInfo: Identifiable {
    let id: Date
    let day: Int
    let lunarDayText: String
    let lunarMonthText: String?
    let holiday: String?
    let solarTerm: String?
    let zodiacSign: String?
    let isCurrentMonth: Bool
    let isToday: Bool
    var hasEvents: Bool

    var displayText: String {
        if let holiday = holiday {
            return holiday
        }
        if let solarTerm = solarTerm {
            return solarTerm
        }
        if let zodiacSign = zodiacSign {
            return zodiacSign
        }
        if let lunarMonthText = lunarMonthText {
            return lunarMonthText
        }
        return lunarDayText
    }
}
