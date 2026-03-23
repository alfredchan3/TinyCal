//
//  HolidayService.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import Foundation

struct HolidayService {

    // MARK: - Gregorian Fixed Holidays (month, day) -> name

    private static let gregorianHolidays: [Int: [Int: String]] = [
        1: [1: "元旦"],
        2: [14: "情人節"],
        3: [8: "婦女節", 12: "植樹節", 15: "消費者"],
        4: [1: "愚人節"],
        5: [1: "勞動節", 4: "青年節"],
        6: [1: "兒童節"],
        7: [1: "建黨節"],
        8: [1: "建軍節"],
        9: [10: "教師節"],
        10: [1: "國慶節"],
        12: [25: "聖誕節"],
    ]

    // MARK: - Lunar Fixed Holidays (month, day) -> name

    private static let lunarHolidays: [Int: [Int: String]] = [
        1: [1: "春節", 15: "元宵節"],
        2: [2: "龍抬頭節"],
        5: [5: "端午節"],
        7: [7: "七夕", 15: "中元節"],
        8: [15: "中秋節"],
        9: [9: "重陽節"],
    ]

    // MARK: - Zodiac Signs

    private struct ZodiacSign {
        let name: String
        let startMonth: Int
        let startDay: Int
    }

    private static let zodiacSigns: [ZodiacSign] = [
        ZodiacSign(name: "水瓶", startMonth: 1, startDay: 20),
        ZodiacSign(name: "雙魚", startMonth: 2, startDay: 19),
        ZodiacSign(name: "白羊", startMonth: 3, startDay: 21),
        ZodiacSign(name: "金牛", startMonth: 4, startDay: 20),
        ZodiacSign(name: "雙子", startMonth: 5, startDay: 21),
        ZodiacSign(name: "巨蟹", startMonth: 6, startDay: 21),
        ZodiacSign(name: "獅子", startMonth: 7, startDay: 23),
        ZodiacSign(name: "處女", startMonth: 8, startDay: 23),
        ZodiacSign(name: "天秤", startMonth: 9, startDay: 23),
        ZodiacSign(name: "天蠍", startMonth: 10, startDay: 23),
        ZodiacSign(name: "射手", startMonth: 11, startDay: 22),
        ZodiacSign(name: "摩羯", startMonth: 12, startDay: 22),
    ]

    // MARK: - Public API

    static func gregorianHoliday(month: Int, day: Int) -> String? {
        return gregorianHolidays[month]?[day]
    }

    static func lunarHoliday(lunarMonth: Int, lunarDay: Int, date: Date? = nil) -> String? {
        if let result = lunarHolidays[lunarMonth]?[lunarDay] {
            return result
        }
        if let date = date, lunarMonth == 12 {
            return checkChuxi(date: date)
        }
        return nil
    }

    private static func checkChuxi(date: Date) -> String? {
        let chineseCal = Calendar(identifier: .chinese)
        guard let tomorrow = chineseCal.date(byAdding: .day, value: 1, to: date) else {
            return nil
        }
        let tomorrowComps = chineseCal.dateComponents([.month, .day], from: tomorrow)
        if tomorrowComps.month == 1 && tomorrowComps.day == 1 {
            return "除夕"
        }
        return nil
    }

    static func zodiacSign(month: Int, day: Int) -> String? {
        for sign in zodiacSigns {
            if sign.startMonth == month
                && sign.startDay == day
            {
                return sign.name
            }
        }
        return nil
    }
}
