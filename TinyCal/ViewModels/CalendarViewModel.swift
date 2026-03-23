//
//  CalendarViewModel.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class CalendarViewModel {
    var currentYear: Int
    var currentMonth: Int
    var monthData: MonthData?
    var selectedDate: Date

    let eventKitManager = EventKitManager()

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "zh_Hant")
        return cal
    }

    private var solarTermCache: [Int: [DateComponents: String]] = [:]

    init() {
        let now = Date()
        let cal = Calendar(identifier: .gregorian)
        currentYear = cal.component(.year, from: now)
        currentMonth = cal.component(.month, from: now)
        selectedDate = now
        generateMonthData()
    }

    func goToToday() {
        let now = Date()
        currentYear = calendar.component(.year, from: now)
        currentMonth = calendar.component(.month, from: now)
        selectedDate = now
        generateMonthData()
    }

    func previousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
        generateMonthData()
    }

    func nextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
        generateMonthData()
    }

    func selectDate(_ date: Date) {
        selectedDate = date
    }

    func refreshEvents() {
        eventKitManager.fetchEvents(year: currentYear, month: currentMonth)
        generateMonthData()
    }

    func generateMonthData() {
        let cal = calendar

        var firstDayComps = DateComponents()
        firstDayComps.year = currentYear
        firstDayComps.month = currentMonth
        firstDayComps.day = 1

        guard let firstDayOfMonth = cal.date(from: firstDayComps) else { return }

        let weekdayOfFirst = cal.component(.weekday, from: firstDayOfMonth)
        let firstWeekday = cal.firstWeekday
        var offset = weekdayOfFirst - firstWeekday
        if offset < 0 { offset += 7 }

        guard let startDate = cal.date(byAdding: .day, value: -offset, to: firstDayOfMonth) else { return }

        let today = Date()
        let todayComps = cal.dateComponents([.year, .month, .day], from: today)

        let solarTerms = solarTermsForYear(currentYear)
        var prevYearTerms: [DateComponents: String] = [:]
        var nextYearTerms: [DateComponents: String] = [:]
        if currentMonth == 1 {
            prevYearTerms = solarTermsForYear(currentYear - 1)
        }
        if currentMonth == 12 {
            nextYearTerms = solarTermsForYear(currentYear + 1)
        }

        var days: [DayInfo] = []
        for i in 0..<42 {
            guard let date = cal.date(byAdding: .day, value: i, to: startDate) else { continue }
            let comps = cal.dateComponents([.year, .month, .day], from: date)
            let day = comps.day ?? 1
            let month = comps.month ?? 1
            let year = comps.year ?? currentYear
            let isCurrentMonth = month == currentMonth && year == currentYear
            let isToday = comps.year == todayComps.year
                && comps.month == todayComps.month
                && comps.day == todayComps.day

            let lunar = LunarService.lunarDate(from: date)

            let lunarHoliday = HolidayService.lunarHoliday(lunarMonth: lunar.month, lunarDay: lunar.day, date: date)
            let gregorianHoliday = HolidayService.gregorianHoliday(month: month, day: day)
            let holiday = gregorianHoliday ?? lunarHoliday

            var solarTerm: String? = nil
            let termKey = DateComponents(year: year, month: month, day: day)
            if let term = solarTerms[termKey] {
                solarTerm = term
            } else if let term = prevYearTerms[termKey] {
                solarTerm = term
            } else if let term = nextYearTerms[termKey] {
                solarTerm = term
            }

            let zodiacSign = HolidayService.zodiacSign(month: month, day: day)

            let hasEvents = eventKitManager.hasEvent(year: year, month: month, day: day)

            let lunarMonthText: String? = lunar.day == 1 ? lunar.monthText : nil

            let dayInfo = DayInfo(
                id: date,
                day: day,
                lunarDayText: lunar.dayText,
                lunarMonthText: lunarMonthText,
                holiday: holiday,
                solarTerm: solarTerm,
                zodiacSign: zodiacSign,
                isCurrentMonth: isCurrentMonth,
                isToday: isToday,
                hasEvents: hasEvents
            )
            days.append(dayInfo)
        }

        let symbols = weekdaySymbolsOrdered()
        monthData = MonthData(year: currentYear, month: currentMonth, days: days, weekdaySymbols: symbols)
    }

    private func solarTermsForYear(_ year: Int) -> [DateComponents: String] {
        if let cached = solarTermCache[year] {
            return cached
        }
        let terms = SolarTermService.termsForYear(year)
        solarTermCache[year] = terms
        return terms
    }

    private func weekdaySymbolsOrdered() -> [String] {
        let symbols = ["週日", "週一", "週二", "週三", "週四", "週五", "週六"]
        let firstWeekday = calendar.firstWeekday
        let offset = firstWeekday - 1
        return Array(symbols[offset...]) + Array(symbols[..<offset])
    }

    var selectedDateLunar: LunarDateInfo {
        LunarService.lunarDate(from: selectedDate)
    }

    var selectedDateWeekOfYear: Int {
        calendar.component(.weekOfYear, from: selectedDate)
    }

    var selectedDateFormatted: String {
        let comps = calendar.dateComponents([.month, .day], from: selectedDate)
        return "\(comps.month ?? 1)月\(comps.day ?? 1)日"
    }
}
