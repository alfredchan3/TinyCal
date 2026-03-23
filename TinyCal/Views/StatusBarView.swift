//
//  StatusBarView.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import SwiftUI

struct StatusBarView: View {
    let dateText: String
    let weekOfYear: Int
    let lunarText: String
    let onSettings: () -> Void
    let onGoToToday: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Button(action: onSettings) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Spacer()

            Circle()
                .fill(Color.purple.opacity(0.6))
                .frame(width: 5, height: 5)

            Text("\(dateText)  第\(weekOfYear)週  \(lunarText)")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .monospacedDigit()

            Spacer()

            Button(action: onGoToToday) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.quaternary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}
