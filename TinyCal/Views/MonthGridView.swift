//
//  MonthGridView.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import SwiftUI

struct MonthGridView: View {
    let days: [DayInfo]
    let selectedDate: Date
    let onSelectDate: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(days) { dayInfo in
                let isSelected = Calendar.current.isDate(dayInfo.id, inSameDayAs: selectedDate)
                DayCellView(dayInfo: dayInfo, isSelected: isSelected) {
                    onSelectDate(dayInfo.id)
                }
            }
        }
    }
}
