//
//  SolarTermService.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import Foundation

struct SolarTermService {
    struct TermInfo {
        let name: String
        let longitude: Double
        let month: Int
    }

    private static let terms: [TermInfo] = [
        TermInfo(name: "小寒", longitude: 285, month: 1),
        TermInfo(name: "大寒", longitude: 300, month: 1),
        TermInfo(name: "立春", longitude: 315, month: 2),
        TermInfo(name: "雨水", longitude: 330, month: 2),
        TermInfo(name: "驚蟄", longitude: 345, month: 3),
        TermInfo(name: "春分", longitude: 0, month: 3),
        TermInfo(name: "清明", longitude: 15, month: 4),
        TermInfo(name: "穀雨", longitude: 30, month: 4),
        TermInfo(name: "立夏", longitude: 45, month: 5),
        TermInfo(name: "小滿", longitude: 60, month: 5),
        TermInfo(name: "芒種", longitude: 75, month: 6),
        TermInfo(name: "夏至", longitude: 90, month: 6),
        TermInfo(name: "小暑", longitude: 105, month: 7),
        TermInfo(name: "大暑", longitude: 120, month: 7),
        TermInfo(name: "立秋", longitude: 135, month: 8),
        TermInfo(name: "處暑", longitude: 150, month: 8),
        TermInfo(name: "白露", longitude: 165, month: 9),
        TermInfo(name: "秋分", longitude: 180, month: 9),
        TermInfo(name: "寒露", longitude: 195, month: 10),
        TermInfo(name: "霜降", longitude: 210, month: 10),
        TermInfo(name: "立冬", longitude: 225, month: 11),
        TermInfo(name: "小雪", longitude: 240, month: 11),
        TermInfo(name: "大雪", longitude: 255, month: 12),
        TermInfo(name: "冬至", longitude: 270, month: 12),
    ]

    private static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        return cal
    }()

    static func termsForYear(_ year: Int) -> [DateComponents: String] {
        var result: [DateComponents: String] = [:]
        for term in terms {
            if let date = findTermDate(year: year, targetLongitude: term.longitude, approxMonth: term.month) {
                let comps = calendar.dateComponents([.year, .month, .day], from: date)
                result[comps] = term.name
            }
        }
        return result
    }

    private static func findTermDate(year: Int, targetLongitude: Double, approxMonth: Int) -> Date? {
        var comps = DateComponents()
        comps.year = year
        comps.month = approxMonth
        comps.day = 1
        comps.hour = 0

        guard let startDate = calendar.date(from: comps) else { return nil }
        let startJD = dateToJD(startDate)

        var jd = startJD
        let targetLon = targetLongitude

        for _ in 0..<40 {
            let lon = sunApparentLongitude(jd: jd)
            var diff = targetLon - lon
            if diff > 180 { diff -= 360 }
            if diff < -180 { diff += 360 }

            if abs(diff) < 0.0001 {
                break
            }
            jd += diff / 360.0 * 365.25
        }

        return jdToDate(jd)
    }

    // MARK: - Sun Position (Jean Meeus, Astronomical Algorithms)

    private static func sunApparentLongitude(jd: Double) -> Double {
        let T = (jd - 2451545.0) / 36525.0

        var L0 = 280.46646 + 36000.76983 * T + 0.0003032 * T * T
        L0 = normalizeAngle(L0)

        var M = 357.52911 + 35999.05029 * T - 0.0001537 * T * T
        M = normalizeAngle(M)
        let Mrad = M * .pi / 180.0

        let C = (1.914602 - 0.004817 * T - 0.000014 * T * T) * sin(Mrad)
            + (0.019993 - 0.000101 * T) * sin(2 * Mrad)
            + 0.000289 * sin(3 * Mrad)

        var sunLon = L0 + C

        let omega = 125.04 - 1934.136 * T
        let omegaRad = omega * .pi / 180.0
        sunLon = sunLon - 0.00569 - 0.00478 * sin(omegaRad)

        return normalizeAngle(sunLon)
    }

    private static func normalizeAngle(_ angle: Double) -> Double {
        var a = angle.truncatingRemainder(dividingBy: 360.0)
        if a < 0 { a += 360.0 }
        return a
    }

    // MARK: - Julian Day Conversions

    private static func dateToJD(_ date: Date) -> Double {
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let Y = Double(comps.year ?? 2000)
        let M = Double(comps.month ?? 1)
        let D = Double(comps.day ?? 1)
            + Double(comps.hour ?? 0) / 24.0
            + Double(comps.minute ?? 0) / 1440.0
            + Double(comps.second ?? 0) / 86400.0

        var y = Y, m = M
        if m <= 2 {
            y -= 1
            m += 12
        }

        let A = floor(y / 100.0)
        let B = 2 - A + floor(A / 4.0)

        return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + D + B - 1524.5
    }

    private static func jdToDate(_ jd: Double) -> Date? {
        let jd = jd + 0.5
        let Z = floor(jd)
        let F = jd - Z

        let A: Double
        if Z < 2299161 {
            A = Z
        } else {
            let alpha = floor((Z - 1867216.25) / 36524.25)
            A = Z + 1 + alpha - floor(alpha / 4.0)
        }

        let B = A + 1524
        let C = floor((B - 122.1) / 365.25)
        let D = floor(365.25 * C)
        let E = floor((B - D) / 30.6001)

        let day = B - D - floor(30.6001 * E) + F
        let month: Double
        if E < 14 {
            month = E - 1
        } else {
            month = E - 13
        }
        let year: Double
        if month > 2 {
            year = C - 4716
        } else {
            year = C - 4715
        }

        var comps = DateComponents()
        comps.year = Int(year)
        comps.month = Int(month)
        comps.day = Int(day)
        comps.hour = 12
        return calendar.date(from: comps)
    }
}
