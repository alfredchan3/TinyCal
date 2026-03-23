//
//  WeekdayHeaderView.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import SwiftUI

struct WeekdayHeaderView: View {
    let symbols: [String]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
}
