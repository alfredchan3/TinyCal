//
//  DayCellView.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import SwiftUI

struct DayCellView: View {
    let dayInfo: DayInfo
    let isSelected: Bool
    let onTap: () -> Void

    private var dayNumberColor: Color {
        if dayInfo.isToday {
            return .white
        }
        if !dayInfo.isCurrentMonth {
            return .primary.opacity(0.3)
        }
        return .primary
    }

    private var subtitleColor: Color {
        if dayInfo.isToday {
            return .white.opacity(0.8)
        }
        if !dayInfo.isCurrentMonth {
            return .primary.opacity(0.2)
        }
        if dayInfo.holiday != nil || dayInfo.solarTerm != nil {
            return .accentColor
        }
        return .secondary
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                if dayInfo.isToday {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 30, height: 30)
                }

                Text("\(dayInfo.day)")
                    .font(.system(size: 15, weight: dayInfo.isToday ? .bold : .regular))
                    .foregroundStyle(dayNumberColor)
            }
            .frame(height: 30)

            Text(dayInfo.displayText)
                .font(.system(size: 9))
                .foregroundStyle(subtitleColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            if dayInfo.hasEvents {
                Circle()
                    .fill(dayInfo.isToday ? Color.white.opacity(0.7) : Color.accentColor)
                    .frame(width: 4, height: 4)
            } else {
                Color.clear.frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
        .background {
            if isSelected && !dayInfo.isToday {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.06))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
