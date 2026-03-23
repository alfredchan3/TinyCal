//
//  EventKitManager.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import EventKit
import Foundation
import Observation

@MainActor
@Observable
final class EventKitManager {
    private let store = EKEventStore()
    var authorized = false
    private(set) var datesWithEvents: Set<DateComponents> = []

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        return cal
    }()

    func requestAccess() {
        Task {
            do {
                let granted: Bool
                if #available(iOS 17.0, macOS 14.0, *) {
                    granted = try await store.requestFullAccessToEvents()
                } else {
                    granted = try await store.requestAccess(to: .event)
                }
                self.authorized = granted
            } catch {
                self.authorized = false
            }
        }
    }

    func fetchEvents(year: Int, month: Int) {
        guard authorized else { return }

        var startComps = DateComponents()
        startComps.year = year
        startComps.month = month
        startComps.day = 1

        guard let startDate = calendar.date(from: startComps),
              let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)
        else { return }

        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = store.events(matching: predicate)

        var dates: Set<DateComponents> = []
        for event in events {
            let comps = calendar.dateComponents([.year, .month, .day], from: event.startDate)
            dates.insert(comps)
        }
        self.datesWithEvents = dates
    }

    func hasEvent(year: Int, month: Int, day: Int) -> Bool {
        let comps = DateComponents(year: year, month: month, day: day)
        return datesWithEvents.contains(comps)
    }
}
