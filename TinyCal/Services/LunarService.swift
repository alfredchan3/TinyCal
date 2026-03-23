//
//  LunarService.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import Foundation

struct LunarDateInfo {
    let month: Int
    let day: Int
    let isLeapMonth: Bool
    let monthText: String
    let dayText: String
}

struct LunarService {
    private static let chineseCalendar = Calendar(identifier: .chinese)

    private static let monthNames = [
        "正月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "冬月", "臘月"
    ]

    private static let dayNames = [
        "初一", "初二", "初三", "初四", "初五",
        "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五",
        "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五",
        "廿六", "廿七", "廿八", "廿九", "三十"
    ]

    static func lunarDate(from date: Date) -> LunarDateInfo {
        let components = chineseCalendar.dateComponents([.month, .day], from: date)
        let month = components.month ?? 1
        let day = components.day ?? 1
        let isLeapMonth = components.isLeapMonth ?? false

        let monthIndex = (month - 1) % 12
        let dayIndex = (day - 1) % 30

        var monthText = monthNames[monthIndex]
        if isLeapMonth {
            monthText = "閏" + monthText
        }

        return LunarDateInfo(
            month: month,
            day: day,
            isLeapMonth: isLeapMonth,
            monthText: monthText,
            dayText: dayNames[dayIndex]
        )
    }
}
