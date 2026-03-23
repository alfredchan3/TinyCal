//
//  ContentView.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = CalendarViewModel()

    var body: some View {
        VStack(spacing: 0) {
            if let monthData = viewModel.monthData {
                CalendarHeaderView(
                    year: monthData.year,
                    month: monthData.month,
                    onPrevious: { viewModel.previousMonth() },
                    onNext: { viewModel.nextMonth() }
                )

                WeekdayHeaderView(symbols: monthData.weekdaySymbols)

                MonthGridView(
                    days: monthData.days,
                    selectedDate: viewModel.selectedDate,
                    onSelectDate: { date in
                        viewModel.selectDate(date)
                    }
                )
                .padding(.horizontal, 4)
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            if value.translation.width < -50 {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.nextMonth()
                                }
                            } else if value.translation.width > 50 {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.previousMonth()
                                }
                            }
                        }
                )

                Divider()
                    .padding(.horizontal, 12)

                StatusBarView(
                    dateText: viewModel.selectedDateFormatted,
                    weekOfYear: viewModel.selectedDateWeekOfYear,
                    lunarText: lunarStatusText,
                    onSettings: {},
                    onGoToToday: { viewModel.goToToday() }
                )
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.12), radius: 10, y: 3)
        .frame(maxWidth: 420)
        .padding()
        .onAppear {
            viewModel.eventKitManager.requestAccess()
        }
        .onChange(of: viewModel.eventKitManager.authorized) { _, authorized in
            if authorized {
                viewModel.refreshEvents()
            }
        }
    }

    private var lunarStatusText: String {
        let lunar = viewModel.selectedDateLunar
        return "\(lunar.monthText)\(lunar.dayText)"
    }
}

#Preview {
    ContentView()
}
